
//
//  ItemDataService.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation

class ItemDataService {
    
    static let shared = ItemDataService()
    private init() {
        print("✅ ItemDataService initialized")
    }
    
    // MARK: - 分类管理
    func getCategories(completion: @escaping ([CategoryModel]) -> Void) {
        print("📦 getCategories called")
        
        // 确保在主线程回调
        DispatchQueue.main.async {
            // 创建示例数据
            let categories = [
                CategoryModel.example(),
                {
                    let c = CategoryModel()
                    c.id = "2"
                    c.name = "日用品"
                    c.icon = "🧴"
                    c.color = "#4ECDC4"
                    c.itemCount = 3
                    return c
                }(),
                {
                    let c = CategoryModel()
                    c.id = "3"
                    c.name = "电子产品"
                    c.icon = "📱"
                    c.color = "#45B7D1"
                    c.itemCount = 2
                    return c
                }()
            ]
            
            print("📦 Returning \(categories.count) categories")
            completion(categories)
        }
    }
    
    // MARK: - 单位管理
    func getUnits(completion: @escaping ([UnitModel]) -> Void) {
        print("📦 getUnits called")
        
        DispatchQueue.main.async {
            let units = [
                UnitModel.example(),
                {
                    let u = UnitModel()
                    u.id = "2"
                    u.name = "件"
                    u.abbreviation = "件"
                    return u
                }(),
                {
                    let u = UnitModel()
                    u.id = "3"
                    u.name = "瓶"
                    u.abbreviation = "瓶"
                    return u
                }(),
                {
                    let u = UnitModel()
                    u.id = "4"
                    u.name = "千克"
                    u.abbreviation = "kg"
                    return u
                }()
            ]
            
            print("📦 Returning \(units.count) units")
            completion(units)
        }
    }
    
    // MARK: - 提醒规则
    func getReminderRules(completion: @escaping ([ReminderRuleModel]) -> Void) {
        print("📦 getReminderRules called")
        
        DispatchQueue.main.async {
            let rules = [
                ReminderRuleModel.example(),
                {
                    let r = ReminderRuleModel()
                    r.id = "2"
                    r.name = "提前1天"
                    r.daysBefore = 1
                    r.desc = "过期前1天提醒"
                    return r
                }(),
                {
                    let r = ReminderRuleModel()
                    r.id = "3"
                    r.name = "提前7天"
                    r.daysBefore = 7
                    r.desc = "过期前7天提醒"
                    return r
                }(),
                {
                    let r = ReminderRuleModel()
                    r.id = "4"
                    r.name = "不提醒"
                    r.daysBefore = nil
                    r.desc = "不设置提醒"
                    return r
                }()
            ]
            
            print("📦 Returning \(rules.count) rules")
            completion(rules)
        }
    }
    
    // MARK: - 物品管理
    func getItems(page: Int = 1,
                  categoryId: String? = nil,
                  keyword: String? = nil,
                  completion: @escaping (Result<ItemsListResponse, Error>) -> Void) {
        
        print("📦 getItems called, page: \(page)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let response = ItemsListResponse()
            response.items = [
                ItemModel.example(),
                {
                    let item = ItemModel.example()
                    item.id = "2"
                    item.name = "牛奶"
                    item.quantity = 2
                    item.expiryDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
                    return item
                }(),
                {
                    let item = ItemModel.example()
                    item.id = "3"
                    item.name = "面包"
                    item.quantity = 1
                    item.expiryDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                    return item
                }(),
                {
                    let item = ItemModel.example()
                    item.id = "2"
                    item.name = "牛奶"
                    item.quantity = 2
                    item.expiryDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
                    return item
                }(),
                {
                    let item = ItemModel.example()
                    item.id = "3"
                    item.name = "面包"
                    item.quantity = 1
                    item.expiryDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                    return item
                }(),
                {
                    let item = ItemModel.example()
                    item.id = "2"
                    item.name = "牛奶"
                    item.quantity = 2
                    item.expiryDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
                    return item
                }(),
                {
                    let item = ItemModel.example()
                    item.id = "3"
                    item.name = "面包"
                    item.quantity = 1
                    item.expiryDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                    return item
                }()
                
            ]
            
            response.pagination = PaginationModel()
            response.pagination?.page = page
            response.pagination?.limit = 20
            response.pagination?.total = 3
            response.pagination?.pages = 1
            
            print("📦 Returning \(response.items.count) items")
            completion(.success(response))
        }
    }
    
