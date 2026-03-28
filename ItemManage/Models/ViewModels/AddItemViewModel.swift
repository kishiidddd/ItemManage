//import Foundation
//import Combine
//
//class AddItemViewModel {
//    
//    // MARK: - 输入数据
//    @Published var name: String = ""
//    @Published var selectedCategory: CategoryModel?
//    @Published var quantity: Int = 1
//    @Published var totalPrice: String = ""
//    @Published var selectedUnit: UnitModel?
//    @Published var photos: [PhotoModel] = []
//    
//    // 日期相关字段
//    @Published var productionDate: Date?
//    @Published var expiryDate: Date?
//    @Published var shelfLife: Int?  // 新增：保质期（天数）
//    
//    @Published var selectedReminderRule: ReminderRuleModel?
//    @Published var customReminderDays: Int?
//    
//    @Published var remarks: String = ""
//    
//    // MARK: - UI 状态
//    @Published var categories: [CategoryModel] = []
//    @Published var units: [UnitModel] = []
//    @Published var reminderRules: [ReminderRuleModel] = []
//    
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    @Published var showDatePicker: Bool = false
//    
//    // MARK: - 验证状态
//    @Published var nameError: String?
//    @Published var isFormValid: Bool = false  // 只有名称是必填的
//    
//    // 当前编辑的日期字段
//    var activeDateField: DateField?
//    
//    enum DateField {
//        case production, expiry
//    }
//    
//    // MARK: - 计算属性
//    var displayPrice: Double? {
//        return Double(totalPrice)
//    }
//    
//    var reminderDescription: String {
//        if let rule = selectedReminderRule {
//            return rule.name
//        } else if let days = customReminderDays {
//            return "提前\(days)天"
//        }
//        return "不提醒"
//    }
//    
//    var canAddMorePhotos: Bool {
//        return photos.count < 3
//    }
//    
//    var isEditing: Bool {
//        return !(editingItemId?.isEmpty ?? true)
//    }
//    
//    // MARK: - Private Properties
//    private var editingItemId: String?
//    private var cancellables = Set<AnyCancellable>()
//    
//    // MARK: - 初始化
//    init(item: ItemModel? = nil) {
//        if let item = item {
//            editingItemId = item.id
//        }
//        
//        setupValidation()
//        loadInitialData()
//    }
//    
//    // MARK: - Setup
//    private func setupValidation() {
//        // 只验证名称是否为空
//        $name
//            .map { name -> Bool in
//                return !name.isEmpty
//            }
//            .assign(to: &$isFormValid)
//        
//        // 实时验证名称
//        $name
//            .dropFirst()
//            .map { name -> String? in
//                if name.isEmpty {
//                    return "请输入物品名称"
//                }
//                return nil
//            }
//            .assign(to: &$nameError)
//        
//        // 监听日期变化，验证逻辑（如果有过期日期和生产日期）
//        Publishers.CombineLatest($productionDate, $expiryDate)
//            .sink { [weak self] production, expiry in
//                guard let production = production, let expiry = expiry else { return }
//                if expiry < production {
//                    self?.errorMessage = "过期日期不能早于生产日期"
//                } else {
//                    // 只有当错误消息是日期验证错误时才清除
//                    if self?.errorMessage == "过期日期不能早于生产日期" {
//                        self?.errorMessage = nil
//                    }
//                }
//            }
//            .store(in: &cancellables)
//    }
//    
//    // MARK: - 数据加载
//    func loadInitialData() {
//        isLoading = true
//        
//        let group = DispatchGroup()
//        
//        group.enter()
//        ItemDataService.shared.getCategories { [weak self] categories in
//            self?.categories = categories
//            group.leave()
//        }
//        
//        group.enter()
//        ItemDataService.shared.getUnits { [weak self] units in
//            self?.units = units
//            group.leave()
//        }
//        
//        group.enter()
//        ItemDataService.shared.getReminderRules { [weak self] rules in
//            self?.reminderRules = rules
//            group.leave()
//        }
//        
//        group.notify(queue: .main) { [weak self] in
//            self?.isLoading = false
//            
//            // 如果是编辑模式，需要重新加载 item 数据
//            if let itemId = self?.editingItemId {
//                self?.loadEditingItem(id: itemId)
//            }
//        }
//    }
//    
//    private func loadEditingItem(id: String) {
//        ItemDataService.shared.getItem(id: id) { [weak self] result in
//            switch result {
//            case .success(let item):
//                self?.loadItem(item)
//            case .failure(let error):
//                self?.errorMessage = error.localizedDescription
//            }
//        }
//    }
//    
//    private func loadItem(_ item: ItemModel) {
//        name = item.name
//        selectedCategory = categories.first { $0.id == item.categoryId }
//        quantity = item.quantity
//        if let price = item.totalPrice {
//            totalPrice = String(format: "%.2f", price)
//        }
//        selectedUnit = units.first { $0.id == item.unitId }
//        photos = item.photos
//        productionDate = item.productionDate
//        expiryDate = item.expiryDate
//        shelfLife = item.shelfLife  // 加载保质期
//        selectedReminderRule = reminderRules.first { $0.id == item.reminder.ruleId }
//        customReminderDays = item.reminder.daysBefore
//        remarks = item.remarks ?? ""
//    }
//    
//    // MARK: - 照片管理
//    func addPhoto(localPath: String) {
//        guard canAddMorePhotos else { return }
//        
//        let newPhoto = PhotoModel(localPath: localPath, sortOrder: photos.count)
//        photos.append(newPhoto)
//    }
//    
//    func removePhoto(at index: Int) {
//        guard index < photos.count else { return }
//        photos.remove(at: index)
//        
//        // 更新排序
//        for (i, photo) in photos.enumerated() {
//            photo.sortOrder = i
//        }
//    }
//    
//    func movePhoto(from sourceIndex: Int, to destinationIndex: Int) {
//        guard sourceIndex >= 0, sourceIndex < photos.count,
//              destinationIndex >= 0, destinationIndex <= photos.count else {
//            return
//        }
//        
//        let photo = photos.remove(at: sourceIndex)
//        photos.insert(photo, at: destinationIndex)
//        
//        // 更新排序
//        for (i, photo) in photos.enumerated() {
//            photo.sortOrder = i
//        }
//    }
//    
//    // MARK: - 日期管理
//    func setProductionDate(_ date: Date) {
//        productionDate = date
//        // 如果同时有生产日期和保质期，自动计算过期日期
//        if let shelfLife = shelfLife {
//            expiryDate = Calendar.current.date(byAdding: .day, value: shelfLife, to: date)
//        }
//    }
//    
//    func setExpiryDate(_ date: Date) {
//        expiryDate = date
//    }
//    
//    func setShelfLife(_ days: Int) {
//        shelfLife = days
//        // 如果同时有生产日期和保质期，自动计算过期日期
//        if let productionDate = productionDate {
//            expiryDate = Calendar.current.date(byAdding: .day, value: days, to: productionDate)
//        }
//    }
//    
//    // MARK: - 提交表单
//    func saveItem(completion: @escaping (Result<ItemModel, Error>) -> Void) {
//        // 只验证名称
//        guard !name.isEmpty else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "请填写物品名称"])))
//            return
//        }
//        
//        isLoading = true
//        
//        // 构建请求数据
//        let request = CreateItemRequest()
//        request.name = name
//        request.categoryId = selectedCategory?.id ?? ""
//        request.quantity = quantity
//        request.totalPrice = displayPrice
//        request.unitId = selectedUnit?.id
//        request.productionDate = productionDate
//        request.expiryDate = expiryDate
//        request.shelfLife = shelfLife  // 添加保质期
//        request.remarks = remarks.isEmpty ? nil : remarks
//        request.level = 3
//        
//        // 处理提醒设置
//        if let rule = selectedReminderRule {
//            request.reminder = [
//                "ruleId": rule.id,
//                "daysBefore": rule.daysBefore ?? NSNull()
//            ]
//        }
//        
//        if let days = customReminderDays {
//            if request.reminder == nil {
//                request.reminder = [:]
//            }
//            request.reminder?["daysBefore"] = days
//        }
//        
//        // 处理照片
//        request.photos = photos.compactMap { $0.url.isEmpty ? nil : $0.url }
//        
//        ItemDataService.shared.createItem(request) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                completion(result)
//            }
//        }
//    }
//    
//    // MARK: - 重置表单
//    func resetForm() {
//        name = ""
//        selectedCategory = nil
//        quantity = 1
//        totalPrice = ""
//        selectedUnit = nil
//        photos = []
//        productionDate = nil
//        expiryDate = nil
//        shelfLife = nil
//        selectedReminderRule = nil
//        customReminderDays = nil
//        remarks = ""
//        errorMessage = nil
//    }
//}

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
    @Published var totalPrice: String = ""
    @Published var selectedUnit: UnitModel?
    @Published var photos: [PhotoModel] = []
    @Published var productionDate: Date?
    @Published var expiryDate: Date?
    @Published var shelfLife: Int?
    @Published var selectedReminderRule: ReminderRuleModel?
    @Published var customReminderDays: Int?
    @Published var remarks: String = ""
    
    // 数据源
    @Published var categories: [CategoryModel] = []
    @Published var units: [UnitModel] = []
    @Published var primaryLocations: [PrimaryLocationModel] = []
    @Published var reminderRules: [ReminderRuleModel] = []
    
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
        
        // 模拟保存（实际项目中应该调用 API）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
            completion(.success(item))
        }
    }
    
    // MARK: - Private Methods
    private func loadItemData(_ item: ItemModel) {
        name = item.name
        selectedCategory = repository.categories.first { $0.id == item.categoryId }
        quantity = item.quantity
        
        if let totalPrice = item.totalPrice {
            self.totalPrice = String(format: "%.2f", totalPrice)
        }
        
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
        
        // 加载提醒规则
        if let reminderDays = item.reminder.daysBefore {
            customReminderDays = reminderDays
            // 查找自定义提醒规则（daysBefore 为 nil 的规则）
            selectedReminderRule = reminderRules.first { $0.daysBefore == nil }
        } else if let reminderRuleId = item.reminder.ruleId {
            selectedReminderRule = reminderRules.first { $0.id == reminderRuleId }
        }
    }
    
    private func loadDataFromRepository() {
        categories = repository.categories
        units = repository.units
        primaryLocations = repository.primaryLocations
        
        if let item = editingItem {
            loadItemData(item)
        }
        
        ItemDataService.shared.getReminderRules { [weak self] rules in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.reminderRules = rules
                if let item = self.editingItem {
                    self.loadItemData(item)
                }
            }
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
        
        if let priceText = totalPrice.isEmpty ? nil : totalPrice,
           let price = Double(priceText) {
            item.totalPrice = price
        }
        
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
        
        // 设置提醒规则
        if let rule = selectedReminderRule {
            if rule.daysBefore == nil {
                // 自定义提醒天数
                if let days = customReminderDays, days > 0 {
                    item.reminder.daysBefore = days
                    item.reminder.isEnabled = true
                } else {
                    item.reminder.isEnabled = false
                }
            } else {
                // 预设提醒规则
                item.reminder.ruleId = rule.id
                item.reminder.daysBefore = rule.daysBefore
                item.reminder.isEnabled = true
            }
        } else {
            item.reminder.isEnabled = false
        }
        
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
        
        // 验证价格格式
        if !totalPrice.isEmpty {
            if let price = Double(totalPrice), price < 0 {
                errorMessage = "价格不能为负数"
                return false
            }
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
        Publishers.CombineLatest4($name, $selectedCategory, $quantity, $totalPrice)
            .map { name, category, quantity, price in
                let isNameValid = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                let isCategoryValid = category != nil
                let isQuantityValid = quantity > 0
                
                var isPriceValid = true
                if !price.isEmpty {
                    if let priceValue = Double(price) {
                        isPriceValid = priceValue >= 0
                    } else {
                        isPriceValid = false
                    }
                }
                
                return isNameValid && isCategoryValid && isQuantityValid && isPriceValid
            }
            .assign(to: &$isFormValid)
    }
    
    // MARK: - Helper Methods
    func getExpiryStatus() -> (description: String, color: String)? {
        guard let expiryDate = expiryDate else { return nil }
        
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
        
        if daysUntilExpiry < 0 {
            return ("已过期\(-daysUntilExpiry)天", "#FF6B6B")
        } else if daysUntilExpiry == 0 {
            return ("今天过期", "#FFB347")
        } else if daysUntilExpiry <= 3 {
            return ("\(daysUntilExpiry)天后过期", "#FFB347")
        } else {
            return ("\(daysUntilExpiry)天后过期", "#4CAF50")
        }
    }
    
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

// MARK: - Extension for Mock Data
extension AddItemViewModel {
    // 添加一些示例数据，方便测试
    static func mockViewModel() -> AddItemViewModel {
        let viewModel = AddItemViewModel()
        viewModel.name = "测试物品"
        viewModel.selectedCategory = CategoryModel.example()
        viewModel.selectedPrimaryLocation = PrimaryLocationModel.example()
        viewModel.selectedSecondaryLocation = SecondaryLocationModel.example()
        viewModel.quantity = 3
        viewModel.totalPrice = "29.99"
        viewModel.selectedUnit = UnitModel.example()
        viewModel.remarks = "这是一个测试物品"
        viewModel.productionDate = Date()
        viewModel.shelfLife = 30
        viewModel.calculateExpiryDate()
        return viewModel
    }
    
    func calculateExpiryDate() {
        if let productionDate = productionDate, let shelfLife = shelfLife {
            expiryDate = Calendar.current.date(byAdding: .day, value: shelfLife, to: productionDate)
        }
    }
}

// MARK: - 提醒规则模型扩展
//extension ReminderRuleModel {
//    static func example() -> ReminderRuleModel {
//        let rule = ReminderRuleModel()
//        rule.id = "1"
//        rule.name = "提前1天提醒"
//        rule.daysBefore = 1
//        return rule
//    }
//}
//
//// MARK: - 单位模型扩展
//extension UnitModel {
//    static func example() -> UnitModel {
//        let unit = UnitModel()
//        unit.id = "1"
//        unit.name = "个"
//        unit.symbol = "个"
//        return unit
//    }
//}
//
//// MARK: - 分类模型扩展
//extension CategoryModel {
//    static func example() -> CategoryModel {
//        let category = CategoryModel()
//        category.id = "1"
//        category.name = "食品"
//        category.icon = "🍎"
//        category.color = "#FF6B6B"
//        return category
//    }
//}
