////
////  ItemDataService.swift
////  ItemManage
////
////  Created by a on 2026/3/17.
////
//
//import Foundation
//
//class ItemDataService {
//    
//    static let shared = ItemDataService()
//    private let mockDataService = MockDataService.shared
//    
//    private init() {
//        print("✅ ItemDataService initialized (Backend: MockDataService)")
//    }
//    
//    // MARK: - 分类管理
//    func getCategories(completion: @escaping ([CategoryModel]) -> Void) {
//        print("📦 getCategories called")
//        
//        // 模拟网络请求延迟
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            guard let self = self else { return }
//            let categories = self.mockDataService.getCategories()
//            print("📦 Returning \(categories.count) categories")
//            completion(categories)
//        }
//    }
//    
//    // MARK: - 单位管理
//    func getUnits(completion: @escaping ([UnitModel]) -> Void) {
//        print("📦 getUnits called")
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            guard let self = self else { return }
//            let units = self.mockDataService.getUnits()
//            print("📦 Returning \(units.count) units")
//            completion(units)
//        }
//    }
//    
//    // MARK: - 提醒规则
//    func getReminderRules(completion: @escaping ([ReminderRuleModel]) -> Void) {
//        print("📦 getReminderRules called")
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            guard let self = self else { return }
//            
//            // 从 MockDataService 获取数据后转换为 ReminderRuleModel
//            // 这里可以扩展 MockDataService 来提供提醒规则数据
//            let rules = [
//                ReminderRuleModel.example(),
//                {
//                    let r = ReminderRuleModel()
//                    r.id = "2"
//                    r.name = "提前1天"
//                    r.daysBefore = 1
//                    r.desc = "过期前1天提醒"
//                    return r
//                }(),
//                {
//                    let r = ReminderRuleModel()
//                    r.id = "3"
//                    r.name = "提前7天"
//                    r.daysBefore = 7
//                    r.desc = "过期前7天提醒"
//                    return r
//                }(),
//                {
//                    let r = ReminderRuleModel()
//                    r.id = "4"
//                    r.name = "不提醒"
//                    r.daysBefore = nil
//                    r.desc = "不设置提醒"
//                    return r
//                }()
//            ]
//            
//            print("📦 Returning \(rules.count) rules")
//            completion(rules)
//        }
//    }
//    
//    // MARK: - 物品管理
//    func getItems(page: Int = 1,
//                  categoryId: String? = nil,
//                  keyword: String? = nil,
//                  completion: @escaping (Result<ItemsListResponse, Error>) -> Void) {
//        
//        print("📦 getItems called, page: \(page), categoryId: \(categoryId ?? "nil"), keyword: \(keyword ?? "nil")")
//        
//        // 模拟网络请求延迟
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            guard let self = self else { return }
//            
//            // 从 MockDataService 获取所有物品
//            var items = self.mockDataService.getItems()
//            
//            // 根据分类筛选
//            if let categoryId = categoryId {
//                items = items.filter { $0.categoryId == categoryId }
//            }
//            
//            // 根据关键词筛选
//            if let keyword = keyword, !keyword.isEmpty {
//                items = items.filter { item in
//                    item.name.localizedCaseInsensitiveContains(keyword) ||
//                    item.remarks?.localizedCaseInsensitiveContains(keyword) == true
//                }
//            }
//            
//            // 模拟分页
//            let limit = 20
//            let startIndex = (page - 1) * limit
//            let endIndex = min(startIndex + limit, items.count)
//            let paginatedItems = Array(items[startIndex..<endIndex])
//            
//            let response = ItemsListResponse()
//            response.items = paginatedItems
//            
//            response.pagination = PaginationModel()
//            response.pagination?.page = page
//            response.pagination?.limit = limit
//            response.pagination?.total = items.count
//            response.pagination?.pages = Int(ceil(Double(items.count) / Double(limit)))
//            
//            print("📦 Returning \(response.items.count) items (total: \(items.count))")
//            completion(.success(response))
//        }
//    }
//    
//    func createItem(_ item: CreateItemRequest,
//                    completion: @escaping (Result<ItemModel, Error>) -> Void) {
//        
//        print("📦 createItem called: \(item.name)")
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            guard let self = self else { return }
//            
//            // 创建新物品
//            let newItem = ItemModel()
//            newItem.id = UUID().uuidString
//            newItem.name = item.name
//            newItem.categoryId = item.categoryId
//            newItem.category = self.mockDataService.getCategory(byId: item.categoryId)
//            newItem.quantity = item.quantity
//            newItem.totalPrice = item.totalPrice
//            newItem.unitId = item.unitId
//            newItem.unit = item.unitId.flatMap { self.mockDataService.getUnit(byId: $0) }
//            newItem.productionDate = item.productionDate
//            newItem.expiryDate = item.expiryDate
//            newItem.remarks = item.remarks
//            newItem.createdAt = Date()
//            newItem.level = 1 // 默认为顶级物品
//            newItem.parentId = nil
//            
//            // 注意：这里需要扩展 MockDataService 来支持动态添加物品
//            // 目前 MockDataService 是只读的，实际项目中应该实现数据持久化
//            
//            print("📦 Created item with id: \(newItem.id)")
//            completion(.success(newItem))
//        }
//    }
//    
//    func updateItem(_ item: ItemModel,
//                    completion: @escaping (Result<ItemModel, Error>) -> Void) {
//        
//        print("📦 updateItem called: \(item.id)")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            guard let self = self else { return }
//            
//            // 注意：这里需要扩展 MockDataService 来支持更新物品
//            // 目前 MockDataService 是只读的，实际项目中应该实现数据更新
//            
//            print("📦 Updated item: \(item.name)")
//            completion(.success(item))
//        }
//    }
//    
//    func deleteItem(id: String,
//                    completion: @escaping (Result<Bool, Error>) -> Void) {
//        
//        print("📦 deleteItem called, id: \(id)")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            guard let self = self else { return }
//            
//            // 注意：这里需要扩展 MockDataService 来支持删除物品
//            // 目前 MockDataService 是只读的，实际项目中应该实现数据删除
//            
//            print("📦 Deleted item: \(id)")
//            completion(.success(true))
//        }
//    }
//    
//    func getItem(id: String, completion: @escaping (Result<ItemModel, Error>) -> Void) {
//        print("📦 getItem called, id: \(id)")
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            guard let self = self else { return }
//            
//            if let item = self.mockDataService.getItem(byId: id) {
//                print("📦 Returning item: \(item.name)")
//                completion(.success(item))
//            } else {
//                let error = NSError(domain: "ItemDataService",
//                                   code: 404,
//                                   userInfo: [NSLocalizedDescriptionKey: "Item not found"])
//                print("❌ Item not found with id: \(id)")
//                completion(.failure(error))
//            }
//        }
//    }
//}
//
//// MARK: - 扩展：过期物品相关方法
//extension ItemDataService {
//    
//    /// 获取指定日期过期的物品
//    func getExpiredItems(for date: Date,
//                         completion: @escaping (Result<[ItemModel], Error>) -> Void) {
//        
//        print("📦 getExpiredItems called for date: \(date)")
//        
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: date)
//        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
//            completion(.success([]))
//            return
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            guard let self = self else { return }
//            
//            let allItems = self.mockDataService.getItems()
//            let expiredItems = allItems.filter { item in
//                guard let expiryDate = item.expiryDate else { return false }
//                return expiryDate >= startOfDay && expiryDate < endOfDay
//            }
//            
//            print("📦 Found \(expiredItems.count) expired items for date \(date)")
//            completion(.success(expiredItems))
//        }
//    }
//    
//    /// 获取即将过期的物品（指定天数内）
//    func getUpcomingExpiredItems(days: Int = 7,
//                                 completion: @escaping (Result<[ItemModel], Error>) -> Void) {
//        
//        print("📦 getUpcomingExpiredItems called for next \(days) days")
//        
//        let calendar = Calendar.current
//        let now = Date()
//        let endDate = calendar.date(byAdding: .day, value: days, to: now) ?? now
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            guard let self = self else { return }
//            
//            let allItems = self.mockDataService.getItems()
//            let upcomingItems = allItems.filter { item in
//                guard let expiryDate = item.expiryDate else { return false }
//                return expiryDate >= now && expiryDate <= endDate
//            }
//            
//            let sortedItems = upcomingItems.sorted {
//                ($0.expiryDate ?? Date.distantFuture) < ($1.expiryDate ?? Date.distantFuture)
//            }
//            
//            print("📦 Found \(sortedItems.count) upcoming expired items")
//            completion(.success(sortedItems))
//        }
//    }
//    
//    /// 获取已过期的物品
//    func getExpiredItems(completion: @escaping (Result<[ItemModel], Error>) -> Void) {
//        
//        print("📦 getExpiredItems called (all expired)")
//        
//        let now = Date()
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            guard let self = self else { return }
//            
//            let allItems = self.mockDataService.getItems()
//            let expiredItems = allItems.filter { item in
//                guard let expiryDate = item.expiryDate else { return false }
//                return expiryDate < now
//            }
//            
//            let sortedItems = expiredItems.sorted {
//                ($0.expiryDate ?? Date.distantPast) > ($1.expiryDate ?? Date.distantPast)
//            }
//            
//            print("📦 Found \(sortedItems.count) expired items")
//            completion(.success(sortedItems))
//        }
//    }
//    
//    /// 获取指定日期范围的过期物品
//    func getExpiredItems(from startDate: Date,
//                         to endDate: Date,
//                         completion: @escaping (Result<[ItemModel], Error>) -> Void) {
//        
//        print("📦 getExpiredItems called from \(startDate) to \(endDate)")
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            guard let self = self else { return }
//            
//            let allItems = self.mockDataService.getItems()
//            let expiredItems = allItems.filter { item in
//                guard let expiryDate = item.expiryDate else { return false }
//                return expiryDate >= startDate && expiryDate <= endDate
//            }
//            
//            print("📦 Found \(expiredItems.count) expired items in date range")
//            completion(.success(expiredItems))
//        }
//    }
//    
//    /// 按月份分组获取过期物品
//    func getExpiredItemsGroupedByDay(forYear year: Int,
//                                      month: Int,
//                                      completion: @escaping (Result<[Int: [ItemModel]], Error>) -> Void) {
//        
//        print("📦 getExpiredItemsGroupedByDay called for \(year)-\(month)")
//        
//        var components = DateComponents()
//        components.year = year
//        components.month = month
//        components.day = 1
//        
//        let calendar = Calendar.current
//        guard let startOfMonth = calendar.date(from: components),
//              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
//            completion(.success([:]))
//            return
//        }
//        
//        let endOfDay = calendar.date(byAdding: .day, value: 1, to: endOfMonth) ?? endOfMonth
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            guard let self = self else { return }
//            
//            let allItems = self.mockDataService.getItems()
//            let monthItems = allItems.filter { item in
//                guard let expiryDate = item.expiryDate else { return false }
//                return expiryDate >= startOfMonth && expiryDate < endOfDay
//            }
//            
//            var groupedItems: [Int: [ItemModel]] = [:]
//            
//            for item in monthItems {
//                guard let expiryDate = item.expiryDate else { continue }
//                let day = calendar.component(.day, from: expiryDate)
//                
//                if groupedItems[day] == nil {
//                    groupedItems[day] = []
//                }
//                groupedItems[day]?.append(item)
//            }
//            
//            print("📦 Found items in \(groupedItems.count) days of month \(month)")
//            completion(.success(groupedItems))
//        }
//    }
//    
//    /// 获取过期物品统计信息
//    func getExpiredItemsStatistics(completion: @escaping (Result<ExpiredItemsStatistics, Error>) -> Void) {
//        
//        print("📦 getExpiredItemsStatistics called")
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            guard let self = self else { return }
//            
//            let allItems = self.mockDataService.getItems()
//            let now = Date()
//            let calendar = Calendar.current
//            
//            var statistics = ExpiredItemsStatistics()
//            
//            for item in allItems {
//                guard let expiryDate = item.expiryDate else { continue }
//                
//                let daysUntilExpire = calendar.dateComponents([.day], from: now, to: expiryDate).day ?? 0
//                
//                if daysUntilExpire < 0 {
//                    statistics.expiredCount += 1
//                    statistics.expiredItems.append(item)
//                } else if daysUntilExpire <= 3 {
//                    statistics.soonExpiredCount += 1
//                    statistics.soonExpiredItems.append(item)
//                } else if daysUntilExpire <= 7 {
//                    statistics.weekExpiredCount += 1
//                }
//                
//                let categoryId = item.categoryId
//                statistics.categoryCount[categoryId, default: 0] += 1
//            }
//            
//            print("📦 Statistics: expired=\(statistics.expiredCount), soon=\(statistics.soonExpiredCount)")
//            completion(.success(statistics))
//        }
//    }
//}
//
//// MARK: - 统计信息模型
//struct ExpiredItemsStatistics {
//    var expiredCount: Int = 0
//    var soonExpiredCount: Int = 0
//    var weekExpiredCount: Int = 0
//    var expiredItems: [ItemModel] = []
//    var soonExpiredItems: [ItemModel] = []
//    var categoryCount: [String: Int] = [:]
//    
//    var totalExpiringItems: Int {
//        return expiredCount + soonExpiredCount
//    }
//}

