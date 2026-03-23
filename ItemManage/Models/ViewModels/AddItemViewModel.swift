import Foundation
import Combine

class AddItemViewModel {
    
    // MARK: - 输入数据
    @Published var name: String = ""
    @Published var selectedCategory: CategoryModel?
    @Published var quantity: Int = 1
    @Published var totalPrice: String = ""
    @Published var selectedUnit: UnitModel?
    @Published var photos: [PhotoModel] = []
    
    @Published var productionDate: Date?
    @Published var expiryDate: Date?
    
    @Published var selectedReminderRule: ReminderRuleModel?
    @Published var customReminderDays: Int?
    
    @Published var remarks: String = ""
    
    // MARK: - UI 状态
    @Published var categories: [CategoryModel] = []
    @Published var units: [UnitModel] = []
    @Published var reminderRules: [ReminderRuleModel] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showDatePicker: Bool = false
    
    // MARK: - 验证状态
    @Published var nameError: String?
    @Published var categoryError: String?
    @Published var isFormValid: Bool = false
    
    // 当前编辑的日期字段
    var activeDateField: DateField?
    
    enum DateField {
        case production, expiry
    }
    
    // MARK: - 计算属性（非 @Published，但可以通过其他 @Published 派生）
    var displayPrice: Double? {
        return Double(totalPrice)
    }
    
    var reminderDescription: String {
        if let rule = selectedReminderRule {
            return rule.name
        } else if let days = customReminderDays {
            return "提前\(days)天"
        }
        return "不提醒"
    }
    
    var canAddMorePhotos: Bool {
        return photos.count < 3
    }
    
    var isEditing: Bool {
        return !(editingItemId?.isEmpty ?? true)
    }
    
    // MARK: - Private Properties
    private var editingItemId: String?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    init(item: ItemModel? = nil) {
        if let item = item {
            editingItemId = item.id
        }
        
        setupValidation()
        loadInitialData()
    }
    
    // MARK: - Setup
    private func setupValidation() {
        // 使用 Combine 监听表单验证
        Publishers.CombineLatest($name, $selectedCategory)
            .map { name, category in
                return !name.isEmpty && category != nil
            }
            .assign(to: &$isFormValid)
        
        // 实时验证名称
        $name
            .dropFirst()  // 跳过初始值
            .map { name -> String? in
                if name.isEmpty {
                    return "请输入物品名称"
                }
                return nil
            }
            .assign(to: &$nameError)
        
        // 实时验证分类
        $selectedCategory
            .dropFirst()
            .map { category -> String? in
                if category == nil {
                    return "请选择分类"
                }
                return nil
            }
            .assign(to: &$categoryError)
        
        // 监听日期变化，验证逻辑
        Publishers.CombineLatest($productionDate, $expiryDate)
            .sink { [weak self] production, expiry in
                guard let production = production, let expiry = expiry else { return }
                if expiry < production {
                    self?.errorMessage = "过期日期不能早于生产日期"
                } else {
                    self?.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 数据加载
    func loadInitialData() {
        isLoading = true
        
        let group = DispatchGroup()
        
        group.enter()
        ItemDataService.shared.getCategories { [weak self] categories in
            self?.categories = categories
            group.leave()
        }
        
        group.enter()
        ItemDataService.shared.getUnits { [weak self] units in
            self?.units = units
            group.leave()
        }
        
        group.enter()
        ItemDataService.shared.getReminderRules { [weak self] rules in
            self?.reminderRules = rules
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            
            // 如果是编辑模式，需要重新加载 item 数据
            if let itemId = self?.editingItemId {
                self?.loadEditingItem(id: itemId)
            }
        }
    }
    
    private func loadEditingItem(id: String) {
        // 这里应该从数据服务加载完整的 item 数据
        ItemDataService.shared.getItem(id: id) { [weak self] result in
            switch result {
            case .success(let item):
                self?.loadItem(item)
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func loadItem(_ item: ItemModel) {
        name = item.name
        selectedCategory = categories.first { $0.id == item.categoryId }
        quantity = item.quantity
        if let price = item.totalPrice {
            totalPrice = String(format: "%.2f", price)
        }
        selectedUnit = units.first { $0.id == item.unitId }
        photos = item.photos
        productionDate = item.productionDate
        expiryDate = item.expiryDate
        selectedReminderRule = reminderRules.first { $0.id == item.reminder.ruleId }
        customReminderDays = item.reminder.daysBefore
        remarks = item.remarks ?? ""
    }
    
    // MARK: - 照片管理
    func addPhoto(localPath: String) {
        guard canAddMorePhotos else { return }
        
        let newPhoto = PhotoModel(localPath: localPath, sortOrder: photos.count)
        photos.append(newPhoto)
    }
    
    func removePhoto(at index: Int) {
        guard index < photos.count else { return }
        photos.remove(at: index)
        
        // 更新排序
        for (i, photo) in photos.enumerated() {
            photo.sortOrder = i
        }
    }
    
    func movePhoto(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex >= 0, sourceIndex < photos.count,
              destinationIndex >= 0, destinationIndex <= photos.count else {
            return
        }
        
        let photo = photos.remove(at: sourceIndex)
        photos.insert(photo, at: destinationIndex)
        
        // 更新排序
        for (i, photo) in photos.enumerated() {
            photo.sortOrder = i
        }
    }
    
    // MARK: - 日期管理
    func setProductionDate(_ date: Date) {
        productionDate = date
    }
    
    func setExpiryDate(_ date: Date) {
        expiryDate = date
    }
    
    // MARK: - 提交表单
    func saveItem(completion: @escaping (Result<ItemModel, Error>) -> Void) {
        guard isFormValid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "表单验证失败"])))
            return
        }
        
        isLoading = true
        
        // 构建请求数据
        let newItem = ItemModel()
        newItem.name = name
        newItem.categoryId = selectedCategory?.id ?? ""
        newItem.quantity = quantity
        newItem.totalPrice = displayPrice
        newItem.unitId = selectedUnit?.id
        newItem.photos = photos
        newItem.productionDate = productionDate
        newItem.expiryDate = expiryDate
        newItem.remarks = remarks.isEmpty ? nil : remarks
        
        // 设置提醒
        if let rule = selectedReminderRule {
            newItem.reminder.ruleId = rule.id
            newItem.reminder.rule = rule
        }
        
        if let days = customReminderDays {
            newItem.reminder.daysBefore = days
        }
        
        let request = CreateItemRequest(from: newItem)
        
        ItemDataService.shared.createItem(request) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                completion(result)
            }
        }
    }
    
    // MARK: - 重置表单
    func resetForm() {
        name = ""
        selectedCategory = nil
        quantity = 1
        totalPrice = ""
        selectedUnit = nil
        photos = []
        productionDate = nil
        expiryDate = nil
        selectedReminderRule = nil
        customReminderDays = nil
        remarks = ""
        errorMessage = nil
    }
}

