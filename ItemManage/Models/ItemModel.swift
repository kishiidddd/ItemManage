////
////
////  CategoryModel.swift
////  ItemManage
////
////  Created by a on 2026/3/17.
////
//
//import Foundation
//import HandyJSON
//
//// MARK: - 主物品模型
//class ItemModel: HandyJSON {
//    var id: String = ""
//    var name: String = ""
//    var categoryId: String = ""
//    var quantity: Int = 1
//    var totalPrice: Double?
//    var unitId: String?
//    var photos: [PhotoModel] = []
//    var productionDate: Date?
//    var expiryDate: Date?
//    var reminder: ReminderSettingModel = ReminderSettingModel()
//    var remarks: String?
//    var status: String = "normal"
//    var createdAt: Date = Date()
//    var updatedAt: Date = Date()
//    
//    // 关联对象（用于UI展示）
//    var category: CategoryModel?
//    var unit: UnitModel?
//    
//    required init() {}
//    
//    func mapping(mapper: HelpingMapper) {
//        mapper <<< self.id <-- "_id"
//        
//        // 处理日期格式
//        mapper <<< self.productionDate <-- "productionDate"
//        mapper <<< self.expiryDate <-- "expiryDate"
//        mapper <<< self.createdAt <-- "createdAt"
//        mapper <<< self.updatedAt <-- "updatedAt"
//    }
//    
//    // 计算属性：单价
//    var unitPrice: Double? {
//        if let totalPrice = totalPrice, quantity > 0 {
//            return totalPrice / Double(quantity)
//        }
//        return nil
//    }
//    
//    // 计算属性：是否过期
//    var isExpired: Bool {
//        guard let expiryDate = expiryDate else { return false }
//        return expiryDate < Date()
//    }
//    
//    // 计算属性：剩余天数
//    var daysUntilExpiry: Int? {
//        guard let expiryDate = expiryDate else { return nil }
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.day], from: Date(), to: expiryDate)
//        return components.day
//    }
//    
//    // 计算属性：过期状态描述
//    var expiryStatusDescription: String {
//        if isExpired {
//            return "已过期"
//        }
//        
//        if let days = daysUntilExpiry {
//            if days < 0 {
//                return "已过期"
//            } else if days == 0 {
//                return "今天过期"
//            } else if days <= 3 {
//                return "即将过期"
//            } else {
//                return "\(days)天后过期"
//            }
//        }
//        
//        return "无过期时间"
//    }
//    
//    // 计算属性：显示价格
//    var displayPrice: String {
//        if let totalPrice = totalPrice {
//            return String(format: "¥%.2f", totalPrice)
//        }
//        return "未设置"
//    }
//    
//    // 计算属性：显示单位
//    var displayUnit: String {
//        if let unit = unit {
//            return unit.name
//        }
//        return "个"
//    }
//    
//    // 示例数据
//    static func example() -> ItemModel {
//        let item = ItemModel()
//        item.id = "1"
//        item.name = "苹果"
//        item.categoryId = "1"
//        item.category = CategoryModel.example()
//        item.quantity = 5
//        item.totalPrice = 25.0
//        item.unitId = "1"
//        item.unit = UnitModel.example()
//        
//        // 添加示例照片
//        let photo1 = PhotoModel()
//        photo1.url = "https://example.com/photo1.jpg"
//        photo1.sortOrder = 0
//        
//        let photo2 = PhotoModel()
//        photo2.url = "https://example.com/photo2.jpg"
//        photo2.sortOrder = 1
//        
//        item.photos = [photo1, photo2]
//        
//        // 设置过期日期（7天后）
//        item.expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
//        
//        // 设置提醒
//        item.reminder.rule = ReminderRuleModel.example()
//        item.reminder.ruleId = "1"
//        
//        item.remarks = "这是示例物品"
//        
//        return item
//    }
//}

//
//  CategoryModel.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation
import HandyJSON

// MARK: - 主物品模型
class ItemModel: HandyJSON {
    var id: String = ""
    var name: String = ""
    var categoryId: String = ""
    var quantity: Int = 1
    var totalPrice: Double?
    var unitId: String?
    var photos: [PhotoModel] = []
    var productionDate: Date?
    var expiryDate: Date?
    var reminder: ReminderSettingModel = ReminderSettingModel()
    var remarks: String?
    var status: String = "normal"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // 层级关系属性
    var parentId: String?          // 父物品ID
    var level: Int = 1              // 当前层级（1-3）
    var children: [ItemModel]?      // 子物品数组
    
    // 关联对象（用于UI展示）
    var category: CategoryModel?
    var unit: UnitModel?
    var parent: ItemModel?          // 父物品对象（可选，避免循环引用）
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.id <-- "_id"
        
        // 处理日期格式
        mapper <<< self.productionDate <-- "productionDate"
        mapper <<< self.expiryDate <-- "expiryDate"
        mapper <<< self.createdAt <-- "createdAt"
        mapper <<< self.updatedAt <-- "updatedAt"
        
