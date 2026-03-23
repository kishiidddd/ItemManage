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
//    // 层级关系属性
//    var parentId: String?          // 父物品ID
//    var level: Int = 1              // 当前层级（1-3）
//    var children: [ItemModel]?      // 子物品数组
//    
//    // 关联对象（用于UI展示）
//    var category: CategoryModel?
//    var unit: UnitModel?
//    var parent: ItemModel?          // 父物品对象（可选，避免循环引用）
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
//        
//        // 处理层级关系
//        mapper <<< self.parentId <-- "parentId"
//        mapper <<< self.level <-- "level"
//        mapper <<< self.children <-- "children"
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
//    // 计算属性：是否有子物品
//    var hasChildren: Bool {
//        return children?.isEmpty == false
//    }
//    
//    // 计算属性：是否是顶级物品
//    var isTopLevel: Bool {
//        return parentId == nil || parentId?.isEmpty == true
//    }
//    
//    // 计算属性：是否是叶子节点（没有子物品）
//    var isLeaf: Bool {
//        return !hasChildren
//    }
//    
//    // 方法：添加子物品
//    func addChild(_ child: ItemModel) {
//        if children == nil {
//            children = []
//        }
//        
//        child.parentId = self.id
//        child.parent = self
//        child.level = self.level + 1
//        
//        // 限制最多三级
//        if child.level <= 3 {
//            children?.append(child)
//        }
//    }
//    
//    // 方法：移除子物品
//    func removeChild(_ child: ItemModel) {
//        children?.removeAll { $0.id == child.id }
//        child.parentId = nil
//        child.parent = nil
//    }
//    
//    // 方法：获取所有子物品（递归）
//    func getAllChildren() -> [ItemModel] {
//        var allChildren: [ItemModel] = []
//        
//        if let children = children {
//            allChildren.append(contentsOf: children)
//            
//            for child in children {
//                allChildren.append(contentsOf: child.getAllChildren())
//            }
//        }
//        
//        return allChildren
//    }
//    
//    // 方法：获取层级路径
//    func getPath() -> [ItemModel] {
//        var path: [ItemModel] = [self]
//        var current = self.parent
//        
//        while let parent = current {
//            path.insert(parent, at: 0)
//            current = parent.parent
//        }
//        
//        return path
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
//        // 添加子物品示例
//        let child1 = ItemModel()
//        child1.id = "1-1"
//        child1.name = "红苹果"
//        child1.parentId = item.id
//        child1.level = 2
//        
//        let child2 = ItemModel()
//        child2.id = "1-2"
//        child2.name = "青苹果"
//        child2.parentId = item.id
//        child2.level = 2
//        
//        // 添加孙物品示例
//        let grandChild = ItemModel()
//        grandChild.id = "1-1-1"
//        grandChild.name = "新疆红苹果"
//        grandChild.parentId = child1.id
//        grandChild.level = 3
//        
//        child1.children = [grandChild]
//        grandChild.parent = child1
//        
//        item.children = [child1, child2]
//        child1.parent = item
//        child2.parent = item
//        
//        return item
//    }
//    
//    // 示例数据：创建三层级结构的物品
//    static func exampleWithThreeLevels() -> ItemModel {
//        // 第一级：水果
//        let fruit = ItemModel()
//        fruit.id = "1"
//        fruit.name = "水果"
//        fruit.level = 1
//        
//        // 第二级：苹果类别
//        let apple = ItemModel()
//        apple.id = "1-1"
//        apple.name = "苹果"
//        apple.parentId = fruit.id
//        apple.level = 2
//        
//        // 第三级：具体苹果品种
//        let redApple = ItemModel()
//        redApple.id = "1-1-1"
//        redApple.name = "红富士苹果"
//        redApple.parentId = apple.id
//        redApple.level = 3
//        redApple.quantity = 10
//        redApple.totalPrice = 50.0
//        
//        let greenApple = ItemModel()
//        greenApple.id = "1-1-2"
//        greenApple.name = "青苹果"
//        greenApple.parentId = apple.id
//        greenApple.level = 3
//        greenApple.quantity = 8
//        greenApple.totalPrice = 40.0
//        
//        // 建立关系
//        apple.children = [redApple, greenApple]
//        redApple.parent = apple
//        greenApple.parent = apple
//        
//        fruit.children = [apple]
//        apple.parent = fruit
//        
//        return fruit
//    }
//}

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
    
    // 日期相关字段
    var productionDate: Date?      // 生产日期
    var expiryDate: Date?          // 过期日期
    var shelfLife: Int?            // 保质期（天数）
    
    var reminder: ReminderSettingModel = ReminderSettingModel()
    var remarks: String?
    var status: String = "normal"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // 层级关系属性
    var parentId: String?          // 父物品ID
    var level: Int = 3              // 当前层级（1-3）
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
    
    // MARK: - 计算属性
    
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
    
    // 计算属性：剩余天数（负数表示已过期）
    var daysUntilExpiry: Int? {
        guard let expiryDate = expiryDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expiryDate)
        return components.day
    }
    
    // 计算属性：是否即将过期（3天内）
    var isExpiringSoon: Bool {
        guard let days = daysUntilExpiry else { return false }
        return days >= 0 && days <= 3
    }
    
    // 计算属性：过期状态描述
    var expiryStatusDescription: String {
        guard let days = daysUntilExpiry else {
            return "无过期时间"
        }
        
        if days < 0 {
            return "已过期\(-days)天"
        } else if days == 0 {
            return "今天过期"
        } else if days <= 3 {
            return "\(days)天后过期（即将过期）"
        } else {
            return "\(days)天后过期"
        }
    }
    
    // 计算属性：过期状态颜色
    var expiryStatusColor: String {
        guard let days = daysUntilExpiry else {
            return "#999999"  // 灰色
        }
        
        if days < 0 {
            return "#FF6B6B"  // 红色
        } else if days <= 3 {
            return "#FFB347"  // 橙色
        } else {
            return "#4CAF50"  // 绿色
        }
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
    
    // MARK: - 日期处理方法
    
    /// 根据生产日期和保质期计算过期日期
    func calculateExpiryDate() {
        guard let productionDate = productionDate,
              let shelfLife = shelfLife,
              shelfLife > 0 else {
            return
        }
        expiryDate = Calendar.current.date(byAdding: .day, value: shelfLife, to: productionDate)
    }
    
    /// 更新保质期时自动重新计算过期日期
    func updateShelfLife(_ days: Int) {
        shelfLife = days
        calculateExpiryDate()
    }
    
    /// 更新生产日期时自动重新计算过期日期
    func updateProductionDate(_ date: Date) {
        productionDate = date
        calculateExpiryDate()
    }
    
    /// 更新过期日期（如果用户直接修改了过期日期）
    func updateExpiryDate(_ date: Date) {
        expiryDate = date
        // 注意：如果用户直接修改了过期日期，生产日期和保质期的关联会被打破
        // 我们可以选择不清空它们，但需要标记这是一个直接设置的过期日期
    }
    
    /// 检查日期信息完整性
    func validateDates() -> DateValidationResult {
        if let expiryDate = expiryDate {
            // 用户直接填了过期日期
            return .hasExpiryDate(expiryDate)
        } else if let productionDate = productionDate, let shelfLife = shelfLife {
            // 用户填了生产日期和保质期，自动计算
            let calculatedExpiry = Calendar.current.date(byAdding: .day, value: shelfLife, to: productionDate)
            return .calculated(productionDate: productionDate, shelfLife: shelfLife, expiryDate: calculatedExpiry)
        } else if productionDate != nil || shelfLife != nil {
            // 只填了其中一个，数据不完整
            return .incomplete
        } else {
            // 都没有填写，无过期信息
            return .noExpiryInfo
        }
    }
    
    /// 智能更新日期信息
    func updateDateInfo(productionDate: Date? = nil, shelfLife: Int? = nil, expiryDate: Date? = nil) {
        // 优先使用直接填写的过期日期
        if let expiryDate = expiryDate {
            self.expiryDate = expiryDate
            // 如果用户同时提供了生产日期和保质期，也保存它们
            if let productionDate = productionDate {
                self.productionDate = productionDate
            }
            if let shelfLife = shelfLife {
                self.shelfLife = shelfLife
            }
        }
        // 如果没有过期日期，但有生产日期和保质期，则自动计算
        else if let productionDate = productionDate, let shelfLife = shelfLife {
            self.productionDate = productionDate
            self.shelfLife = shelfLife
            calculateExpiryDate()
        }
        // 只有生产日期或只有保质期，则保存但无法计算过期日期
        else {
            if let productionDate = productionDate {
                self.productionDate = productionDate
            }
            if let shelfLife = shelfLife {
                self.shelfLife = shelfLife
            }
        }
    }
    
    /// 获取格式化的生产日期字符串
    func formattedProductionDate(format: String = "yyyy-MM-dd") -> String {
        guard let productionDate = productionDate else { return "未设置" }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: productionDate)
    }
    
    /// 获取格式化的过期日期字符串
    func formattedExpiryDate(format: String = "yyyy-MM-dd") -> String {
        guard let expiryDate = expiryDate else { return "未设置" }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: expiryDate)
    }
    
    /// 获取保质期描述
    var shelfLifeDescription: String {
        guard let shelfLife = shelfLife else { return "未设置" }
        return "\(shelfLife)天"
    }
    
    /// 获取完整的日期信息描述
    var dateInfoDescription: String {
        let validation = validateDates()
        switch validation {
        case .hasExpiryDate(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "过期日期: \(formatter.string(from: date))"
        case .calculated(let productionDate, let shelfLife, let expiryDate):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            var description = "生产日期: \(formatter.string(from: productionDate)), 保质期: \(shelfLife)天"
            if let expiryDate = expiryDate {
                description += ", 过期日期: \(formatter.string(from: expiryDate))"
            }
            return description
        case .incomplete:
            return "日期信息不完整"
        case .noExpiryInfo:
            return "无过期信息"
        }
    }
    
    // MARK: - 层级关系方法
    
    /// 添加子物品
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
    
    /// 移除子物品
    func removeChild(_ child: ItemModel) {
        children?.removeAll { $0.id == child.id }
        child.parentId = nil
        child.parent = nil
    }
    
    /// 获取所有子物品（递归）
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
    
    /// 获取层级路径
    func getPath() -> [ItemModel] {
        var path: [ItemModel] = [self]
        var current = self.parent
        
        while let parent = current {
            path.insert(parent, at: 0)
            current = parent.parent
        }
        
        return path
    }
}

