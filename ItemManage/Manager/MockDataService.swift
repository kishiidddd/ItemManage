////
////  MockDataService.swift
////  ItemManage
////
//
//import Foundation
//
//// MARK: - 模拟数据服务
//class MockDataService {
//    
//    // 单例模式
//    static let shared = MockDataService()
//    private init() {}
//    
//    // MARK: - 分类数据
//    private let mockCategories: [CategoryModel] = [
//        {
//            let category = CategoryModel()
//            category.id = "1"
//            category.name = "水果"
//            category.icon = "🍎"
//            category.color = "#FF6B6B"
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "2"
//            category.name = "饮品"
//            category.icon = "🥤"
//            category.color = "#4ECDC4"
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "3"
//            category.name = "零食"
//            category.icon = "🍿"
//            category.color = "#FFE66D"
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "4"
//            category.name = "日用品"
//            category.icon = "🧴"
//            category.color = "#95E1D3"
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "5"
//            category.name = "蔬菜"
//            category.icon = "🥬"
//            category.color = "#A8E6CF"
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "location"
//            category.name = "位置"
//            category.icon = "📍"
//            category.color = "#FFD93D"
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "clothing"
//            category.name = "衣物"
//            category.icon = "👕"
//            category.color = "#C7CEE6"
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "food"
//            category.name = "食品"
//            category.icon = "🍱"
//            category.color = "#B5EAD7"
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "shoes"
//            category.name = "鞋类"
//            category.icon = "👟"
//            category.color = "#F9D5E5"
//            return category
//        }()
//    ]
//    
//    // MARK: - 单位数据
//    private let mockUnits: [UnitModel] = [
//        {
//            let unit = UnitModel()
//            unit.id = "1"
//            unit.name = "个"
//            unit.abbreviation = "个"
//            return unit
//        }(),
//        {
//            let unit = UnitModel()
//            unit.id = "2"
//            unit.name = "盒"
//            unit.abbreviation = "盒"
//            return unit
//        }(),
//        {
//            let unit = UnitModel()
//            unit.id = "3"
//            unit.name = "袋"
//            unit.abbreviation = "袋"
//            return unit
//        }(),
//        {
//            let unit = UnitModel()
//            unit.id = "4"
//            unit.name = "瓶"
//            unit.abbreviation = "瓶"
//            return unit
//        }(),
//        {
//            let unit = UnitModel()
//            unit.id = "5"
//            unit.name = "千克"
//            unit.abbreviation = "kg"
//            return unit
//        }(),
//        {
//            let unit = UnitModel()
//            unit.id = "6"
//            unit.name = "件"
//            unit.abbreviation = "件"
//            return unit
//        }()
//    ]
//    
//    // MARK: - 物品数据
//    private lazy var mockItems: [ItemModel] = {
//        var items: [ItemModel] = []
//        
//        let calendar = Calendar.current
//        let now = Date()
//        
//        // ========== 位置类物品（无过期日期）==========
//        
//        // 第一组：卧室
//        let wardrobe = createLocationItem(
//            id: "1",
//            name: "衣柜",
//            remarks: "主卧大衣柜",
//            level: 1,
//            parentId: nil
//        )
//        items.append(wardrobe)
//        
//        let pinkBox = createLocationItem(
//            id: "1-1",
//            name: "粉色箱子",
//            remarks: "放在衣柜上层",
//            level: 2,
//            parentId: "1"
//        )
//        items.append(pinkBox)
//        
//        let drawer = createLocationItem(
//            id: "1-2",
//            name: "抽屉",
//            remarks: "衣柜下层抽屉",
//            level: 2,
//            parentId: "1"
//        )
//        items.append(drawer)
//        
//        // 第二组：厨房
//        let fridge = createLocationItem(
//            id: "2",
//            name: "冰箱",
//            remarks: "双开门冰箱",
//            level: 1,
//            parentId: nil
//        )
//        items.append(fridge)
//        
//        let fridgeUpper = createLocationItem(
//            id: "2-1",
//            name: "冷藏层",
//            remarks: "上层冷藏",
//            level: 2,
//            parentId: "2"
//        )
//        items.append(fridgeUpper)
//        
//        let fridgeFreezer = createLocationItem(
//            id: "2-2",
//            name: "冷冻层",
//            remarks: "下层冷冻",
//            level: 2,
//            parentId: "2"
//        )
//        items.append(fridgeFreezer)
//        
//        let cabinet = createLocationItem(
//            id: "3",
//            name: "橱柜",
//            remarks: "厨房储物柜",
//            level: 1,
//            parentId: nil
//        )
//        items.append(cabinet)
//        
//        let upperCabinet = createLocationItem(
//            id: "3-1",
//            name: "上层橱柜",
//            remarks: "高处储物",
//            level: 2,
//            parentId: "3"
//        )
//        items.append(upperCabinet)
//        
//        // 第三组：其他位置
//        let shoeCabinet = createLocationItem(
//            id: "4",
//            name: "鞋柜",
//            remarks: "玄关鞋柜",
//            level: 1,
//            parentId: nil
//        )
//        items.append(shoeCabinet)
//        
//        // ========== 物品类（有过期日期）==========
//        
//        // 1. 鸡蛋 - 使用生产日期 + 保质期（还有12天过期）
//        let eggsProductionDate = calendar.date(byAdding: .day, value: -2, to: now)!
//        let eggs = createFoodItem(
//            id: "5",
//            name: "鸡蛋",
//            categoryId: "food",
//            quantity: 12,
//            totalPrice: 18.0,
//            unitId: "1",
//            productionDate: eggsProductionDate,
//            shelfLife: 14,
//            expiryDate: nil,
//            locationId: "2-1",
//            remarks: "新鲜鸡蛋，保质期14天"
//        )
//        items.append(eggs)
//        
//        // 2. 牛奶 - 直接填写过期日期（3天后过期）
//        let milkExpiryDate = calendar.date(byAdding: .day, value: 3, to: now)!
//        let milk = createFoodItem(
//            id: "6",
//            name: "鲜牛奶",
//            categoryId: "2",
//            quantity: 2,
//            totalPrice: 32.0,
//            unitId: "4",
//            productionDate: nil,
//            shelfLife: nil,
//            expiryDate: milkExpiryDate,
//            locationId: "2-1",
//            remarks: "巴氏杀菌乳，需冷藏"
//        )
//        items.append(milk)
//        
//        // 3. 面包 - 直接填写过期日期（1天后过期）
//        let breadExpiryDate = calendar.date(byAdding: .day, value: 1, to: now)!
//        let bread = createFoodItem(
//            id: "7",
//            name: "全麦面包",
//            categoryId: "3",
//            quantity: 1,
//            totalPrice: 15.0,
//            unitId: "3",
//            productionDate: nil,
//            shelfLife: nil,
//            expiryDate: breadExpiryDate,
//            locationId: "3-1",
//            remarks: "全麦吐司"
//        )
//        items.append(bread)
//        
//        // 4. 酸奶 - 已过期5天
//        let yogurtExpiryDate = calendar.date(byAdding: .day, value: -5, to: now)!
//        let yogurt = createFoodItem(
//            id: "8",
//            name: "原味酸奶",
//            categoryId: "2",
//            quantity: 3,
//            totalPrice: 24.0,
//            unitId: "2",
//            productionDate: nil,
//            shelfLife: nil,
//            expiryDate: yogurtExpiryDate,
//            locationId: "2-1",
//            remarks: "已过期，请勿食用"
//        )
//        items.append(yogurt)
//        
//        // 5. 苹果 - 还有7天过期
//        let appleExpiryDate = calendar.date(byAdding: .day, value: 7, to: now)!
//        let apple = createFoodItem(
//            id: "9",
//            name: "红富士苹果",
//            categoryId: "1",
//            quantity: 5,
//            totalPrice: 25.0,
//            unitId: "1",
//            productionDate: nil,
//            shelfLife: nil,
//            expiryDate: appleExpiryDate,
//            locationId: "1-1",
//            remarks: "新鲜水果"
//        )
//        items.append(apple)
//        
//        // 6. 方便面 - 使用生产日期 + 保质期（还有150天过期）
//        let noodlesProductionDate = calendar.date(byAdding: .day, value: -30, to: now)!
//        let noodles = createFoodItem(
//            id: "10",
//            name: "方便面",
//            categoryId: "3",
//            quantity: 5,
//            totalPrice: 25.0,
//            unitId: "3",
//            productionDate: noodlesProductionDate,
//            shelfLife: 180,
//            expiryDate: nil,
//            locationId: "3-1",
//            remarks: "保质期6个月"
//        )
//        items.append(noodles)
//        
//        // 7. 可乐 - 还有30天过期
//        let colaExpiryDate = calendar.date(byAdding: .day, value: 30, to: now)!
//        let cola = createFoodItem(
//            id: "11",
//            name: "可乐",
//            categoryId: "2",
//            quantity: 6,
//            totalPrice: 18.0,
//            unitId: "4",
//            productionDate: nil,
//            shelfLife: nil,
//            expiryDate: colaExpiryDate,
//            locationId: "2-1",
//            remarks: "碳酸饮料"
//        )
//        items.append(cola)
//        
//        // 8. 香蕉 - 还有4天过期
//        let bananaExpiryDate = calendar.date(byAdding: .day, value: 4, to: now)!
//        let banana = createFoodItem(
//            id: "12",
//            name: "香蕉",
//            categoryId: "1",
//            quantity: 3,
//            totalPrice: 12.0,
//            unitId: "1",
//            productionDate: nil,
//            shelfLife: nil,
//            expiryDate: bananaExpiryDate,
//            locationId: "1-1",
//            remarks: "热带水果"
//        )
//        items.append(banana)
//        
//        // 9. 速冻水饺 - 使用生产日期 + 保质期（还有75天过期）
//        let dumplingsProductionDate = calendar.date(byAdding: .day, value: -15, to: now)!
//        let dumplings = createFoodItem(
//            id: "13",
//            name: "速冻水饺",
//            categoryId: "food",
//            quantity: 2,
//            totalPrice: 30.0,
//            unitId: "2",
//            productionDate: dumplingsProductionDate,
//            shelfLife: 90,
//            expiryDate: nil,
//            locationId: "2-2",
//            remarks: "猪肉白菜馅"
//        )
//        items.append(dumplings)
//        
//        // 10. 番茄 - 还有2天过期
//        let tomatoExpiryDate = calendar.date(byAdding: .day, value: 2, to: now)!
//        let tomato = createFoodItem(
//            id: "14",
//            name: "番茄",
//            categoryId: "5",
//            quantity: 4,
//            totalPrice: 10.0,
//            unitId: "1",
//            productionDate: nil,
//            shelfLife: nil,
//            expiryDate: tomatoExpiryDate,
//            locationId: "2-1",
//            remarks: "新鲜蔬菜"
//        )
//        items.append(tomato)
//        
//        // ========== 衣物类物品（无过期日期）==========
//        
//        // 白色短袖
//        let whiteShirt = createClothingItem(
//            id: "15",
//            name: "白色短袖",
//            categoryId: "clothing",
//            quantity: 3,
//            totalPrice: 120.0,
//            unitId: "6",
//            locationId: "1-1",
//            remarks: "纯棉白色T恤"
//        )
//        items.append(whiteShirt)
//        
//        // 袜子
//        let socks = createClothingItem(
//            id: "16",
//            name: "袜子",
//            categoryId: "clothing",
//            quantity: 10,
//            totalPrice: 50.0,
//            unitId: "6",
//            locationId: "1-2",
//            remarks: "白色运动袜"
//        )
//        items.append(socks)
//        
//        // 运动鞋
//        let sportsShoes = createClothingItem(
//            id: "17",
//            name: "运动鞋",
//            categoryId: "shoes",
//            quantity: 2,
//            totalPrice: 500.0,
//            unitId: "6",
//            locationId: "4",
//            remarks: "跑步鞋"
//        )
//        items.append(sportsShoes)
//        
//        // ========== 日用品类（无过期日期）==========
//        
//        // 洗衣液
//        let laundry = createDailyItem(
//            id: "18",
//            name: "洗衣液",
//            categoryId: "4",
//            quantity: 2,
//            totalPrice: 45.0,
//            unitId: "4",
//            locationId: "3",
//            remarks: "3kg装"
//        )
//        items.append(laundry)
//        
//        // 纸巾
//        let tissue = createDailyItem(
//            id: "19",
//            name: "纸巾",
//            categoryId: "4",
//            quantity: 5,
//            totalPrice: 20.0,
//            unitId: "3",
//            locationId: "3-1",
//            remarks: "抽纸"
//        )
//        items.append(tissue)
//        
//        // 建立父子关系
//        for item in items {
//            if let parentId = item.parentId {
//                item.parent = items.first { $0.id == parentId }
//            }
//        }
//        
//        // 建立 children 数组
//        for item in items where item.parentId != nil {
//            if let parent = items.first(where: { $0.id == item.parentId }) {
//                if parent.children == nil {
//                    parent.children = []
//                }
//                parent.children?.append(item)
//            }
//        }
//        
//        return items
//    }()
//    
//    // MARK: - 辅助方法：创建位置物品
//    private func createLocationItem(
//        id: String,
//        name: String,
//        remarks: String? = nil,
//        level: Int,
//        parentId: String?
//    ) -> ItemModel {
//        let item = ItemModel()
//        item.id = id
//        item.name = name
//        item.categoryId = "location"
//        item.category = getCategory(byId: "location")
//        item.quantity = 0
//        item.totalPrice = nil
//        item.unitId = nil
//        item.level = level
//        item.parentId = parentId
//        item.remarks = remarks
//        item.createdAt = Date()
//        
//        return item
//    }
//    
//    // MARK: - 辅助方法：创建食品物品
//    private func createFoodItem(
//        id: String,
//        name: String,
//        categoryId: String,
//        quantity: Int,
//        totalPrice: Double?,
//        unitId: String,
//        productionDate: Date?,
//        shelfLife: Int?,
//        expiryDate: Date?,
//        locationId: String?,
//        remarks: String?
//    ) -> ItemModel {
//        let item = ItemModel()
//        item.id = id
//        item.name = name
//        item.categoryId = categoryId
//        item.category = getCategory(byId: categoryId)
//        item.quantity = quantity
//        item.totalPrice = totalPrice
//        item.unitId = unitId
//        item.unit = getUnit(byId: unitId)
//        item.level = 3
//        item.parentId = locationId
//        item.remarks = remarks
//        item.createdAt = Date()
//        
//        // 处理日期
//        if let expiryDate = expiryDate {
//            // 直接设置过期日期
//            item.expiryDate = expiryDate
//        } else if let productionDate = productionDate, let shelfLife = shelfLife {
//            // 设置生产日期和保质期，自动计算过期日期
//            item.productionDate = productionDate
//            item.shelfLife = shelfLife
//            item.calculateExpiryDate()
//        }
//        
//        return item
//    }
//    
//    // MARK: - 辅助方法：创建衣物物品
//    private func createClothingItem(
//        id: String,
//        name: String,
//        categoryId: String,
//        quantity: Int,
//        totalPrice: Double?,
//        unitId: String,
//        locationId: String?,
//        remarks: String?
//    ) -> ItemModel {
//        let item = ItemModel()
//        item.id = id
//        item.name = name
//        item.categoryId = categoryId
//        item.category = getCategory(byId: categoryId)
//        item.quantity = quantity
//        item.totalPrice = totalPrice
//        item.unitId = unitId
//        item.unit = getUnit(byId: unitId)
//        item.level = 3
//        item.parentId = locationId
//        item.remarks = remarks
//        item.createdAt = Date()
//        
//        // 衣物类没有过期日期
//        
//        return item
//    }
//    
//    // MARK: - 辅助方法：创建日用品物品
//    private func createDailyItem(
//        id: String,
//        name: String,
//        categoryId: String,
//        quantity: Int,
//        totalPrice: Double?,
//        unitId: String,
//        locationId: String?,
//        remarks: String?
//    ) -> ItemModel {
//        let item = ItemModel()
//        item.id = id
//        item.name = name
//        item.categoryId = categoryId
//        item.category = getCategory(byId: categoryId)
//        item.quantity = quantity
//        item.totalPrice = totalPrice
//        item.unitId = unitId
//        item.unit = getUnit(byId: unitId)
//        item.level = 3
//        item.parentId = locationId
//        item.remarks = remarks
//        item.createdAt = Date()
//        
//        // 日用品类没有过期日期
//        
//        return item
//    }
//    
//    // MARK: - 公开方法
//    
//    /// 获取所有分类
//    func getCategories() -> [CategoryModel] {
//        return mockCategories
//    }
//    
//    /// 获取所有单位
//    func getUnits() -> [UnitModel] {
//        return mockUnits
//    }
//    
//    /// 获取所有物品
//    func getItems() -> [ItemModel] {
//        return mockItems
//    }
//    
//    /// 根据分类ID获取物品
//    func getItems(byCategoryId categoryId: String) -> [ItemModel] {
//        return mockItems.filter { $0.categoryId == categoryId }
//    }
//    
//    /// 获取最近添加的物品（7天内）
//    func getRecentItems() -> [ItemModel] {
//        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
//        return mockItems.filter { $0.createdAt >= sevenDaysAgo }
//            .sorted { $0.createdAt > $1.createdAt }
//    }
//    
//    /// 根据ID获取物品
//    func getItem(byId id: String) -> ItemModel? {
//        return mockItems.first { $0.id == id }
//    }
//    
//    /// 根据分类ID获取分类
//    func getCategory(byId id: String) -> CategoryModel? {
//        return mockCategories.first { $0.id == id }
//    }
//    
//    /// 根据单位ID获取单位
//    func getUnit(byId id: String) -> UnitModel? {
//        return mockUnits.first { $0.id == id }
//    }
//    
//    /// 获取即将过期的物品（3天内）
//    func getExpiringItems() -> [ItemModel] {
//        let now = Date()
//        let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: now) ?? now
//        return mockItems.filter { item in
//            guard let expiryDate = item.expiryDate else { return false }
//            return expiryDate <= threeDaysLater && expiryDate >= now
//        }
//    }
//    
//    /// 获取已过期的物品
//    func getExpiredItems() -> [ItemModel] {
//        let now = Date()
//        return mockItems.filter { item in
//            guard let expiryDate = item.expiryDate else { return false }
//            return expiryDate < now
//        }
//    }
//    
//    /// 获取所有有过期日期的物品
//    func getItemsWithExpiry() -> [ItemModel] {
//        return mockItems.filter { $0.expiryDate != nil }
//    }
//    
//    /// 获取所有没有过期日期的物品
//    func getItemsWithoutExpiry() -> [ItemModel] {
//        return mockItems.filter { $0.expiryDate == nil }
//    }
//    
//    /// 搜索物品
//    func searchItems(keyword: String) -> [ItemModel] {
//        return mockItems.filter {
//            $0.name.localizedCaseInsensitiveContains(keyword) ||
//            $0.remarks?.localizedCaseInsensitiveContains(keyword) == true
//        }
//    }
//    
//    /// 获取顶级物品（没有父物品）
//    func getTopLevelItems() -> [ItemModel] {
//        return mockItems.filter { $0.parentId == nil }
//    }
//    
//    /// 获取子物品
//    func getChildren(for parentId: String) -> [ItemModel] {
//        return mockItems.filter { $0.parentId == parentId }
//    }
//    
//    /// 获取层级树（以树形结构返回）
//    func getItemTree() -> [ItemModel] {
//        return mockItems.filter { $0.parentId == nil }
//    }
//    
//    /// 获取按过期状态分类的物品
//    func getItemsGroupedByExpiryStatus() -> (expired: [ItemModel], expiringSoon: [ItemModel], valid: [ItemModel], noExpiry: [ItemModel]) {
//        let now = Date()
//        var expired: [ItemModel] = []
//        var expiringSoon: [ItemModel] = []
//        var valid: [ItemModel] = []
//        var noExpiry: [ItemModel] = []
//        
//        for item in mockItems {
//            guard let expiryDate = item.expiryDate else {
//                noExpiry.append(item)
//                continue
//            }
//            
//            if expiryDate < now {
//                expired.append(item)
//            } else if item.isExpiringSoon {
//                expiringSoon.append(item)
//            } else {
//                valid.append(item)
//            }
//        }
//        
//        return (expired, expiringSoon, valid, noExpiry)
//    }
//}

