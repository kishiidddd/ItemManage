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
    private var primaryLocations: [PrimaryLocationModel] = []
    private var secondaryLocations: [SecondaryLocationModel] = []
    
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
        
        // 加载一级位置数据
        primaryLocations = [
            {
                let location = PrimaryLocationModel()
                location.id = "primary_1"
                location.name = "冰箱"
                location.icon = "❄️"
                location.color = "#2196F3"
                location.isSystem = true
                location.sortOrder = 1
                return location
            }(),
            {
                let location = PrimaryLocationModel()
                location.id = "primary_2"
                location.name = "橱柜"
                location.icon = "🚪"
                location.color = "#795548"
                location.isSystem = true
                location.sortOrder = 2
                return location
            }(),
            {
                let location = PrimaryLocationModel()
                location.id = "primary_3"
                location.name = "衣柜"
                location.icon = "👔"
                location.color = "#9C27B0"
                location.isSystem = true
                location.sortOrder = 3
                return location
            }(),
            {
                let location = PrimaryLocationModel()
                location.id = "primary_4"
                location.name = "鞋柜"
                location.icon = "👟"
                location.color = "#FF9800"
                location.isSystem = true
                location.sortOrder = 4
                return location
            }(),
            {
                let location = PrimaryLocationModel()
                location.id = "primary_5"
                location.name = "储物间"
                location.icon = "📦"
                location.color = "#607D8B"
                location.isSystem = true
                location.sortOrder = 5
                return location
            }()
        ]
        
        // 加载二级位置数据
        secondaryLocations = [
            // 冰箱的二级位置
            {
                let location = SecondaryLocationModel()
                location.id = "secondary_1_1"
                location.name = "冷藏层"
                location.primaryLocationId = "primary_1"
                location.icon = "🥶"
                location.color = "#03A9F4"
                location.isSystem = true
                location.sortOrder = 1
                return location
            }(),
            {
                let location = SecondaryLocationModel()
                location.id = "secondary_1_2"
                location.name = "冷冻层"
                location.primaryLocationId = "primary_1"
                location.icon = "❄️"
                location.color = "#00BCD4"
                location.isSystem = true
                location.sortOrder = 2
                return location
            }(),
            {
                let location = SecondaryLocationModel()
                location.id = "secondary_1_3"
                location.name = "保鲜层"
                location.primaryLocationId = "primary_1"
                location.icon = "🥬"
                location.color = "#4CAF50"
                location.isSystem = true
                location.sortOrder = 3
                return location
            }(),
            // 橱柜的二级位置
            {
                let location = SecondaryLocationModel()
                location.id = "secondary_2_1"
                location.name = "上层橱柜"
                location.primaryLocationId = "primary_2"
                location.icon = "⬆️"
                location.color = "#8D6E63"
                location.isSystem = true
                location.sortOrder = 1
                return location
            }(),
            {
                let location = SecondaryLocationModel()
                location.id = "secondary_2_2"
                location.name = "下层橱柜"
                location.primaryLocationId = "primary_2"
                location.icon = "⬇️"
                location.color = "#A1887F"
                location.isSystem = true
                location.sortOrder = 2
                return location
            }(),
            // 衣柜的二级位置
            {
                let location = SecondaryLocationModel()
                location.id = "secondary_3_1"
                location.name = "挂衣区"
                location.primaryLocationId = "primary_3"
                location.icon = "👕"
                location.color = "#BA68C8"
                location.isSystem = true
                location.sortOrder = 1
                return location
            }(),
            {
                let location = SecondaryLocationModel()
                location.id = "secondary_3_2"
                location.name = "叠放区"
                location.primaryLocationId = "primary_3"
                location.icon = "📚"
                location.color = "#CE93D8"
                location.isSystem = true
                location.sortOrder = 2
                return location
            }(),
            {
                let location = SecondaryLocationModel()
                location.id = "secondary_3_3"
                location.name = "抽屉"
                location.primaryLocationId = "primary_3"
                location.icon = "🗄️"
                location.color = "#E1BEE7"
                location.isSystem = true
                location.sortOrder = 3
                return location
            }()
        ]
        
        // 为一级位置建立二级位置关联
        for primary in primaryLocations {
            primary.secondaryLocations = secondaryLocations.filter { $0.primaryLocationId == primary.id }
        }
        
        // 加载物品数据
        items = createMockItems()
    }
    
    // MARK: - 创建模拟物品数据
    private func createMockItems() -> [ItemModel] {
        var items: [ItemModel] = []
        
        let calendar = Calendar.current
        let now = Date()
        
        // ========== 物品类（有过期日期）==========
        
        // 1. 鸡蛋 - 使用生产日期 + 保质期（还有12天过期）
        let eggsProductionDate = calendar.date(byAdding: .day, value: -2, to: now)!
        let eggs = createFoodItem(
            id: "1",
            name: "鸡蛋",
            categoryId: "food",
            quantity: 12,
            totalPrice: 18.0,
            unitId: "1",
            productionDate: eggsProductionDate,
            shelfLife: 14,
            expiryDate: nil,
            primaryLocationId: "primary_1",
            secondaryLocationId: "secondary_1_1",
            remarks: "新鲜鸡蛋，保质期14天"
        )
        items.append(eggs)
        
        // 2. 牛奶 - 直接填写过期日期（3天后过期）
        let milkExpiryDate = calendar.date(byAdding: .day, value: 3, to: now)!
        let milk = createFoodItem(
            id: "2",
            name: "鲜牛奶",
            categoryId: "2",
            quantity: 2,
            totalPrice: 32.0,
            unitId: "4",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: milkExpiryDate,
            primaryLocationId: "primary_1",
            secondaryLocationId: "secondary_1_1",
            remarks: "巴氏杀菌乳，需冷藏"
        )
        items.append(milk)
        
        // 3. 面包 - 直接填写过期日期（1天后过期）
        let breadExpiryDate = calendar.date(byAdding: .day, value: 1, to: now)!
        let bread = createFoodItem(
            id: "3",
            name: "全麦面包",
            categoryId: "3",
            quantity: 1,
            totalPrice: 15.0,
            unitId: "3",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: breadExpiryDate,
            primaryLocationId: "primary_2",
            secondaryLocationId: "secondary_2_1",
            remarks: "全麦吐司"
        )
        items.append(bread)
        
        // 4. 酸奶 - 已过期5天
        let yogurtExpiryDate = calendar.date(byAdding: .day, value: -5, to: now)!
        let yogurt = createFoodItem(
            id: "4",
            name: "原味酸奶",
            categoryId: "2",
            quantity: 3,
            totalPrice: 24.0,
            unitId: "2",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: yogurtExpiryDate,
            primaryLocationId: "primary_1",
            secondaryLocationId: "secondary_1_1",
            remarks: "已过期，请勿食用"
        )
        items.append(yogurt)
        
        // 5. 苹果 - 还有7天过期
        let appleExpiryDate = calendar.date(byAdding: .day, value: 7, to: now)!
        let apple = createFoodItem(
            id: "5",
            name: "红富士苹果",
            categoryId: "1",
            quantity: 5,
            totalPrice: 25.0,
            unitId: "1",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: appleExpiryDate,
            primaryLocationId: "primary_1",
            secondaryLocationId: "secondary_1_3",
            remarks: "新鲜水果"
        )
        items.append(apple)
        
        // 6. 方便面 - 使用生产日期 + 保质期（还有150天过期）
        let noodlesProductionDate = calendar.date(byAdding: .day, value: -30, to: now)!
        let noodles = createFoodItem(
            id: "6",
            name: "方便面",
            categoryId: "3",
            quantity: 5,
            totalPrice: 25.0,
            unitId: "3",
            productionDate: noodlesProductionDate,
            shelfLife: 180,
            expiryDate: nil,
            primaryLocationId: "primary_2",
            secondaryLocationId: "secondary_2_1",
            remarks: "保质期6个月"
        )
        items.append(noodles)
        
        // 7. 可乐 - 还有30天过期
        let colaExpiryDate = calendar.date(byAdding: .day, value: 30, to: now)!
        let cola = createFoodItem(
            id: "7",
            name: "可乐",
            categoryId: "2",
            quantity: 6,
            totalPrice: 18.0,
            unitId: "4",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: colaExpiryDate,
            primaryLocationId: "primary_1",
            secondaryLocationId: "secondary_1_1",
            remarks: "碳酸饮料"
        )
        items.append(cola)
        
        // 8. 香蕉 - 还有4天过期
        let bananaExpiryDate = calendar.date(byAdding: .day, value: 4, to: now)!
        let banana = createFoodItem(
            id: "8",
            name: "香蕉",
            categoryId: "1",
            quantity: 3,
            totalPrice: 12.0,
            unitId: "1",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: bananaExpiryDate,
            primaryLocationId: "primary_1",
            secondaryLocationId: "secondary_1_3",
            remarks: "热带水果"
        )
        items.append(banana)
        
        // 9. 速冻水饺 - 使用生产日期 + 保质期（还有75天过期）
        let dumplingsProductionDate = calendar.date(byAdding: .day, value: -15, to: now)!
        let dumplings = createFoodItem(
            id: "9",
            name: "速冻水饺",
            categoryId: "food",
            quantity: 2,
            totalPrice: 30.0,
            unitId: "2",
            productionDate: dumplingsProductionDate,
            shelfLife: 90,
            expiryDate: nil,
            primaryLocationId: "primary_1",
            secondaryLocationId: "secondary_1_2",
            remarks: "猪肉白菜馅"
        )
        items.append(dumplings)
        
        // 10. 番茄 - 还有2天过期
        let tomatoExpiryDate = calendar.date(byAdding: .day, value: 2, to: now)!
        let tomato = createFoodItem(
            id: "10",
            name: "番茄",
            categoryId: "5",
            quantity: 4,
            totalPrice: 10.0,
            unitId: "1",
            productionDate: nil,
            shelfLife: nil,
            expiryDate: tomatoExpiryDate,
            primaryLocationId: "primary_1",
            secondaryLocationId: "secondary_1_3",
            remarks: "新鲜蔬菜"
        )
        items.append(tomato)
        
        // ========== 衣物类物品（无过期日期）==========
        
        // 白色短袖
        let whiteShirt = createClothingItem(
            id: "11",
            name: "白色短袖",
            categoryId: "clothing",
            quantity: 3,
            totalPrice: 120.0,
            unitId: "6",
            primaryLocationId: "primary_3",
            secondaryLocationId: "secondary_3_1",
            remarks: "纯棉白色T恤"
        )
        items.append(whiteShirt)
        
        // 袜子
        let socks = createClothingItem(
            id: "12",
            name: "袜子",
            categoryId: "clothing",
            quantity: 10,
            totalPrice: 50.0,
            unitId: "6",
            primaryLocationId: "primary_3",
            secondaryLocationId: "secondary_3_2",
            remarks: "白色运动袜"
        )
        items.append(socks)
        
        // 运动鞋
        let sportsShoes = createClothingItem(
            id: "13",
            name: "运动鞋",
            categoryId: "shoes",
            quantity: 2,
            totalPrice: 500.0,
            unitId: "6",
            primaryLocationId: "primary_4",
            secondaryLocationId: nil,
            remarks: "跑步鞋"
        )
        items.append(sportsShoes)
        
        // ========== 日用品类（无过期日期）==========
        
        // 洗衣液
        let laundry = createDailyItem(
            id: "14",
            name: "洗衣液",
            categoryId: "4",
            quantity: 2,
            totalPrice: 45.0,
            unitId: "4",
            primaryLocationId: "primary_5",
            secondaryLocationId: nil,
            remarks: "3kg装"
        )
        items.append(laundry)
        
        // 纸巾
        let tissue = createDailyItem(
            id: "15",
            name: "纸巾",
            categoryId: "4",
            quantity: 5,
            totalPrice: 20.0,
            unitId: "3",
            primaryLocationId: "primary_2",
            secondaryLocationId: "secondary_2_1",
            remarks: "抽纸"
        )
        items.append(tissue)
        
        // 建立位置对象的关联
        for item in items {
            if let primaryId = item.primaryLocationId {
                item.primaryLocation = primaryLocations.first { $0.id == primaryId }
            }
            if let secondaryId = item.secondaryLocationId {
                item.secondaryLocation = secondaryLocations.first { $0.id == secondaryId }
            }
        }
        
        return items
    }
    
    // MARK: - 辅助方法：创建物品
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
        primaryLocationId: String?,
        secondaryLocationId: String?,
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
        item.primaryLocationId = primaryLocationId
        item.secondaryLocationId = secondaryLocationId
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
        primaryLocationId: String?,
        secondaryLocationId: String?,
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
        item.primaryLocationId = primaryLocationId
        item.secondaryLocationId = secondaryLocationId
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
        primaryLocationId: String?,
        secondaryLocationId: String?,
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
        item.primaryLocationId = primaryLocationId
        item.secondaryLocationId = secondaryLocationId
        item.remarks = remarks
        item.createdAt = Date()
        
        return item
    }
    
    // MARK: - 位置数据操作方法
    
    /// 添加一级位置
    func addPrimaryLocation(_ location: PrimaryLocationModel) -> Bool {
        if primaryLocations.contains(where: { $0.id == location.id }) {
            print("❌ 一级位置ID已存在: \(location.id)")
            return false
        }
        
        primaryLocations.append(location)
        print("✅ 添加一级位置成功: \(location.name) (ID: \(location.id))")
        return true
    }
    
    /// 更新一级位置
    func updatePrimaryLocation(_ location: PrimaryLocationModel) -> Bool {
        guard let index = primaryLocations.firstIndex(where: { $0.id == location.id }) else {
            print("❌ 未找到要更新的一级位置: \(location.id)")
            return false
        }
        
        primaryLocations[index] = location
        print("✅ 更新一级位置成功: \(location.name) (ID: \(location.id))")
        return true
    }
    
    /// 删除一级位置
    func deletePrimaryLocation(id: String) -> Bool {
        guard let index = primaryLocations.firstIndex(where: { $0.id == id }) else {
            print("❌ 未找到要删除的一级位置: \(id)")
            return false
        }
        
        primaryLocations.remove(at: index)
        print("✅ 删除一级位置成功: \(id)")
        return true
    }
    
    /// 添加二级位置
    func addSecondaryLocation(_ location: SecondaryLocationModel) -> Bool {
        if secondaryLocations.contains(where: { $0.id == location.id }) {
            print("❌ 二级位置ID已存在: \(location.id)")
            return false
        }
        
        secondaryLocations.append(location)
        print("✅ 添加二级位置成功: \(location.name) (ID: \(location.id))")
        return true
    }
    
    /// 更新二级位置
    func updateSecondaryLocation(_ location: SecondaryLocationModel) -> Bool {
        guard let index = secondaryLocations.firstIndex(where: { $0.id == location.id }) else {
            print("❌ 未找到要更新的二级位置: \(location.id)")
            return false
        }
        
        secondaryLocations[index] = location
        print("✅ 更新二级位置成功: \(location.name) (ID: \(location.id))")
        return true
    }
    
    /// 删除二级位置
    func deleteSecondaryLocation(id: String) -> Bool {
        guard let index = secondaryLocations.firstIndex(where: { $0.id == id }) else {
            print("❌ 未找到要删除的二级位置: \(id)")
            return false
        }
        
        secondaryLocations.remove(at: index)
        print("✅ 删除二级位置成功: \(id)")
        return true
    }
    
    // MARK: - 物品数据操作方法
    
    /// 添加物品
    func addItem(_ item: ItemModel) -> Bool {
        // 检查ID是否已存在
        if items.contains(where: { $0.id == item.id }) {
            print("❌ 物品ID已存在: \(item.id)")
            return false
        }
        
        items.append(item)
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
        items.remove(at: index)
        
        print("✅ 删除物品成功: \(item.name) (ID: \(id))")
        return true
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
    
    /// 获取所有一级位置
    func getPrimaryLocations() -> [PrimaryLocationModel] {
        return primaryLocations
    }
    
    /// 获取所有二级位置
    func getSecondaryLocations() -> [SecondaryLocationModel] {
        return secondaryLocations
    }
    
    /// 根据一级位置ID获取二级位置
    func getSecondaryLocations(for primaryLocationId: String) -> [SecondaryLocationModel] {
        return secondaryLocations.filter { $0.primaryLocationId == primaryLocationId }
    }
    
    /// 根据ID获取一级位置
    func getPrimaryLocation(byId id: String) -> PrimaryLocationModel? {
        return primaryLocations.first { $0.id == id }
    }
    
    /// 根据ID获取二级位置
    func getSecondaryLocation(byId id: String) -> SecondaryLocationModel? {
        return secondaryLocations.first { $0.id == id }
    }
    
    /// 获取所有物品
    func getItems() -> [ItemModel] {
        return items
    }
    
    /// 根据分类ID获取物品
    func getItems(byCategoryId categoryId: String) -> [ItemModel] {
        return items.filter { $0.categoryId == categoryId }
    }
    
    /// 根据一级位置ID获取物品
    func getItems(byPrimaryLocationId locationId: String) -> [ItemModel] {
        return items.filter { $0.primaryLocationId == locationId }
    }
    
    /// 根据二级位置ID获取物品
    func getItems(bySecondaryLocationId locationId: String) -> [ItemModel] {
        return items.filter { $0.secondaryLocationId == locationId }
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
    
    /// 获取位置统计
    func getLocationStatistics() -> [(location: PrimaryLocationModel, count: Int)] {
        var stats: [String: Int] = [:]
        
        for item in items {
            if let locationId = item.primaryLocationId {
                stats[locationId, default: 0] += 1
            }
        }
        
        return primaryLocations.compactMap { location in
            let count = stats[location.id] ?? 0
            return (location, count)
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
        item.primaryLocationId = "primary_1"
        item.secondaryLocationId = "secondary_1_1"
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
