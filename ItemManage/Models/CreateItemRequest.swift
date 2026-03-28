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
//
//// MARK: - 创建物品的请求模型
//class CreateItemRequest: HandyJSON {
//    var name: String = ""
//    var categoryId: String = ""
//    var quantity: Int = 1
//    var totalPrice: Double?
//    var unitId: String?
//    var productionDate: Date?
//    var expiryDate: Date?
//    var reminder: [String: Any]?
//    var remarks: String?
//    var level:Int = 3
//    var parentId:String?
//    var shelfLife:Int?
//    var photos: [String] = []  // 照片URL或base64
//    
//    required init() {}
//    
//    // 从 ItemModel 转换
//    convenience init(from item: ItemModel) {
//        self.init()
//        self.name = item.name
//        self.categoryId = item.categoryId
//        self.quantity = item.quantity
//        self.totalPrice = item.totalPrice
//        self.unitId = item.unitId
//        self.productionDate = item.productionDate
//        self.expiryDate = item.expiryDate
//        self.remarks = item.remarks
//        
//        // 处理提醒设置
//        if let ruleId = item.reminder.ruleId {
//            self.reminder = [
//                "ruleId": ruleId,
//                "daysBefore": item.reminder.daysBefore ?? NSNull()
//            ]
//        }
//        
//        // 处理照片（这里假设上传后返回URL）
//        self.photos = item.photos.compactMap { $0.url.isEmpty ? nil : $0.url }
//    }
//    
//    // 转换为字典
//    func toDictionary() -> [String: Any] {
//        var dict: [String: Any] = [
//            "name": name,
//            "categoryId": categoryId,
//            "quantity": quantity
//        ]
//        
//        if let totalPrice = totalPrice {
//            dict["totalPrice"] = totalPrice
//        }
//        
//        if let unitId = unitId {
//            dict["unitId"] = unitId
//        }
//        
//        if let productionDate = productionDate {
//            dict["productionDate"] = productionDate.timeIntervalSince1970 * 1000
//        }
//        
//        if let expiryDate = expiryDate {
//            dict["expiryDate"] = expiryDate.timeIntervalSince1970 * 1000
//        }
//        
//        if let reminder = reminder {
//            dict["reminder"] = reminder
//        }
//        
//        if let remarks = remarks, !remarks.isEmpty {
//            dict["remarks"] = remarks
//        }
//        
//        if !photos.isEmpty {
//            dict["photos"] = photos
//        }
//        
//        return dict
//    }
//}
//
//

//
//  CategoryModel.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation
import HandyJSON

// MARK: - 创建物品的请求模型
class CreateItemRequest: HandyJSON {
    var name: String = ""
    var categoryId: String = ""
    var quantity: Int = 1
    var totalPrice: Double?
    var unitId: String?
    
    // 位置相关字段
    var primaryLocationId: String?      // 一级位置ID
    var secondaryLocationId: String?    // 二级位置ID
    
    // 日期相关字段（支持三种方式）
    var productionDate: Date?      // 生产日期
    var shelfLife: Int?            // 保质期（天数）
    var expiryDate: Date?          // 过期日期
    
    var remarks: String?
    var level: Int = 3
    var parentId: String?
    var photos: [String] = []  // 照片URL或base64
    
    required init() {}
    
    // 便捷初始化方法
    convenience init(name: String,
                     categoryId: String,
                     quantity: Int = 1,
                     totalPrice: Double? = nil,
                     unitId: String? = nil,
                     productionDate: Date? = nil,
                     shelfLife: Int? = nil,
                     expiryDate: Date? = nil,
                     remarks: String? = nil,
                     parentId: String? = nil) {
        self.init()
        self.name = name
        self.categoryId = categoryId
        self.quantity = quantity
        self.totalPrice = totalPrice
        self.unitId = unitId
        self.productionDate = productionDate
        self.shelfLife = shelfLife
        self.expiryDate = expiryDate
        self.remarks = remarks
        self.parentId = parentId
    }
    