// MARK: - 日期验证结果枚举
enum DateValidationResult {
    case hasExpiryDate(Date)           // 直接有过期日期
    case calculated(productionDate: Date, shelfLife: Int, expiryDate: Date?) // 自动计算
    case incomplete                    // 数据不完整（只有生产日期或只有保质期）
    case noExpiryInfo                  // 无过期信息
}

// MARK: - 日期信息模型
class DateInfoModel: HandyJSON {
    var productionDate: Date?
    var expiryDate: Date?
    var shelfLife: Int?
    var hasExpiryInfo: Bool = false
    var isCalculated: Bool = false      // 是否是自动计算的
    
    required init() {}
    
    convenience init(productionDate: Date? = nil, expiryDate: Date? = nil, shelfLife: Int? = nil) {
        self.init()
        self.productionDate = productionDate
        self.expiryDate = expiryDate
        self.shelfLife = shelfLife
        self.hasExpiryInfo = expiryDate != nil || shelfLife != nil
    }
    
    // 验证日期信息是否完整
    func isValid() -> Bool {
        if expiryDate != nil {
            return true
        }
        if productionDate != nil && shelfLife != nil {
            return true
        }
        return false
    }
    
    // 获取显示文本
    func getDisplayText() -> String {
        if let expiryDate = expiryDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "过期: \(formatter.string(from: expiryDate))"
        }
        
        if let productionDate = productionDate, let shelfLife = shelfLife {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "生产: \(formatter.string(from: productionDate)), 保质: \(shelfLife)天"
        }
        
        if let productionDate = productionDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "生产: \(formatter.string(from: productionDate))"
        }
        
        if let shelfLife = shelfLife {
            return "保质: \(shelfLife)天"
        }
        
        return "无过期信息"
    }
}