//
//  ItemDataService.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation

class ItemDataService {
    
    static let shared = ItemDataService()
    private let mockDataService = MockDataService.shared
    
    private init() {
        print("✅ ItemDataService initialized (Backend: MockDataService)")
    }
    
    // MARK: - 分类管理
    func getCategories(completion: @escaping ([CategoryModel]) -> Void) {
        print("📦 getCategories called")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            let categories = self.mockDataService.getCategories()
            print("📦 Returning \(categories.count) categories")
            completion(categories)
        }
    }
    
    // MARK: - 单位管理
    func getUnits(completion: @escaping ([UnitModel]) -> Void) {
        print("📦 getUnits called")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            let units = self.mockDataService.getUnits()
            print("📦 Returning \(units.count) units")
            completion(units)
        }
    }
    
    // MARK: - 提醒规则
    func getReminderRules(completion: @escaping ([ReminderRuleModel]) -> Void) {
        print("📦 getReminderRules called")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
        
        print("📦 getItems called, page: \(page), categoryId: \(categoryId ?? "nil"), keyword: \(keyword ?? "nil")")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // 从 MockDataService 获取所有物品
            var items = self.mockDataService.getItems()
            
            // 根据分类筛选
            if let categoryId = categoryId {
                items = items.filter { $0.categoryId == categoryId }
            }
            
            // 根据关键词筛选
            if let keyword = keyword, !keyword.isEmpty {
                items = items.filter { item in
                    item.name.localizedCaseInsensitiveContains(keyword) ||
                    item.remarks?.localizedCaseInsensitiveContains(keyword) == true
                }
            }
            
            // 模拟分页
            let limit = 20
            let startIndex = (page - 1) * limit
            let endIndex = min(startIndex + limit, items.count)
            let paginatedItems = startIndex < items.count ? Array(items[startIndex..<endIndex]) : []
            
            let response = ItemsListResponse()
            response.items = paginatedItems
            
            response.pagination = PaginationModel()
            response.pagination?.page = page
            response.pagination?.limit = limit
            response.pagination?.total = items.count
            response.pagination?.pages = Int(ceil(Double(items.count) / Double(limit)))
            
            print("📦 Returning \(response.items.count) items (total: \(items.count))")
            completion(.success(response))
        }
    }
    
    func createItem(_ item: CreateItemRequest,
                    completion: @escaping (Result<ItemModel, Error>) -> Void) {
        
        print("📦 createItem called: \(item.name)")
        
        // 验证日期信息
        let validation = item.validateDates()
        if !validation.isValid {
            let error = NSError(domain: "ItemDataService",
                               code: 400,
                               userInfo: [NSLocalizedDescriptionKey: validation.message ?? "日期信息不完整"])
            print("❌ \(validation.message ?? "日期信息不完整")")
            completion(.failure(error))
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // 创建新物品
            let newItem = ItemModel()
            newItem.id = UUID().uuidString
            newItem.name = item.name
            newItem.categoryId = item.categoryId
            newItem.category = self.mockDataService.getCategory(byId: item.categoryId)
            newItem.quantity = item.quantity
            newItem.totalPrice = item.totalPrice
            newItem.unitId = item.unitId
            newItem.unit = item.unitId.flatMap { self.mockDataService.getUnit(byId: $0) }
            newItem.remarks = item.remarks
            newItem.level = item.level
            newItem.parentId = item.parentId
            newItem.createdAt = Date()
            
            // 智能处理日期信息
            if let expiryDate = item.expiryDate {
                // 用户直接填写了过期日期
                newItem.expiryDate = expiryDate
                newItem.productionDate = item.productionDate
                newItem.shelfLife = item.shelfLife
            } else if let productionDate = item.productionDate, let shelfLife = item.shelfLife {
                // 用户填写了生产日期和保质期，自动计算过期日期
                newItem.productionDate = productionDate
                newItem.shelfLife = shelfLife
                newItem.calculateExpiryDate()
            } else {
                // 无过期信息
                newItem.productionDate = item.productionDate
                newItem.shelfLife = item.shelfLife
                newItem.expiryDate = nil
            }
            
            // 保存到 MockDataService
            let success = self.mockDataService.addItem(newItem)
            
            if success {
                print("📦 Created item with id: \(newItem.id)")
                if let expiryDate = newItem.expiryDate {
                    print("📦 Expiry date: \(expiryDate)")
//                    print("📦 Remaining days: \(newItem.remainingDays ?? 0)")
                } else if let shelfLife = newItem.shelfLife {
                    print("📦 Shelf life: \(shelfLife) days")
                } else {
                    print("📦 No expiry information")
                }
                completion(.success(newItem))
            } else {
                let error = NSError(domain: "ItemDataService",
                                   code: 500,
                                   userInfo: [NSLocalizedDescriptionKey: "Failed to create item"])
                completion(.failure(error))
            }
        }
    }
    
    func updateItem(_ item: ItemModel,
                    completion: @escaping (Result<ItemModel, Error>) -> Void) {
        
        print("📦 updateItem called: \(item.id)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // 确保过期日期是最新的（如果有生产日期和保质期）
            if let productionDate = item.productionDate, let shelfLife = item.shelfLife {
                let calculatedExpiry = Calendar.current.date(byAdding: .day, value: shelfLife, to: productionDate)
                if item.expiryDate != calculatedExpiry {
                    print("⚠️ Expiry date updated based on production date and shelf life")
                    item.expiryDate = calculatedExpiry
                }
            }
            
            // 更新到 MockDataService
            let success = self.mockDataService.updateItem(item)
            
            if success {
                print("📦 Updated item: \(item.name)")
                completion(.success(item))
            } else {
                let error = NSError(domain: "ItemDataService",
                                   code: 404,
                                   userInfo: [NSLocalizedDescriptionKey: "Item not found"])
                completion(.failure(error))
            }
        }
    }
    
    func deleteItem(id: String,
                    completion: @escaping (Result<Bool, Error>) -> Void) {
        
        print("📦 deleteItem called, id: \(id)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // 从 MockDataService 删除
            let success = self.mockDataService.deleteItem(id: id)
            
            if success {
                print("📦 Deleted item: \(id)")
                completion(.success(true))
            } else {
                let error = NSError(domain: "ItemDataService",
                                   code: 404,
                                   userInfo: [NSLocalizedDescriptionKey: "Item not found"])
                completion(.failure(error))
            }
        }
    }
    
    func getItem(id: String, completion: @escaping (Result<ItemModel, Error>) -> Void) {
        print("📦 getItem called, id: \(id)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            if let item = self.mockDataService.getItem(byId: id) {
                print("📦 Returning item: \(item.name)")
                completion(.success(item))
            } else {
                let error = NSError(domain: "ItemDataService",
                                   code: 404,
                                   userInfo: [NSLocalizedDescriptionKey: "Item not found"])
                print("❌ Item not found with id: \(id)")
                completion(.failure(error))
            }
        }
    }
}