    // 从 ItemModel 转换
    convenience init(from item: ItemModel) {
        self.init()
        self.name = item.name
        self.categoryId = item.categoryId
        self.quantity = item.quantity
        self.totalPrice = item.totalPrice
        self.unitId = item.unitId
        self.primaryLocationId = item.primaryLocationId
        self.secondaryLocationId = item.secondaryLocationId
        self.productionDate = item.productionDate
        self.shelfLife = item.shelfLife
        self.expiryDate = item.expiryDate
        self.remarks = item.remarks
        
        // 处理照片（这里假设上传后返回URL）
        self.photos = item.photos.compactMap { $0.url.isEmpty ? nil : $0.url }
    }
    
    // 验证日期信息是否完整
    func validateDates() -> (isValid: Bool, message: String?) {
        // 如果用户直接填写了过期日期，直接通过
        if expiryDate != nil {
            return (true, nil)
        }
        
        // 如果需要自动计算，必须同时有生产日期和保质期
        if productionDate != nil && shelfLife != nil {
            return (true, nil)
        }
        
        // 如果只有其中一个，提示不完整
        if productionDate != nil || shelfLife != nil {
            return (false, "请同时填写生产日期和保质期，或直接填写过期日期")
        }
        
        // 都没有填写，表示无过期信息，也通过
        return (true, nil)
    }
    
    // 获取最终的过期日期（自动计算如果必要）
    func getFinalExpiryDate() -> Date? {
        // 优先使用直接填写的过期日期
        if let expiryDate = expiryDate {
            return expiryDate
        }
        
        // 如果有生产日期和保质期，自动计算
        if let productionDate = productionDate, let shelfLife = shelfLife {
            return Calendar.current.date(byAdding: .day, value: shelfLife, to: productionDate)
        }
        
        return nil
    }
    
    // 获取日期信息描述
    func getDateInfoDescription() -> String {
        if let expiryDate = expiryDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "过期日期: \(formatter.string(from: expiryDate))"
        }
        
        if let productionDate = productionDate, let shelfLife = shelfLife {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "生产日期: \(formatter.string(from: productionDate)), 保质期: \(shelfLife)天"
        }
        
        if let productionDate = productionDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "生产日期: \(formatter.string(from: productionDate))"
        }
        
        if let shelfLife = shelfLife {
            return "保质期: \(shelfLife)天"
        }
        
        return "无过期信息"
    }
    
    // 转换为字典（用于API请求）
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "categoryId": categoryId,
            "quantity": quantity,
            "level": level
        ]
        
        if let totalPrice = totalPrice {
            dict["totalPrice"] = totalPrice
        }
        
        if let unitId = unitId {
            dict["unitId"] = unitId
        }
        
        if let pid = primaryLocationId, !pid.isEmpty {
            dict["primaryLocationId"] = pid
        }
        if let sid = secondaryLocationId, !sid.isEmpty {
            dict["secondaryLocationId"] = sid
        }
        
        // 根据用户输入方式决定传递哪些字段
        if let expiryDate = expiryDate {
            // 用户直接填写了过期日期
            dict["expiryDate"] = expiryDate.timeIntervalSince1970 * 1000
            if let productionDate = productionDate {
                dict["productionDate"] = productionDate.timeIntervalSince1970 * 1000
            }
            if let shelfLife = shelfLife {
                dict["shelfLife"] = shelfLife
            }
        } else if let productionDate = productionDate, let shelfLife = shelfLife {
            // 用户填写了生产日期和保质期
            dict["productionDate"] = productionDate.timeIntervalSince1970 * 1000
            dict["shelfLife"] = shelfLife
            // 计算过期日期并传递
            if let calculatedExpiry = getFinalExpiryDate() {
                dict["expiryDate"] = calculatedExpiry.timeIntervalSince1970 * 1000
            }
        } else {
            // 无过期信息或信息不完整
            if let productionDate = productionDate {
                dict["productionDate"] = productionDate.timeIntervalSince1970 * 1000
            }
            if let shelfLife = shelfLife {
                dict["shelfLife"] = shelfLife
            }
        }
        
        if let remarks = remarks, !remarks.isEmpty {
            dict["remarks"] = remarks
        }
        
        if let parentId = parentId, !parentId.isEmpty {
            dict["parentId"] = parentId
        }
        
        if !photos.isEmpty {
            dict["photos"] = photos
        }
        
        return dict
    }
}