//
//  MockDataService.swift
//  ItemManage
//

import Foundation

// MARK: - 模拟数据服务
class MockDataService {
    
    // 单例模式
    static let shared = MockDataService()
    private init() {
        // 初始化数据
        loadMockData()
    }
    
    // 可变的数据存储
    private var categories: [CategoryModel] = []
    private var units: [UnitModel] = []
    private var items: [ItemModel] = []
    
    // MARK: - 初始化数据
    private func loadMockData() {
        // 加载分类数据
        categories = [
            {
                let category = CategoryModel()
                category.id = "1"
                category.name = "水果"
                category.icon = "🍎"
                category.color = "#FF6B6B"
                return category
            }(),
            {
                let category = CategoryModel()
                category.id = "2"
                category.name = "饮品"
                category.icon = "🥤"
                category.color = "#4ECDC4"
                return category
            }(),
            {
                let category = CategoryModel()
                category.id = "3"
                category.name = "零食"
                category.icon = "🍿"
                category.color = "#FFE66D"
                return category
            }(),
            {
                let category = CategoryModel()
                category.id = "4"
                category.name = "日用品"
                category.icon = "🧴"
                category.color = "#95E1D3"
                return category
            }(),
            {
                let category = CategoryModel()
                category.id = "5"
                category.name = "蔬菜"
                category.icon = "🥬"
                category.color = "#A8E6CF"
                return category
            }(),
            {
                let category = CategoryModel()
                category.id = "location"
                category.name = "位置"
                category.icon = "📍"
                category.color = "#FFD93D"
                return category
            }(),
            {
                let category = CategoryModel()
                category.id = "clothing"
                category.name = "衣物"
                category.icon = "👕"
                category.color = "#C7CEE6"
                return category
            }(),
            {
                let category = CategoryModel()
                category.id = "food"
                category.name = "食品"
                category.icon = "🍱"
                category.color = "#B5EAD7"
                return category
            }(),
            {
                let category = CategoryModel()
                category.id = "shoes"
                category.name = "鞋类"
                category.icon = "👟"
                category.color = "#F9D5E5"
                return category
            }()
        ]
        
        // 加载单位数据
        units = [
            {
                let unit = UnitModel()
                unit.id = "1"
                unit.name = "个"
                unit.abbreviation = "个"
                return unit
            }(),
            {
                let unit = UnitModel()
                unit.id = "2"
                unit.name = "盒"
                unit.abbreviation = "盒"
                return unit
            }(),
            {
                let unit = UnitModel()
                unit.id = "3"
                unit.name = "袋"
                unit.abbreviation = "袋"
                return unit
            }(),
            {
                let unit = UnitModel()
                unit.id = "4"
                unit.name = "瓶"
                unit.abbreviation = "瓶"
                return unit
            }(),
            {
                let unit = UnitModel()
                unit.id = "5"
                unit.name = "千克"
                unit.abbreviation = "kg"
                return unit
            }(),
            {
                let unit = UnitModel()
                unit.id = "6"
                unit.name = "件"
                unit.abbreviation = "件"
                return unit
            }()
        ]
        
        // 加载物品数据
        items = createMockItems()
    }
    
