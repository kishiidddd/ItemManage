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
    var productionDate: Date?
    var expiryDate: Date?
    var reminder: [String: Any]?
    var remarks: String?
    var photos: [String] = []  // 照片URL或base64
    
    required init() {}
    
    // 从 ItemModel 转换
    convenience init(from item: ItemModel) {
        self.init()
        self.name = item.name
        self.categoryId = item.categoryId
        self.quantity = item.quantity
        self.totalPrice = item.totalPrice
        self.unitId = item.unitId
        self.productionDate = item.productionDate
        self.expiryDate = item.expiryDate
        self.remarks = item.remarks
        
        // 处理提醒设置
        if let ruleId = item.reminder.ruleId {
            self.reminder = [
                "ruleId": ruleId,
                "daysBefore": item.reminder.daysBefore ?? NSNull()
            ]
        }
        
        // 处理照片（这里假设上传后返回URL）
        self.photos = item.photos.compactMap { $0.url.isEmpty ? nil : $0.url }
    }
    
    // 转换为字典
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "categoryId": categoryId,
            "quantity": quantity
        ]
        
        if let totalPrice = totalPrice {
            dict["totalPrice"] = totalPrice
        }
        
        if let unitId = unitId {
            dict["unitId"] = unitId
        }
        
        if let productionDate = productionDate {
            dict["productionDate"] = productionDate.timeIntervalSince1970 * 1000
        }
        
        if let expiryDate = expiryDate {
            dict["expiryDate"] = expiryDate.timeIntervalSince1970 * 1000
        }
        
        if let reminder = reminder {
            dict["reminder"] = reminder
        }
        
        if let remarks = remarks, !remarks.isEmpty {
            dict["remarks"] = remarks
        }
        
        if !photos.isEmpty {
            dict["photos"] = photos
        }
        
        return dict
    }
}