// MARK: - 更新物品的请求模型
class UpdateItemRequest: HandyJSON {
    var name: String?
    var categoryId: String?
    var quantity: Int?
    var totalPrice: Double?
    var unitId: String?
    var primaryLocationId: String?
    var secondaryLocationId: String?
    var productionDate: Date?
    var shelfLife: Int?
    var expiryDate: Date?
    var remarks: String?
    var parentId: String?
    var photos: [String]?
    
    required init() {}
    
    // 从 ItemModel 转换
    convenience init(from item: ItemModel) {
        self.init()
        self.name = item.name
        self.categoryId = item.categoryId
        self.quantity = item.quantity
        self.totalPrice = item.totalPrice
        self.unitId = item.unitId
        self.primaryLocationId = item.primaryLocationId
        self.secondaryLocationId = item.secondaryLocationId
        self.productionDate = item.productionDate
        self.shelfLife = item.shelfLife
        self.expiryDate = item.expiryDate
        self.remarks = item.remarks
        
        // 处理照片
        if !item.photos.isEmpty {
            self.photos = item.photos.compactMap { $0.url.isEmpty ? nil : $0.url }
        }
    }
    
    // 验证日期信息
    func validateDates() -> (isValid: Bool, message: String?) {
        // 如果有过期日期，直接通过
        if expiryDate != nil {
            return (true, nil)
        }
        
        // 如果有生产日期和保质期，通过
        if productionDate != nil && shelfLife != nil {
            return (true, nil)
        }
        
        // 如果只有一个，提示不完整
        if productionDate != nil || shelfLife != nil {
            return (false, "请同时填写生产日期和保质期，或直接填写过期日期")
        }
        
        return (true, nil)
    }
    
    // 转换为字典
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if let name = name {
            dict["name"] = name
        }
        
        if let categoryId = categoryId {
            dict["categoryId"] = categoryId
        }
        
        if let quantity = quantity {
            dict["quantity"] = quantity
        }
        
        if let totalPrice = totalPrice {
            dict["totalPrice"] = totalPrice
        }
        
        if let unitId = unitId {
            dict["unitId"] = unitId
        }
        
        if let pid = primaryLocationId, !pid.isEmpty {
            dict["primaryLocationId"] = pid
        }
        if let sid = secondaryLocationId, !sid.isEmpty {
            dict["secondaryLocationId"] = sid
        }
        
        // 处理日期
        if let expiryDate = expiryDate {
            dict["expiryDate"] = expiryDate.timeIntervalSince1970 * 1000
            if let productionDate = productionDate {
                dict["productionDate"] = productionDate.timeIntervalSince1970 * 1000
            }
            if let shelfLife = shelfLife {
                dict["shelfLife"] = shelfLife
            }
        } else if let productionDate = productionDate, let shelfLife = shelfLife {
            dict["productionDate"] = productionDate.timeIntervalSince1970 * 1000
            dict["shelfLife"] = shelfLife
            // 计算过期日期
            if let calculatedExpiry = Calendar.current.date(byAdding: .day, value: shelfLife, to: productionDate) {
                dict["expiryDate"] = calculatedExpiry.timeIntervalSince1970 * 1000
            }
        } else {
            if let productionDate = productionDate {
                dict["productionDate"] = productionDate.timeIntervalSince1970 * 1000
            }
            if let shelfLife = shelfLife {
                dict["shelfLife"] = shelfLife
            }
        }
        
        if let remarks = remarks {
            dict["remarks"] = remarks
        }
        
        if let parentId = parentId {
            dict["parentId"] = parentId
        }
        
        if let photos = photos {
            dict["photos"] = photos
        }
        
        return dict
    }
}
