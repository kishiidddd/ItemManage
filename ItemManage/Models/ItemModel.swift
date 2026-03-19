//
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
    
    // 关联对象（用于UI展示）
    var category: CategoryModel?
    var unit: UnitModel?
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.id <-- "_id"
        
        // 处理日期格式
        mapper <<< self.productionDate <-- "productionDate"
        mapper <<< self.expiryDate <-- "expiryDate"
        mapper <<< self.createdAt <-- "createdAt"
        mapper <<< self.updatedAt <-- "updatedAt"
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
        
        return item
    }
}