// MARK: - 扩展：过期物品相关方法
extension ItemDataService {
    
    /// 获取指定日期过期的物品
    func getExpiredItems(for date: Date,
                         completion: @escaping (Result<[ItemModel], Error>) -> Void) {
        
        print("📦 getExpiredItems called for date: \(date)")
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            completion(.success([]))
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let allItems = self.mockDataService.getItems()
            let expiredItems = allItems.filter { item in
                guard let expiryDate = item.expiryDate else { return false }
                return expiryDate >= startOfDay && expiryDate < endOfDay
            }
            
            print("📦 Found \(expiredItems.count) expired items for date \(date)")
            completion(.success(expiredItems))
        }
    }
    
    /// 获取即将过期的物品（指定天数内）
    func getUpcomingExpiredItems(days: Int = 7,
                                 completion: @escaping (Result<[ItemModel], Error>) -> Void) {
        
        print("📦 getUpcomingExpiredItems called for next \(days) days")
        
        let calendar = Calendar.current
        let now = Date()
        let endDate = calendar.date(byAdding: .day, value: days, to: now) ?? now
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let allItems = self.mockDataService.getItems()
            let upcomingItems = allItems.filter { item in
                guard let expiryDate = item.expiryDate else { return false }
                return expiryDate >= now && expiryDate <= endDate
            }
            
            let sortedItems = upcomingItems.sorted {
                ($0.expiryDate ?? Date.distantFuture) < ($1.expiryDate ?? Date.distantFuture)
            }
            
            print("📦 Found \(sortedItems.count) upcoming expired items")
            completion(.success(sortedItems))
        }
    }
    
    /// 获取已过期的物品
    func getExpiredItems(completion: @escaping (Result<[ItemModel], Error>) -> Void) {
        
        print("📦 getExpiredItems called (all expired)")
        
        let now = Date()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let allItems = self.mockDataService.getItems()
            let expiredItems = allItems.filter { item in
                guard let expiryDate = item.expiryDate else { return false }
                return expiryDate < now
            }
            
            let sortedItems = expiredItems.sorted {
                ($0.expiryDate ?? Date.distantPast) > ($1.expiryDate ?? Date.distantPast)
            }
            
            print("📦 Found \(sortedItems.count) expired items")
            completion(.success(sortedItems))
        }
    }
    
    /// 获取指定日期范围的过期物品
    func getExpiredItems(from startDate: Date,
                         to endDate: Date,
                         completion: @escaping (Result<[ItemModel], Error>) -> Void) {
        
        print("📦 getExpiredItems called from \(startDate) to \(endDate)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let allItems = self.mockDataService.getItems()
            let expiredItems = allItems.filter { item in
                guard let expiryDate = item.expiryDate else { return false }
                return expiryDate >= startDate && expiryDate <= endDate
            }
            
            print("📦 Found \(expiredItems.count) expired items in date range")
            completion(.success(expiredItems))
        }
    }
    
    /// 按月份分组获取过期物品
    func getExpiredItemsGroupedByDay(forYear year: Int,
                                      month: Int,
                                      completion: @escaping (Result<[Int: [ItemModel]], Error>) -> Void) {
        
        print("📦 getExpiredItemsGroupedByDay called for \(year)-\(month)")
        
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
            
            let allItems = self.mockDataService.getItems()
            let monthItems = allItems.filter { item in
                guard let expiryDate = item.expiryDate else { return false }
                return expiryDate >= startOfMonth && expiryDate < endOfDay
            }
            
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
        }
    }
    
    /// 获取过期物品统计信息
    func getExpiredItemsStatistics(completion: @escaping (Result<ExpiredItemsStatistics, Error>) -> Void) {
        
        print("📦 getExpiredItemsStatistics called")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let allItems = self.mockDataService.getItems()
            let now = Date()
            let calendar = Calendar.current
            
            var statistics = ExpiredItemsStatistics()
            
            for item in allItems {
                guard let expiryDate = item.expiryDate else { continue }
                
                let daysUntilExpire = calendar.dateComponents([.day], from: now, to: expiryDate).day ?? 0
                
                if daysUntilExpire < 0 {
                    statistics.expiredCount += 1
                    statistics.expiredItems.append(item)
                } else if daysUntilExpire <= 3 {
                    statistics.soonExpiredCount += 1
                    statistics.soonExpiredItems.append(item)
                } else if daysUntilExpire <= 7 {
                    statistics.weekExpiredCount += 1
                }
                
                let categoryId = item.categoryId
                statistics.categoryCount[categoryId, default: 0] += 1
            }
            
            print("📦 Statistics: expired=\(statistics.expiredCount), soon=\(statistics.soonExpiredCount)")
            completion(.success(statistics))
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
