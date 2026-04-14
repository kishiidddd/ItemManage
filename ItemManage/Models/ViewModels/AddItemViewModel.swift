
// ViewModels/AddItemViewModel.swift
import Foundation
import Combine
import UIKit

class AddItemViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name: String = ""
    @Published var selectedCategory: CategoryModel?
    @Published var selectedPrimaryLocation: PrimaryLocationModel?
    @Published var selectedSecondaryLocation: SecondaryLocationModel?
    @Published var quantity: Int = 1
    @Published var selectedUnit: UnitModel?
    @Published var photos: [PhotoModel] = []
    @Published var productionDate: Date?
    @Published var expiryDate: Date?
    @Published var shelfLife: Int?
    @Published var remarks: String = ""
    
    // 数据源
    @Published var categories: [CategoryModel] = []
    @Published var units: [UnitModel] = []
    @Published var primaryLocations: [PrimaryLocationModel] = []
    
    // UI状态
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isFormValid: Bool = false
    
    enum DateField {
        case production
        case expiry
    }
    
    // MARK: - 计算属性
    var isEditing: Bool {
        return editingItem != nil
    }
    
    var canAddMorePhotos: Bool {
        return photos.count < 3
    }
    
    // 可用的二级位置（根据当前选择的一级位置过滤）
    var availableSecondaryLocations: [SecondaryLocationModel] {
        guard let primaryLocation = selectedPrimaryLocation,
              let secondaryLocations = primaryLocation.secondaryLocations else {
            return []
        }
        return secondaryLocations
    }
    
    // 获取当前选择的单位名称
    var selectedUnitName: String {
        return selectedUnit?.name ?? "无"
    }
    
    // 获取当前选择的位置显示文本
    var selectedLocationDisplayText: String {
        if let primary = selectedPrimaryLocation {
            if let secondary = selectedSecondaryLocation {
                return "\(primary.name) > \(secondary.name)"
            }
            return primary.name
        }
        return "未选择位置"
    }
    
    // MARK: - Private Properties
    private let repository = ItemRepository.shared
    private var editingItem: ItemModel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(item: ItemModel? = nil) {
        self.editingItem = item
        setupValidation()
        loadDataFromRepository()
    }
    
    // MARK: - Public Methods
    func loadInitialData() {
        // 数据已经在 init 中加载
    }
    
    /// 从全局仓库同步分类/单位/位置（从规则设置返回或切回添加页时调用）
    func reloadPickersFromRepository() {
        categories = repository.categories
        units = repository.units
        primaryLocations = repository.primaryLocations
    }
    
    func setShelfLife(_ days: Int?) {
        shelfLife = days
        if let days = days, let productionDate = productionDate {
            // 根据生产日期和保质期自动计算过期日期
            expiryDate = Calendar.current.date(byAdding: .day, value: days, to: productionDate)
        } else if days == nil {
            // 如果清空了保质期，不再自动计算
            if productionDate == nil {
                expiryDate = nil
            }
        }
    }
    
    func updateProductionDate(_ date: Date) {
        productionDate = date
        if let shelfLife = shelfLife {
            // 根据生产日期和保质期自动计算过期日期
            expiryDate = Calendar.current.date(byAdding: .day, value: shelfLife, to: date)
        }
    }
    
    func updateExpiryDate(_ date: Date) {
        expiryDate = date
        // 如果用户直接设置了过期日期，清除自动计算的关系
        // 不清除生产日期和保质期，但标记为用户手动设置
    }
    
    func addPhoto(localPath: String) {
        guard canAddMorePhotos else { return }
        let photo = PhotoModel(localPath: localPath, sortOrder: photos.count)
        photos.append(photo)
    }
    
    func removePhoto(at index: Int) {
        guard index < photos.count else { return }
        photos.remove(at: index)
        for (i, p) in photos.enumerated() {
            p.sortOrder = i
        }
    }
    
    func movePhoto(from fromIndex: Int, to toIndex: Int) {
        guard fromIndex != toIndex,
              fromIndex < photos.count,
              toIndex < photos.count else { return }
        let photo = photos.remove(at: fromIndex)
        photos.insert(photo, at: toIndex)
        for (i, p) in photos.enumerated() {
            p.sortOrder = i
        }
    }
    
    func saveItem(completion: @escaping (Result<ItemModel, Error>) -> Void) {
        guard validateForm() else {
            completion(.failure(NSError(domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: errorMessage ?? "请填写必填项"])))
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let item = createItemModel()
        uploadLocalPhotosThenFinish(item: item, completion: completion)
    }

    /// 本地图先上传拿 URL，再交给上层（请求里只带 http URL）
    private func uploadLocalPhotosThenFinish(item: ItemModel, completion: @escaping (Result<ItemModel, Error>) -> Void) {
        let originals = item.photos
        guard !originals.isEmpty else {
            isLoading = false
            completion(.success(item))
            return
        }
        Task { @MainActor in
            defer { isLoading = false }
            var out: [PhotoModel] = []
            do {
                for p in originals {
                    let r = p.remoteURLString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if r.lowercased().hasPrefix("http://") || r.lowercased().hasPrefix("https://") {
                        let c = PhotoModel()
                        c.url = p.url.isEmpty ? r : p.url
                        c.imageUrl = p.imageUrl
                        c.filename = p.filename
                        c.sortOrder = p.sortOrder
                        c.uploadedAt = p.uploadedAt
                        out.append(c)
                        continue
                    }
                    if let path = p.localPath, !path.isEmpty, FileManager.default.fileExists(atPath: path) {
                        let urlStr = try await ItemPhotoUploadService.upload(fileURL: URL(fileURLWithPath: path))
                        let np = PhotoModel()
                        np.url = urlStr
                        np.sortOrder = p.sortOrder
                        np.filename = p.filename
                        np.uploadedAt = Date()
                        out.append(np)
                    }
                }
                item.photos = out
                completion(.success(item))
            } catch {
                errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadItemData(_ item: ItemModel) {
        name = item.name
        selectedCategory = repository.categories.first { $0.id == item.categoryId }
        quantity = item.quantity
        selectedUnit = repository.units.first { $0.id == item.unitId }
        
        // 加载位置信息
        if let primaryLocationId = item.primaryLocationId {
            selectedPrimaryLocation = repository.primaryLocations.first { $0.id == primaryLocationId }
        }
        
        if let secondaryLocationId = item.secondaryLocationId {
            selectedSecondaryLocation = repository.secondaryLocations.first { $0.id == secondaryLocationId }
        }
        
        photos = item.photos
        
        productionDate = item.productionDate
        expiryDate = item.expiryDate
        shelfLife = item.shelfLife
        
        remarks = item.remarks ?? ""
    }
    
    private func loadDataFromRepository() {
        categories = repository.categories
        units = repository.units
        primaryLocations = repository.primaryLocations
        
        if let item = editingItem {
            loadItemData(item)
        }
    }
    
    private func createItemModel() -> ItemModel {
        let item = ItemModel()
        
        if let editingItem = editingItem {
            item.id = editingItem.id
            item.createdAt = editingItem.createdAt
        } else {
            item.id = UUID().uuidString
            item.createdAt = Date()
        }
        
        item.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        item.categoryId = selectedCategory?.id ?? ""
        item.quantity = quantity
        item.unitId = selectedUnit?.id
        
        // 设置位置
        item.primaryLocationId = selectedPrimaryLocation?.id
        item.secondaryLocationId = selectedSecondaryLocation?.id
        
        if !photos.isEmpty {
            item.photos = photos
        }
        
        // 设置日期信息
        item.productionDate = productionDate
        item.expiryDate = expiryDate
        item.shelfLife = shelfLife
        
        item.remarks = remarks.isEmpty ? nil : remarks
        item.updatedAt = Date()
        
        return item
    }
    
    private func validateForm() -> Bool {
        // 验证物品名称
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errorMessage = "请输入物品名称"
            return false
        }
        
        // 验证分类
        guard selectedCategory != nil else {
            errorMessage = "请选择分类"
            return false
        }
        
        // 验证数量
        if quantity <= 0 {
            errorMessage = "数量必须大于0"
            return false
        }
        
        // 验证日期逻辑
        if let productionDate = productionDate, let expiryDate = expiryDate {
            if expiryDate < productionDate {
                errorMessage = "过期日期不能早于生产日期"
                return false
            }
        }
        
        // 验证保质期
        if let shelfLife = shelfLife, shelfLife <= 0 {
            errorMessage = "保质期必须大于0天"
            return false
        }
        
        errorMessage = nil
        return true
    }
    
    private func setupValidation() {
        // 监听表单字段变化，验证表单有效性
        Publishers.CombineLatest3($name, $selectedCategory, $quantity)
            .map { name, category, quantity in
                let isNameValid = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                let isCategoryValid = category != nil
                let isQuantityValid = quantity > 0
                return isNameValid && isCategoryValid && isQuantityValid
            }
            .assign(to: &$isFormValid)
    }
    
    // MARK: - Helper Methods
    func formatDate(_ date: Date, format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func clearLocation() {
        selectedPrimaryLocation = nil
        selectedSecondaryLocation = nil
    }
    
    func setLocation(primary: PrimaryLocationModel?, secondary: SecondaryLocationModel?) {
        selectedPrimaryLocation = primary
        selectedSecondaryLocation = secondary
    }
    
    func isLocationValid() -> Bool {
        if let primary = selectedPrimaryLocation {
            if let secondary = selectedSecondaryLocation {
                // 检查二级位置是否属于当前的一级位置
                return primary.secondaryLocations?.contains(where: { $0.id == secondary.id }) ?? false
            }
            return true
        }
        return selectedSecondaryLocation == nil
    }
}