    func createItem(_ item: CreateItemRequest,
                    completion: @escaping (Result<ItemModel, Error>) -> Void) {
        
        print("📦 createItem called")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let newItem = ItemModel()
            newItem.id = UUID().uuidString
            newItem.name = item.name
            newItem.categoryId = item.categoryId
            newItem.quantity = item.quantity
            newItem.totalPrice = item.totalPrice
            newItem.unitId = item.unitId
            newItem.productionDate = item.productionDate
            newItem.expiryDate = item.expiryDate
            newItem.remarks = item.remarks
            
            print("📦 Created item with id: \(newItem.id)")
            completion(.success(newItem))
        }
    }
    
    func updateItem(_ item: ItemModel,
                    completion: @escaping (Result<ItemModel, Error>) -> Void) {
        
        print("📦 updateItem called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(item))
        }
    }
    
    func deleteItem(id: String,
                    completion: @escaping (Result<Bool, Error>) -> Void) {
        
        print("📦 deleteItem called, id: \(id)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(true))
        }
    }
    
    func getItem(id: String, completion: @escaping (Result<ItemModel, Error>) -> Void) {
        print("📦 getItem called, id: \(id)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let item = ItemModel.example()
            item.id = id
            print("📦 Returning item: \(item.name)")
            completion(.success(item))
        }
    }
}

// MARK: - 扩展：过期物品相关方法
extension ItemDataService {
    