    // MARK: - 创建模拟物品数据
    private func createMockItems() -> [ItemModel] {
        var items: [ItemModel] = []
        
        let calendar = Calendar.current
        let now = Date()
        
        // ========== 位置类物品（无过期日期）==========
        
        // 第一组：卧室
        let wardrobe = createLocationItem(
            id: "1",
            name: "衣柜",
            remarks: "主卧大衣柜",
            level: 1,
            parentId: nil
        )
        items.append(wardrobe)
        
        let pinkBox = createLocationItem(
            id: "1-1",
            name: "粉色箱子",
            remarks: "放在衣柜上层",
            level: 2,
            parentId: "1"
        )
        items.append(pinkBox)
        
        let drawer = createLocationItem(
            id: "1-2",
            name: "抽屉",
            remarks: "衣柜下层抽屉",
            level: 2,
            parentId: "1"
        )
        items.append(drawer)
        
        // 第二组：厨房
        let fridge = createLocationItem(
            id: "2",
            name: "冰箱",
            remarks: "双开门冰箱",
            level: 1,
            parentId: nil
        )
        items.append(fridge)
        
        let fridgeUpper = createLocationItem(
            id: "2-1",
            name: "冷藏层",
            remarks: "上层冷藏",
            level: 2,
            parentId: "2"
        )
        items.append(fridgeUpper)
        
        let fridgeFreezer = createLocationItem(
            id: "2-2",
            name: "冷冻层",
            remarks: "下层冷冻",
            level: 2,
            parentId: "2"
        )
        items.append(fridgeFreezer)
        
        let cabinet = createLocationItem(
            id: "3",
            name: "橱柜",
            remarks: "厨房储物柜",
            level: 1,
            parentId: nil
        )
        items.append(cabinet)
        
        let upperCabinet = createLocationItem(
            id: "3-1",
            name: "上层橱柜",
            remarks: "高处储物",
            level: 2,
            parentId: "3"
        )
        items.append(upperCabinet)
        
        // 第三组：其他位置
        let shoeCabinet = createLocationItem(
            id: "4",
            name: "鞋柜",
            remarks: "玄关鞋柜",
            level: 1,
            parentId: nil
        )
        items.append(shoeCabinet)
        
        // ========== 物品类（有过期日期）==========
        
        // 1. 鸡蛋 - 使用生产日期 + 保质期（还有12天过期）
        let eggsProductionDate = calendar.date(byAdding: .day, value: -2, to: now)!
        let eggs = createFoodItem(
            id: "5",
            name: "鸡蛋",
            categoryId: "food",
            quantity: 12,
            totalPrice: 18.0,
            unitId: "1",
            productionDate: eggsProductionDate,
            shelfLife: 14,
            expiryDate: nil,
            locationId: "2-1",
            remarks: "新鲜鸡蛋，保质期14天"
        )
        items.append(eggs)
        
        // 2. 牛奶 - 直接填写过期日期（3天后过期）
        let milkExpiryDate = calendar.date(byAdding: .day, value: 3, to: now)!
        let milk = createFoodItem(
            id: "6",
            name: "鲜牛奶",
            categoryId: "2",
            quantity: 2,
            totalPrice: 32.0,
            unitId: "4",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: milkExpiryDate,
            locationId: "2-1",
            remarks: "巴氏杀菌乳，需冷藏"
        )
        items.append(milk)
        
        // 3. 面包 - 直接填写过期日期（1天后过期）
        let breadExpiryDate = calendar.date(byAdding: .day, value: 1, to: now)!
        let bread = createFoodItem(
            id: "7",
            name: "全麦面包",
            categoryId: "3",
            quantity: 1,
            totalPrice: 15.0,
            unitId: "3",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: breadExpiryDate,
            locationId: "3-1",
            remarks: "全麦吐司"
        )
        items.append(bread)
        
        // 4. 酸奶 - 已过期5天
        let yogurtExpiryDate = calendar.date(byAdding: .day, value: -5, to: now)!
        let yogurt = createFoodItem(
            id: "8",
            name: "原味酸奶",
            categoryId: "2",
            quantity: 3,
            totalPrice: 24.0,
            unitId: "2",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: yogurtExpiryDate,
            locationId: "2-1",
            remarks: "已过期，请勿食用"
        )
        items.append(yogurt)
        
        // 5. 苹果 - 还有7天过期
        let appleExpiryDate = calendar.date(byAdding: .day, value: 7, to: now)!
        let apple = createFoodItem(
            id: "9",
            name: "红富士苹果",
            categoryId: "1",
            quantity: 5,
            totalPrice: 25.0,
            unitId: "1",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: appleExpiryDate,
            locationId: "1-1",
            remarks: "新鲜水果"
        )
        items.append(apple)
        
        // 6. 方便面 - 使用生产日期 + 保质期（还有150天过期）
        let noodlesProductionDate = calendar.date(byAdding: .day, value: -30, to: now)!
        let noodles = createFoodItem(
            id: "10",
            name: "方便面",
            categoryId: "3",
            quantity: 5,
            totalPrice: 25.0,
            unitId: "3",
            productionDate: noodlesProductionDate,
            shelfLife: 180,
            expiryDate: nil,
            locationId: "3-1",
            remarks: "保质期6个月"
        )
        items.append(noodles)
        
        // 7. 可乐 - 还有30天过期
        let colaExpiryDate = calendar.date(byAdding: .day, value: 30, to: now)!
        let cola = createFoodItem(
            id: "11",
            name: "可乐",
            categoryId: "2",
            quantity: 6,
            totalPrice: 18.0,
            unitId: "4",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: colaExpiryDate,
            locationId: "2-1",
            remarks: "碳酸饮料"
        )
        items.append(cola)
        
        // 8. 香蕉 - 还有4天过期
        let bananaExpiryDate = calendar.date(byAdding: .day, value: 4, to: now)!
        let banana = createFoodItem(
            id: "12",
            name: "香蕉",
            categoryId: "1",
            quantity: 3,
            totalPrice: 12.0,
            unitId: "1",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: bananaExpiryDate,
            locationId: "1-1",
            remarks: "热带水果"
        )
        items.append(banana)
        
        // 9. 速冻水饺 - 使用生产日期 + 保质期（还有75天过期）
        let dumplingsProductionDate = calendar.date(byAdding: .day, value: -15, to: now)!
        let dumplings = createFoodItem(
            id: "13",
            name: "速冻水饺",
            categoryId: "food",
            quantity: 2,
            totalPrice: 30.0,
            unitId: "2",
            productionDate: dumplingsProductionDate,
            shelfLife: 90,
            expiryDate: nil,
            locationId: "2-2",
            remarks: "猪肉白菜馅"
        )
        items.append(dumplings)
        
        // 10. 番茄 - 还有2天过期
        let tomatoExpiryDate = calendar.date(byAdding: .day, value: 2, to: now)!
        let tomato = createFoodItem(
            id: "14",
            name: "番茄",
            categoryId: "5",
            quantity: 4,
            totalPrice: 10.0,
            unitId: "1",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: tomatoExpiryDate,
            locationId: "2-1",
            remarks: "新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜新鲜蔬菜"
        )
        items.append(tomato)
        
        // ========== 衣物类物品（无过期日期）==========
        
        // 白色短袖
        let whiteShirt = createClothingItem(
            id: "15",
            name: "白色短袖",
            categoryId: "clothing",
            quantity: 3,
            totalPrice: 120.0,
            unitId: "6",
            locationId: "1-1",
            remarks: "纯棉白色T恤"
        )
        items.append(whiteShirt)
        
        // 袜子
        let socks = createClothingItem(
            id: "16",
            name: "袜子",
            categoryId: "clothing",
            quantity: 10,
            totalPrice: 50.0,
            unitId: "6",
            locationId: "1-2",
            remarks: "白色运动袜"
        )
        items.append(socks)
        
        // 运动鞋
        let sportsShoes = createClothingItem(
            id: "17",
            name: "运动鞋",
            categoryId: "shoes",
            quantity: 2,
            totalPrice: 500.0,
            unitId: "6",
            locationId: "4",
            remarks: "跑步鞋"
        )
        items.append(sportsShoes)
        
        // ========== 日用品类（无过期日期）==========
        
        // 洗衣液
        let laundry = createDailyItem(
            id: "18",
            name: "洗衣液",
            categoryId: "4",
            quantity: 2,
            totalPrice: 45.0,
            unitId: "4",
            locationId: "3",
            remarks: "3kg装"
        )
        items.append(laundry)
        
        // 纸巾
        let tissue = createDailyItem(
            id: "19",
            name: "纸巾",
            categoryId: "4",
            quantity: 5,
            totalPrice: 20.0,
            unitId: "3",
            locationId: "3-1",
            remarks: "抽纸"
        )
        items.append(tissue)
        
        // 建立父子关系
        for item in items {
            if let parentId = item.parentId {
                item.parent = items.first { $0.id == parentId }
            }
        }
        
        // 建立 children 数组
        for item in items where item.parentId != nil {
            if let parent = items.first(where: { $0.id == item.parentId }) {
                if parent.children == nil {
                    parent.children = []
                }
                parent.children?.append(item)
            }
        }
        
        return items
    }
    