        // 处理层级关系
        mapper <<< self.parentId <-- "parentId"
        mapper <<< self.level <-- "level"
        mapper <<< self.children <-- "children"
    }
    
    // 计算属性：单价
    var unitPrice: Double? {
        if let totalPrice = totalPrice, quantity > 0 {
            return totalPrice / Double(quantity)
        }
        return nil
    }
    
    // 计算属性：是否过期
    var isExpired: Bool {
        guard let expiryDate = expiryDate else { return false }
        return expiryDate < Date()
    }
    
    // 计算属性：剩余天数
    var daysUntilExpiry: Int? {
        guard let expiryDate = expiryDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expiryDate)
        return components.day
    }
    
    // 计算属性：过期状态描述
    var expiryStatusDescription: String {
        if isExpired {
            return "已过期"
        }
        
        if let days = daysUntilExpiry {
            if days < 0 {
                return "已过期"
            } else if days == 0 {
                return "今天过期"
            } else if days <= 3 {
                return "即将过期"
            } else {
                return "\(days)天后过期"
            }
        }
        
        return "无过期时间"
    }
    
    // 计算属性：显示价格
    var displayPrice: String {
        if let totalPrice = totalPrice {
            return String(format: "¥%.2f", totalPrice)
        }
        return "未设置"
    }
    
    // 计算属性：显示单位
    var displayUnit: String {
        if let unit = unit {
            return unit.name
        }
        return "个"
    }
    
    // 计算属性：是否有子物品
    var hasChildren: Bool {
        return children?.isEmpty == false
    }
    
    // 计算属性：是否是顶级物品
    var isTopLevel: Bool {
        return parentId == nil || parentId?.isEmpty == true
    }
    
    // 计算属性：是否是叶子节点（没有子物品）
    var isLeaf: Bool {
        return !hasChildren
    }
    
    // 方法：添加子物品
    func addChild(_ child: ItemModel) {
        if children == nil {
            children = []
        }
        
        child.parentId = self.id
        child.parent = self
        child.level = self.level + 1
        
        // 限制最多三级
        if child.level <= 3 {
            children?.append(child)
        }
    }
    
    // 方法：移除子物品
    func removeChild(_ child: ItemModel) {
        children?.removeAll { $0.id == child.id }
        child.parentId = nil
        child.parent = nil
    }
    
    // 方法：获取所有子物品（递归）
    func getAllChildren() -> [ItemModel] {
        var allChildren: [ItemModel] = []
        
        if let children = children {
            allChildren.append(contentsOf: children)
            
            for child in children {
                allChildren.append(contentsOf: child.getAllChildren())
            }
        }
        
        return allChildren
    }
    
    // 方法：获取层级路径
    func getPath() -> [ItemModel] {
        var path: [ItemModel] = [self]
        var current = self.parent
        
        while let parent = current {
            path.insert(parent, at: 0)
            current = parent.parent
        }
        
        return path
    }
    
    // 示例数据
    static func example() -> ItemModel {
        let item = ItemModel()
        item.id = "1"
        item.name = "苹果"
        item.categoryId = "1"
        item.category = CategoryModel.example()
        item.quantity = 5
        item.totalPrice = 25.0
        item.unitId = "1"
        item.unit = UnitModel.example()
        
        // 添加示例照片
        let photo1 = PhotoModel()
        photo1.url = "https://example.com/photo1.jpg"
        photo1.sortOrder = 0
        
        let photo2 = PhotoModel()
        photo2.url = "https://example.com/photo2.jpg"
        photo2.sortOrder = 1
        
        item.photos = [photo1, photo2]
        
        // 设置过期日期（7天后）
        item.expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        
        // 设置提醒
        item.reminder.rule = ReminderRuleModel.example()
        item.reminder.ruleId = "1"
        
        item.remarks = "这是示例物品"
        
        // 添加子物品示例
        let child1 = ItemModel()
        child1.id = "1-1"
        child1.name = "红苹果"
        child1.parentId = item.id
        child1.level = 2
        
        let child2 = ItemModel()
        child2.id = "1-2"
        child2.name = "青苹果"
        child2.parentId = item.id
        child2.level = 2
        
        // 添加孙物品示例
        let grandChild = ItemModel()
        grandChild.id = "1-1-1"
        grandChild.name = "新疆红苹果"
        grandChild.parentId = child1.id
        grandChild.level = 3
        
        child1.children = [grandChild]
        grandChild.parent = child1
        
        item.children = [child1, child2]
        child1.parent = item
        child2.parent = item
        
        return item
    }
    
    // 示例数据：创建三层级结构的物品
    static func exampleWithThreeLevels() -> ItemModel {
        // 第一级：水果
        let fruit = ItemModel()
        fruit.id = "1"
        fruit.name = "水果"
        fruit.level = 1
        
        // 第二级：苹果类别
        let apple = ItemModel()
        apple.id = "1-1"
        apple.name = "苹果"
        apple.parentId = fruit.id
        apple.level = 2
        
        // 第三级：具体苹果品种
        let redApple = ItemModel()
        redApple.id = "1-1-1"
        redApple.name = "红富士苹果"
        redApple.parentId = apple.id
        redApple.level = 3
        redApple.quantity = 10
        redApple.totalPrice = 50.0
        
        let greenApple = ItemModel()
        greenApple.id = "1-1-2"
        greenApple.name = "青苹果"
        greenApple.parentId = apple.id
        greenApple.level = 3
        greenApple.quantity = 8
        greenApple.totalPrice = 40.0
        
        // 建立关系
        apple.children = [redApple, greenApple]
        redApple.parent = apple
        greenApple.parent = apple
        
        fruit.children = [apple]
        apple.parent = fruit
        
        return fruit
    }
}