    /// 获取指定日期过期的物品
    /// - Parameters:
    ///   - date: 指定的日期
    ///   - completion: 完成回调，返回过期物品列表或错误
    func getExpiredItems(for date: Date,
                         completion: @escaping (Result<[ItemModel], Error>) -> Void) {
        
        print("📦 getExpiredItems called for date: \(date)")
        
        // 获取当天的开始和结束时间
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            completion(.success([]))
            return
        }
        
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // 获取所有物品（这里应该调用您的API）
            self.getItems(page: 1, categoryId: nil, keyword: nil) { result in
                switch result {
                case .success(let response):
                    // 筛选出指定日期过期的物品
                    let expiredItems = response.items.filter { item in
                        guard let expiryDate = item.expiryDate else { return false }
                        // 检查是否在当天过期
                        return expiryDate >= startOfDay && expiryDate < endOfDay
                    }
                    
                    print("📦 Found \(expiredItems.count) expired items for date \(date)")
                    completion(.success(expiredItems))
                    
                case .failure(let error):
                    print("❌ Failed to get items: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    
    /// 获取即将过期的物品（指定天数内）
    /// - Parameters:
    ///   - days: 未来天数（例如：3表示未来3天内过期的物品）
    ///   - completion: 完成回调
    func getUpcomingExpiredItems(days: Int = 7,
                                 completion: @escaping (Result<[ItemModel], Error>) -> Void) {
        
        print("📦 getUpcomingExpiredItems called for next \(days) days")
        
        let calendar = Calendar.current
        let now = Date()
        let endDate = calendar.date(byAdding: .day, value: days, to: now) ?? now
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.getItems(page: 1, categoryId: nil, keyword: nil) { result in
                switch result {
                case .success(let response):
                    // 筛选出即将过期的物品
                    let upcomingItems = response.items.filter { item in
                        guard let expiryDate = item.expiryDate else { return false }
                        return expiryDate >= now && expiryDate <= endDate
                    }
                    
                    // 按过期日期排序
                    let sortedItems = upcomingItems.sorted {
                        ($0.expiryDate ?? Date.distantFuture) < ($1.expiryDate ?? Date.distantFuture)
                    }
                    
                    print("📦 Found \(sortedItems.count) upcoming expired items")
                    completion(.success(sortedItems))
                    
                case .failure(let error):
                    print("❌ Failed to get items: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// 获取已过期的物品
    /// - Parameter completion: 完成回调
    func getExpiredItems(completion: @escaping (Result<[ItemModel], Error>) -> Void) {
        
        print("📦 getExpiredItems called (all expired)")
        
        let now = Date()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.getItems(page: 1, categoryId: nil, keyword: nil) { result in
                switch result {
                case .success(let response):
                    // 筛选出已过期的物品
                    let expiredItems = response.items.filter { item in
                        guard let expiryDate = item.expiryDate else { return false }
                        return expiryDate < now
                    }
                    
                    // 按过期日期倒序排序（最新的过期物品在前）
                    let sortedItems = expiredItems.sorted {
                        ($0.expiryDate ?? Date.distantPast) > ($1.expiryDate ?? Date.distantPast)
                    }
                    
                    print("📦 Found \(sortedItems.count) expired items")
                    completion(.success(sortedItems))
                    
                case .failure(let error):
                    print("❌ Failed to get items: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// 获取指定日期范围的过期物品
    /// - Parameters:
    ///   - startDate: 开始日期
    ///   - endDate: 结束日期
    ///   - completion: 完成回调
    func getExpiredItems(from startDate: Date,
                         to endDate: Date,
                         completion: @escaping (Result<[ItemModel], Error>) -> Void) {
        
        print("📦 getExpiredItems called from \(startDate) to \(endDate)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.getItems(page: 1, categoryId: nil, keyword: nil) { result in
                switch result {
                case .success(let response):
                    // 筛选出指定日期范围内过期的物品
                    let expiredItems = response.items.filter { item in
                        guard let expiryDate = item.expiryDate else { return false }
                        return expiryDate >= startDate && expiryDate <= endDate
                    }
                    
                    print("📦 Found \(expiredItems.count) expired items in date range")
                    completion(.success(expiredItems))
                    
                case .failure(let error):
                    print("❌ Failed to get items: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// 按月份分组获取过期物品
    /// - Parameters:
    ///   - year: 年份
    ///   - month: 月份
    ///   - completion: 完成回调，返回分组后的物品字典
    func getExpiredItemsGroupedByDay(forYear year: Int,
                                      month: Int,
                                      completion: @escaping (Result<[Int: [ItemModel]], Error>) -> Void) {
        
        print("📦 getExpiredItemsGroupedByDay called for \(year)-\(month)")
        
        // 构建月份的开始和结束日期
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            completion(.success([:]))
            return
        }
        
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: endOfMonth) ?? endOfMonth
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.getItems(page: 1, categoryId: nil, keyword: nil) { result in
                switch result {
                case .success(let response):
                    // 筛选出本月过期的物品
                    let monthItems = response.items.filter { item in
                        guard let expiryDate = item.expiryDate else { return false }
                        return expiryDate >= startOfMonth && expiryDate < endOfDay
                    }
                    
                    // 按天分组
                    var groupedItems: [Int: [ItemModel]] = [:]
                    
                    for item in monthItems {
                        guard let expiryDate = item.expiryDate else { continue }
                        let day = calendar.component(.day, from: expiryDate)
                        
                        if groupedItems[day] == nil {
                            groupedItems[day] = []
                        }
                        groupedItems[day]?.append(item)
                    }
                    
                    print("📦 Found items in \(groupedItems.count) days of month \(month)")
                    completion(.success(groupedItems))
                    
                case .failure(let error):
                    print("❌ Failed to get items: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// 获取过期物品统计信息
    /// - Parameter completion: 完成回调，返回统计信息
    func getExpiredItemsStatistics(completion: @escaping (Result<ExpiredItemsStatistics, Error>) -> Void) {
        
        print("📦 getExpiredItemsStatistics called")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.getItems(page: 1, categoryId: nil, keyword: nil) { result in
                switch result {
                case .success(let response):
                    let now = Date()
                    let calendar = Calendar.current
                    
                    var statistics = ExpiredItemsStatistics()
                    
                    for item in response.items {
                        guard let expiryDate = item.expiryDate else { continue }
                        
                        // 计算过期状态
                        let daysUntilExpire = calendar.dateComponents([.day], from: now, to: expiryDate).day ?? 0
                        
                        if daysUntilExpire < 0 {
                            // 已过期
                            statistics.expiredCount += 1
                            statistics.expiredItems.append(item)
                        } else if daysUntilExpire <= 3 {
                            // 即将过期（3天内）
                            statistics.soonExpiredCount += 1
                            statistics.soonExpiredItems.append(item)
                        } else if daysUntilExpire <= 7 {
                            // 一周内过期
                            statistics.weekExpiredCount += 1
                        }
                        
                        // 按分类统计
                        let categoryId = item.categoryId
                        statistics.categoryCount[categoryId, default: 0] += 1
                    }
                    
                    print("📦 Statistics: expired=\(statistics.expiredCount), soon=\(statistics.soonExpiredCount)")
                    completion(.success(statistics))
                    
                case .failure(let error):
                    print("❌ Failed to get items: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - 统计信息模型
struct ExpiredItemsStatistics {
    var expiredCount: Int = 0
    var soonExpiredCount: Int = 0
    var weekExpiredCount: Int = 0
    var expiredItems: [ItemModel] = []
    var soonExpiredItems: [ItemModel] = []
    var categoryCount: [String: Int] = [:]
    
    var totalExpiringItems: Int {
        return expiredCount + soonExpiredCount
    }
}