    // MARK: - 辅助方法：创建物品
    private func createLocationItem(
        id: String,
        name: String,
        remarks: String? = nil,
        level: Int,
        parentId: String?
    ) -> ItemModel {
        let item = ItemModel()
        item.id = id
        item.name = name
        item.categoryId = "location"
        item.category = getCategory(byId: "location")
        item.quantity = 0
        item.totalPrice = nil
        item.unitId = nil
        item.level = level
        item.parentId = parentId
        item.remarks = remarks
        item.createdAt = Date()
        
        return item
    }
    
    private func createFoodItem(
        id: String,
        name: String,
        categoryId: String,
        quantity: Int,
        totalPrice: Double?,
        unitId: String,
        productionDate: Date?,
        shelfLife: Int?,
        expiryDate: Date?,
        locationId: String?,
        remarks: String?
    ) -> ItemModel {
        let item = ItemModel()
        item.id = id
        item.name = name
        item.categoryId = categoryId
        item.category = getCategory(byId: categoryId)
        item.quantity = quantity
        item.totalPrice = totalPrice
        item.unitId = unitId
        item.unit = getUnit(byId: unitId)
        item.level = 3
        item.parentId = locationId
        item.remarks = remarks
        item.createdAt = Date()
        
        // 处理日期
        if let expiryDate = expiryDate {
            item.expiryDate = expiryDate
        } else if let productionDate = productionDate, let shelfLife = shelfLife {
            item.productionDate = productionDate
            item.shelfLife = shelfLife
            item.calculateExpiryDate()
        }
        
        return item
    }
    
