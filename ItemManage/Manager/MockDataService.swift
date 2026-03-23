//////
//////  MockDataService.swift
//////  ItemManage
//////
//////  Created by a on 2026/3/19.
//////
////
////import Foundation
////
////// MARK: - 模拟数据服务
////class MockDataService {
////    
////    // 单例模式
////    static let shared = MockDataService()
////    private init() {}
////    
////    // MARK: - 物品相关模拟数据
////    
////    /// 获取单个示例物品
////    func getExampleItem() -> ItemModel {
////        let item = ItemModel()
////        item.id = "1"
////        item.name = "苹果"
////        item.categoryId = "1"
////        item.category = getExampleCategory()
////        item.quantity = 5
////        item.totalPrice = 25.0
////        item.unitId = "1"
////        item.unit = getExampleUnit()
////        
////        // 添加示例照片
////        item.photos = getExamplePhotos()
////        
////        // 设置过期日期（7天后）
////        item.expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
////        
////        // 设置提醒
////        item.reminder.rule = getExampleReminderRule()
////        item.reminder.ruleId = "1"
////        
////        item.remarks = "这是示例物品"
////        
////        return item
////    }
////    
////    /// 获取包含层级结构的示例物品
////    func getHierarchyItem() -> ItemModel {
////        let item = getExampleItem()
////        
////        // 添加子物品示例
////        let child1 = ItemModel()
////        child1.id = "1-1"
////        child1.name = "红苹果"
////        child1.parentId = item.id
////        child1.level = 2
////        
////        let child2 = ItemModel()
////        child2.id = "1-2"
////        child2.name = "青苹果"
////        child2.parentId = item.id
////        child2.level = 2
////        
////        // 添加孙物品示例
////        let grandChild = ItemModel()
////        grandChild.id = "1-1-1"
////        grandChild.name = "新疆红苹果"
////        grandChild.parentId = child1.id
////        grandChild.level = 3
////        
////        child1.children = [grandChild]
////        grandChild.parent = child1
////        
////        item.children = [child1, child2]
////        child1.parent = item
////        child2.parent = item
////        
////        return item
////    }
////    
////    /// 获取三层级结构的示例物品
////    func getThreeLevelItem() -> ItemModel {
////        // 第一级：水果
////        let fruit = ItemModel()
////        fruit.id = "1"
////        fruit.name = "水果"
////        fruit.level = 1
////        
////        // 第二级：苹果类别
////        let apple = ItemModel()
////        apple.id = "1-1"
////        apple.name = "苹果"
////        apple.parentId = fruit.id
////        apple.level = 2
////        
////        // 第三级：具体苹果品种
////        let redApple = ItemModel()
////        redApple.id = "1-1-1"
////        redApple.name = "红富士苹果"
////        redApple.parentId = apple.id
////        redApple.level = 3
////        redApple.quantity = 10
////        redApple.totalPrice = 50.0
////        
////        let greenApple = ItemModel()
////        greenApple.id = "1-1-2"
////        greenApple.name = "青苹果"
////        greenApple.parentId = apple.id
////        greenApple.level = 3
////        greenApple.quantity = 8
////        greenApple.totalPrice = 40.0
////        
////        // 建立关系
////        apple.children = [redApple, greenApple]
////        redApple.parent = apple
////        greenApple.parent = apple
////        
////        fruit.children = [apple]
////        apple.parent = fruit
////        
////        return fruit
////    }
////    
////    /// 获取多个示例物品
////    func getExampleItems() -> [ItemModel] {
////        var items: [ItemModel] = []
////        
////        // 物品1：苹果
////        let apple = getExampleItem()
////        items.append(apple)
////        
////        // 物品2：香蕉
////        let banana = ItemModel()
////        banana.id = "2"
////        banana.name = "香蕉"
////        banana.categoryId = "1"
////        banana.category = getExampleCategory()
////        banana.quantity = 3
////        banana.totalPrice = 15.0
////        banana.unitId = "1"
////        banana.unit = getExampleUnit()
////        banana.expiryDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
////        banana.remarks = "需要尽快食用"
////        items.append(banana)
////        
////        // 物品3：牛奶
////        let milk = ItemModel()
////        milk.id = "3"
////        milk.name = "牛奶"
////        milk.categoryId = "2"
////        milk.category = getExampleCategory(name: "饮品", id: "2")
////        milk.quantity = 2
////        milk.totalPrice = 30.0
////        milk.unitId = "2"
////        milk.unit = getExampleUnit(name: "盒", id: "2")
////        milk.expiryDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())
////        milk.remarks = "冷藏保存"
////        items.append(milk)
////        
////        return items
////    }
////    
////    // MARK: - 辅助方法
////    
////    private func getExampleCategory(name: String = "水果", id: String = "1") -> CategoryModel {
////        let category = CategoryModel()
////        category.id = id
////        category.name = name
////        return category
////    }
////    
////    private func getExampleUnit(name: String = "个", id: String = "1") -> UnitModel {
////        let unit = UnitModel()
////        unit.id = id
////        unit.name = name
////        return unit
////    }
////    
////    private func getExamplePhotos() -> [PhotoModel] {
////        let photo1 = PhotoModel()
////        photo1.url = "https://example.com/photo1.jpg"
////        photo1.sortOrder = 0
////        
////        let photo2 = PhotoModel()
////        photo2.url = "https://example.com/photo2.jpg"
////        photo2.sortOrder = 1
////        
////        return [photo1, photo2]
////    }
////    
////    private func getExampleReminderRule() -> ReminderRuleModel {
////        let rule = ReminderRuleModel()
////        rule.id = "1"
////        rule.name = "过期提醒"
////        rule.daysBefore = 3
////        return rule
////    }
////}
//
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
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "2"
//            category.name = "饮品"
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "3"
//            category.name = "零食"
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "4"
//            category.name = "日用品"
//            return category
//        }(),
//        {
//            let category = CategoryModel()
//            category.id = "5"
//            category.name = "蔬菜"
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
//            return unit
//        }(),
//        {
//            let unit = UnitModel()
//            unit.id = "2"
//            unit.name = "盒"
//            return unit
//        }(),
//        {
//            let unit = UnitModel()
//            unit.id = "3"
//            unit.name = "袋"
//            return unit
//        }(),
//        {
//            let unit = UnitModel()
//            unit.id = "4"
//            unit.name = "瓶"
//            return unit
//        }()
//    ]
//    
//    // MARK: - 物品数据
//    private lazy var mockItems: [ItemModel] = {
//        var items: [ItemModel] = []
//        
//        // 物品1：苹果
//        let apple = ItemModel()
//        apple.id = "1"
//        apple.name = "苹果"
//        apple.categoryId = "1"
//        apple.category = getCategory(byId: "1")
//        apple.quantity = 5
//        apple.totalPrice = 25.0
//        apple.unitId = "1"
//        apple.unit = getUnit(byId: "1")
//        apple.expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
//        apple.createdAt = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
//        apple.remarks = "红富士苹果"
//        items.append(apple)
//        
//        // 物品2：香蕉
//        let banana = ItemModel()
//        banana.id = "2"
//        banana.name = "香蕉"
//        banana.categoryId = "1"
//        banana.category = getCategory(byId: "1")
//        banana.quantity = 3
//        banana.totalPrice = 15.0
//        banana.unitId = "1"
//        banana.unit = getUnit(byId: "1")
//        banana.expiryDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
//        banana.createdAt = Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
//        banana.remarks = "需要尽快食用"
//        items.append(banana)
//        
//        // 物品3：牛奶
//        let milk = ItemModel()
//        milk.id = "3"
//        milk.name = "牛奶"
//        milk.categoryId = "2"
//        milk.category = getCategory(byId: "2")
//        milk.quantity = 2
//        milk.totalPrice = 30.0
//        milk.unitId = "2"
//        milk.unit = getUnit(byId: "2")
//        milk.expiryDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())
//        milk.createdAt = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
//        milk.remarks = "冷藏保存"
//        items.append(milk)
//        
//        // 物品4：面包
//        let bread = ItemModel()
//        bread.id = "4"
//        bread.name = "面包"
//        bread.categoryId = "3"
//        bread.category = getCategory(byId: "3")
//        bread.quantity = 1
//        bread.totalPrice = 12.5
//        bread.unitId = "3"
//        bread.unit = getUnit(byId: "3")
//        bread.expiryDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())
//        bread.createdAt = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
//        items.append(bread)
//        
//        // 物品5：酸奶
//        let yogurt = ItemModel()
//        yogurt.id = "5"
//        yogurt.name = "酸奶"
//        yogurt.categoryId = "2"
//        yogurt.category = getCategory(byId: "2")
//        yogurt.quantity = 4
//        yogurt.totalPrice = 32.0
//        yogurt.unitId = "2"
//        yogurt.unit = getUnit(byId: "2")
//        yogurt.expiryDate = Calendar.current.date(byAdding: .day, value: 14, to: Date())
//        yogurt.createdAt = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
//        items.append(yogurt)
//        
//        // 物品6：薯片
//        let chips = ItemModel()
//        chips.id = "6"
//        chips.name = "薯片"
//        chips.categoryId = "3"
//        chips.category = getCategory(byId: "3")
//        chips.quantity = 2
//        chips.totalPrice = 18.0
//        chips.unitId = "3"
//        chips.unit = getUnit(byId: "3")
//        chips.expiryDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
//        chips.createdAt = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
//        items.append(chips)
//        
//        // 物品7：洗发水
//        let shampoo = ItemModel()
//        shampoo.id = "7"
//        shampoo.name = "洗发水"
//        shampoo.categoryId = "4"
//        shampoo.category = getCategory(byId: "4")
//        shampoo.quantity = 1
//        shampoo.totalPrice = 45.0
//        shampoo.unitId = "4"
//        shampoo.unit = getUnit(byId: "4")
//        shampoo.expiryDate = Calendar.current.date(byAdding: .day, value: 365, to: Date())
//        shampoo.createdAt = Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date()
//        items.append(shampoo)
//        
//        // 物品8：西红柿
//        let tomato = ItemModel()
//        tomato.id = "8"
//        tomato.name = "西红柿"
//        tomato.categoryId = "5"
//        tomato.category = getCategory(byId: "5")
//        tomato.quantity = 6
//        tomato.totalPrice = 15.0
//        tomato.unitId = "1"
//        tomato.unit = getUnit(byId: "1")
//        tomato.expiryDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())
//        tomato.createdAt = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
//        items.append(tomato)
//        
//        // 物品9：黄瓜
//        let cucumber = ItemModel()
//        cucumber.id = "9"
//        cucumber.name = "黄瓜"
//        cucumber.categoryId = "5"
//        cucumber.category = getCategory(byId: "5")
//        cucumber.quantity = 3
//        cucumber.totalPrice = 9.0
//        cucumber.unitId = "1"
//        cucumber.unit = getUnit(byId: "1")
//        cucumber.expiryDate = Calendar.current.date(byAdding: .day, value: 4, to: Date())
//        cucumber.createdAt = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
//        items.append(cucumber)
//        
//        return items
//    }()
//    
//    // MARK: - 公开方法
//    
//    /// 获取所有分类
//    func getCategories() -> [CategoryModel] {
//        return mockCategories
//    }
//    
//    /// 获取所有分类
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
//        let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
//        return mockItems.filter { item in
//            guard let expiryDate = item.expiryDate else { return false }
//            return expiryDate <= threeDaysLater && expiryDate >= Date()
//        }
//    }
//    
//    /// 获取已过期的物品
//    func getExpiredItems() -> [ItemModel] {
//        return mockItems.filter { $0.isExpired }
//    }
//    
//    /// 搜索物品
//    func searchItems(keyword: String) -> [ItemModel] {
//        return mockItems.filter { $0.name.localizedCaseInsensitiveContains(keyword) }
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
    private init() {}
    
    // MARK: - 分类数据
    private let mockCategories: [CategoryModel] = [
        {
            let category = CategoryModel()
            category.id = "1"
            category.name = "水果"
            return category
        }(),
        {
            let category = CategoryModel()
            category.id = "2"
            category.name = "饮品"
            return category
        }(),
        {
            let category = CategoryModel()
            category.id = "3"
            category.name = "零食"
            return category
        }(),
        {
            let category = CategoryModel()
            category.id = "4"
            category.name = "日用品"
            return category
        }(),
        {
            let category = CategoryModel()
            category.id = "5"
            category.name = "蔬菜"
            return category
        }()
    ]
    
    // MARK: - 单位数据
    private let mockUnits: [UnitModel] = [
        {
            let unit = UnitModel()
            unit.id = "1"
            unit.name = "个"
            return unit
        }(),
        {
            let unit = UnitModel()
            unit.id = "2"
            unit.name = "盒"
            return unit
        }(),
        {
            let unit = UnitModel()
            unit.id = "3"
            unit.name = "袋"
            return unit
        }(),
        {
            let unit = UnitModel()
            unit.id = "4"
            unit.name = "瓶"
            return unit
        }()
    ]
    
    // MARK: - 层级物品数据
    private lazy var mockItems: [ItemModel] = {
        var items: [ItemModel] = []
        
        // ===== 第一组层级：水果类 =====
        // 第一级：水果分类（父物品）
        // ===== 第一组层级：卧室 =====
        // 第一级：衣柜
        let wardrobe = createItem(
            id: "1",
            name: "衣柜",
            categoryId: "location",
            quantity: 0,
            totalPrice: nil,
            level: 1,
            parentId: nil
        )
        wardrobe.remarks = "主卧大衣柜"
        items.append(wardrobe)

        // 第二级：粉色箱子
        let pinkBox = createItem(
            id: "1-1",
            name: "粉色箱子",
            categoryId: "location",
            quantity: 0,
            totalPrice: nil,
            level: 2,
            parentId: "1"
        )
        pinkBox.remarks = "放在衣柜上层"
        items.append(pinkBox)

        // 第三级：白色短袖
        let whiteShirt = createItem(
            id: "1-1-1",
            name: "白色短袖",
            categoryId: "clothing",
            quantity: 3,
            totalPrice: 120.0,
            unitId: "1",
            expiryDays: nil,
            createdDaysAgo: 5,
            level: 3,
            parentId: "1-1"
        )
        whiteShirt.remarks = "纯棉白色T恤"
        items.append(whiteShirt)

        // 第二级：抽屉
        let drawer = createItem(
            id: "1-2",
            name: "抽屉",
            categoryId: "location",
            quantity: 0,
            totalPrice: nil,
            level: 2,
            parentId: "1"
        )
        drawer.remarks = "衣柜下层抽屉"
        items.append(drawer)

        // 第三级：袜子
        let socks = createItem(
            id: "1-2-1",
            name: "袜子",
            categoryId: "clothing",
            quantity: 10,
            totalPrice: 50.0,
            unitId: "1",
            expiryDays: nil,
            createdDaysAgo: 20,
            level: 3,
            parentId: "1-2"
        )
        socks.remarks = "白色运动袜"
        items.append(socks)

        // ===== 第二组层级：厨房 =====
        // 第一级：冰箱
        let fridge = createItem(
            id: "2",
            name: "冰箱",
            categoryId: "location",
            quantity: 0,
            totalPrice: nil,
            level: 1,
            parentId: nil
        )
        items.append(fridge)

        // 第二级：冷藏层
        let fridgeUpper = createItem(
            id: "2-1",
            name: "冷藏层",
            categoryId: "location",
            quantity: 0,
            totalPrice: nil,
            level: 2,
            parentId: "2"
        )
        items.append(fridgeUpper)

        // 第三级：鸡蛋
        let eggs = createItem(
            id: "2-1-1",
            name: "鸡蛋",
            categoryId: "food",
            quantity: 12,
            totalPrice: 18.0,
            unitId: "1",
            expiryDays: 14,
            createdDaysAgo: 2,
            level: 3,
            parentId: "2-1"
        )
        items.append(eggs)

        // 第二级：冷冻层
        let fridgeFreezer = createItem(
            id: "2-2",
            name: "冷冻层",
            categoryId: "location",
            quantity: 0,
            totalPrice: nil,
            level: 2,
            parentId: "2"
        )
        items.append(fridgeFreezer)

        // 第三级：速冻水饺
        let dumplings = createItem(
            id: "2-2-1",
            name: "速冻水饺",
            categoryId: "food",
            quantity: 2,
            totalPrice: 30.0,
            unitId: "2",
            expiryDays: 90,
            createdDaysAgo: 15,
            level: 3,
            parentId: "2-2"
        )
        items.append(dumplings)

        // 第一级：橱柜
        let cabinet = createItem(
            id: "3",
            name: "橱柜",
            categoryId: "location",
            quantity: 0,
            totalPrice: nil,
            level: 1,
            parentId: nil
        )
        items.append(cabinet)

        // 第二级：上层橱柜
        let upperCabinet = createItem(
            id: "3-1",
            name: "上层橱柜",
            categoryId: "location",
            quantity: 0,
            totalPrice: nil,
            level: 2,
            parentId: "3"
        )
        items.append(upperCabinet)

        // 第三级：方便面
        let instantNoodles = createItem(
            id: "3-1-1",
            name: "方便面",
            categoryId: "food",
            quantity: 5,
            totalPrice: 25.0,
            unitId: "3",
            expiryDays: 180,
            createdDaysAgo: 30,
            level: 3,
            parentId: "3-1"
        )
        items.append(instantNoodles)

        // ===== 第三组：独立位置（只有一级）=====
        // 鞋柜
        let shoeCabinet = createItem(
            id: "4",
            name: "鞋柜",
            categoryId: "location",
            quantity: 0,
            totalPrice: nil,
            level: 1,
            parentId: nil
        )
        items.append(shoeCabinet)

        // 第二级：运动鞋
        let sportsShoes = createItem(
            id: "4-1",
            name: "运动鞋",
            categoryId: "shoes",
            quantity: 2,
            totalPrice: 500.0,
            unitId: "1",
            expiryDays: nil,
            createdDaysAgo: 30,
            level: 2,
            parentId: "4"
        )
        items.append(sportsShoes)
            ////
        
        // 建立父子关系（设置 parent 引用）
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
    }()
    
    // MARK: - 辅助方法：创建物品
    private func createItem(
        id: String,
        name: String,
        categoryId: String,
        quantity: Int,
        totalPrice: Double?,
        unitId: String? = nil,
        expiryDays: Int? = nil,
        createdDaysAgo: Int? = nil,
        level: Int,
        parentId: String?
    ) -> ItemModel {
        let item = ItemModel()
        item.id = id
        item.name = name
        item.categoryId = categoryId
        item.category = getCategory(byId: categoryId)
        item.quantity = quantity
        item.totalPrice = totalPrice
        item.unitId = unitId
        item.unit = unitId.flatMap { getUnit(byId: $0) }
        item.level = level
        item.parentId = parentId
        
        if let expiryDays = expiryDays {
            item.expiryDate = Calendar.current.date(byAdding: .day, value: expiryDays, to: Date())
        }
        
        if let createdDaysAgo = createdDaysAgo {
            item.createdAt = Calendar.current.date(byAdding: .day, value: -createdDaysAgo, to: Date()) ?? Date()
        }
        
        return item
    }
    
    // MARK: - 公开方法
    
    /// 获取所有分类
    func getCategories() -> [CategoryModel] {
        return mockCategories
    }
    
    /// 获取所有单位
    func getUnits() -> [UnitModel] {
        return mockUnits
    }
    
    /// 获取所有物品
    func getItems() -> [ItemModel] {
        return mockItems
    }
    
    /// 根据分类ID获取物品
    func getItems(byCategoryId categoryId: String) -> [ItemModel] {
        return mockItems.filter { $0.categoryId == categoryId }
    }
    
    /// 获取最近添加的物品（7天内）
    func getRecentItems() -> [ItemModel] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return mockItems.filter { $0.createdAt >= sevenDaysAgo }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    /// 根据ID获取物品
    func getItem(byId id: String) -> ItemModel? {
        return mockItems.first { $0.id == id }
    }
    
    /// 根据分类ID获取分类
    func getCategory(byId id: String) -> CategoryModel? {
        return mockCategories.first { $0.id == id }
    }
    
    /// 根据单位ID获取单位
    func getUnit(byId id: String) -> UnitModel? {
        return mockUnits.first { $0.id == id }
    }
    
    /// 获取即将过期的物品（3天内）
    func getExpiringItems() -> [ItemModel] {
        let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        return mockItems.filter { item in
            guard let expiryDate = item.expiryDate else { return false }
            return expiryDate <= threeDaysLater && expiryDate >= Date()
        }
    }
    
    /// 获取已过期的物品
    func getExpiredItems() -> [ItemModel] {
        return mockItems.filter { $0.isExpired }
    }
    
    /// 搜索物品
    func searchItems(keyword: String) -> [ItemModel] {
        return mockItems.filter {
            $0.name.localizedCaseInsensitiveContains(keyword) ||
            $0.remarks?.localizedCaseInsensitiveContains(keyword) == true
        }
    }
    
    /// 获取顶级物品（没有父物品）
    func getTopLevelItems() -> [ItemModel] {
        return mockItems.filter { $0.parentId == nil }
    }
    
    /// 获取子物品
    func getChildren(for parentId: String) -> [ItemModel] {
        return mockItems.filter { $0.parentId == parentId }
    }
    
    /// 获取层级树（以树形结构返回）
    func getItemTree() -> [ItemModel] {
        return mockItems.filter { $0.parentId == nil }
    }
}