    private func createClothingItem(
        id: String,
        name: String,
        categoryId: String,
        quantity: Int,
        totalPrice: Double?,
        unitId: String,
        locationId: String?,
        remarks: String?
    ) -> ItemModel {
        let item = ItemModel()
        item.id = id
        item.name = name
        item.categoryId = categoryId
        item.category = getCategory(byId: categoryId)
        item.quantity = quantity
        item.totalPrice = totalPrice
        item.unitId = unitId
        item.unit = getUnit(byId: unitId)
        item.level = 3
        item.parentId = locationId
        item.remarks = remarks
        item.createdAt = Date()
        
        return item
    }
    
    private func createDailyItem(
        id: String,
        name: String,
        categoryId: String,
        quantity: Int,
        totalPrice: Double?,
        unitId: String,
        locationId: String?,
        remarks: String?
    ) -> ItemModel {
        let item = ItemModel()
        item.id = id
        item.name = name
        item.categoryId = categoryId
        item.category = getCategory(byId: categoryId)
        item.quantity = quantity
        item.totalPrice = totalPrice
        item.unitId = unitId
        item.unit = getUnit(byId: unitId)
        item.level = 3
        item.parentId = locationId
        item.remarks = remarks
        item.createdAt = Date()
        
        return item
    }
    
    // MARK: - 数据操作方法
    
    /// 添加物品
    func addItem(_ item: ItemModel) -> Bool {
        // 检查ID是否已存在
        if items.contains(where: { $0.id == item.id }) {
            print("❌ 物品ID已存在: \(item.id)")
            return false
        }
        
        items.append(item)
        
        // 更新父子关系
        if let parentId = item.parentId {
            if let parent = items.first(where: { $0.id == parentId }) {
                if parent.children == nil {
                    parent.children = []
                }
                parent.children?.append(item)
                item.parent = parent
            }
        }
        
        print("✅ 添加物品成功: \(item.name) (ID: \(item.id))")
        return true
    }
    
    /// 更新物品
    func updateItem(_ item: ItemModel) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            print("❌ 未找到要更新的物品: \(item.id)")
            return false
        }
        
        // 更新物品
        items[index] = item
        item.updatedAt = Date()
        
        // 重新建立父子关系
        if let parentId = item.parentId {
            if let parent = items.first(where: { $0.id == parentId }) {
                if parent.children == nil {
                    parent.children = []
                }
                if !parent.children!.contains(where: { $0.id == item.id }) {
                    parent.children?.append(item)
                }
                item.parent = parent
            }
        }
        
        print("✅ 更新物品成功: \(item.name) (ID: \(item.id))")
        return true
    }
    
    /// 删除物品
    func deleteItem(id: String) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            print("❌ 未找到要删除的物品: \(id)")
            return false
        }
        
        let item = items[index]
        
        // 递归删除所有子物品
        if let children = item.children {
            for child in children {
                _ = deleteItem(id: child.id)
            }
        }
        
        // 从父物品的children数组中移除
        if let parentId = item.parentId,
           let parent = items.first(where: { $0.id == parentId }) {
            parent.children?.removeAll { $0.id == id }
        }
        
        // 删除物品
        items.remove(at: index)
        
        print("✅ 删除物品成功: \(item.name) (ID: \(id))")
        return true
    }
    
    /// 批量添加物品
    func addItems(_ newItems: [ItemModel]) -> Int {
        var successCount = 0
        for item in newItems {
            if addItem(item) {
                successCount += 1
            }
        }
        print("✅ 批量添加完成: 成功 \(successCount)/\(newItems.count)")
        return successCount
    }
    
    /// 批量删除物品
    func deleteItems(ids: [String]) -> Int {
        var successCount = 0
        for id in ids {
            if deleteItem(id: id) {
                successCount += 1
            }
        }
        print("✅ 批量删除完成: 成功 \(successCount)/\(ids.count)")
        return successCount
    }
    
    /// 清空所有物品
    func clearAllItems() {
        let count = items.count
        items.removeAll()
        print("✅ 清空所有物品: 删除了 \(count) 个物品")
    }
    
    // MARK: - 公开查询方法
    
    /// 获取所有分类
    func getCategories() -> [CategoryModel] {
        return categories
    }
    
    /// 获取所有单位
    func getUnits() -> [UnitModel] {
        return units
    }
    
    /// 获取所有物品
    func getItems() -> [ItemModel] {
        return items
    }
    
    /// 根据分类ID获取物品
    func getItems(byCategoryId categoryId: String) -> [ItemModel] {
        return items.filter { $0.categoryId == categoryId }
    }
    
    /// 获取最近添加的物品（7天内）
    func getRecentItems() -> [ItemModel] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return items.filter { $0.createdAt >= sevenDaysAgo }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    /// 根据ID获取物品
    func getItem(byId id: String) -> ItemModel? {
        return items.first { $0.id == id }
    }
    
    /// 根据分类ID获取分类
    func getCategory(byId id: String) -> CategoryModel? {
        return categories.first { $0.id == id }
    }
    
    /// 根据单位ID获取单位
    func getUnit(byId id: String) -> UnitModel? {
        return units.first { $0.id == id }
    }
    
    /// 获取即将过期的物品（3天内）
    func getExpiringItems() -> [ItemModel] {
        let now = Date()
        let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: now) ?? now
        return items.filter { item in
            guard let expiryDate = item.expiryDate else { return false }
            return expiryDate <= threeDaysLater && expiryDate >= now
        }
    }
    
    /// 获取已过期的物品
    func getExpiredItems() -> [ItemModel] {
        let now = Date()
        return items.filter { item in
            guard let expiryDate = item.expiryDate else { return false }
            return expiryDate < now
        }
    }
    
    /// 获取所有有过期日期的物品
    func getItemsWithExpiry() -> [ItemModel] {
        return items.filter { $0.expiryDate != nil }
    }
    
    /// 获取所有没有过期日期的物品
    func getItemsWithoutExpiry() -> [ItemModel] {
        return items.filter { $0.expiryDate == nil }
    }
    
    /// 搜索物品
    func searchItems(keyword: String) -> [ItemModel] {
        return items.filter {
            $0.name.localizedCaseInsensitiveContains(keyword) ||
            $0.remarks?.localizedCaseInsensitiveContains(keyword) == true
        }
    }
    
    /// 获取顶级物品（没有父物品）
    func getTopLevelItems() -> [ItemModel] {
        return items.filter { $0.parentId == nil }
    }
    
    /// 获取子物品
    func getChildren(for parentId: String) -> [ItemModel] {
        return items.filter { $0.parentId == parentId }
    }
    
    /// 获取层级树（以树形结构返回）
    func getItemTree() -> [ItemModel] {
        return items.filter { $0.parentId == nil }
    }
    
    /// 获取按过期状态分类的物品
    func getItemsGroupedByExpiryStatus() -> (expired: [ItemModel], expiringSoon: [ItemModel], valid: [ItemModel], noExpiry: [ItemModel]) {
        let now = Date()
        var expired: [ItemModel] = []
        var expiringSoon: [ItemModel] = []
        var valid: [ItemModel] = []
        var noExpiry: [ItemModel] = []
        
        for item in items {
            guard let expiryDate = item.expiryDate else {
                noExpiry.append(item)
                continue
            }
            
            if expiryDate < now {
                expired.append(item)
            } else if item.isExpiringSoon {
                expiringSoon.append(item)
            } else {
                valid.append(item)
            }
        }
        
        return (expired, expiringSoon, valid, noExpiry)
    }
    
    // MARK: - 统计方法
    
    /// 获取物品总数
    func getTotalItemCount() -> Int {
        return items.count
    }
    
    /// 获取分类统计
    func getCategoryStatistics() -> [(category: CategoryModel, count: Int)] {
        var stats: [String: Int] = [:]
        
        for item in items {
            let categoryId = item.categoryId
            stats[categoryId, default: 0] += 1
        }
        
        return categories.compactMap { category in
            let count = stats[category.id] ?? 0
            return (category, count)
        }.filter { $0.count > 0 }
    }
    
    /// 获取过期统计
    func getExpiryStatistics() -> (total: Int, expired: Int, expiringSoon: Int, valid: Int, noExpiry: Int) {
        let grouped = getItemsGroupedByExpiryStatus()
        return (
            total: items.count,
            expired: grouped.expired.count,
            expiringSoon: grouped.expiringSoon.count,
            valid: grouped.valid.count,
            noExpiry: grouped.noExpiry.count
        )
    }
}

// MARK: - 使用示例扩展
extension MockDataService {
    
    /// 创建一个示例物品（用于测试添加）
    func createSampleItem() -> ItemModel {
        let item = ItemModel()
        item.id = UUID().uuidString
        item.name = "新物品"
        item.categoryId = "1"
        item.category = getCategory(byId: "1")
        item.quantity = 1
        item.totalPrice = 10.0
        item.unitId = "1"
        item.unit = getUnit(byId: "1")
        item.expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        item.remarks = "这是一个新添加的物品"
        item.createdAt = Date()
        
        return item
    }
    
    /// 重置所有数据到初始状态
    func resetToInitialData() {
        loadMockData()
        print("✅ 已重置所有数据到初始状态")
    }
}
