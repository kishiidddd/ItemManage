//
//  LocationModel.swift
//  ItemManage
//
//  Created by a on 2026/3/24.
//
import Foundation
import HandyJSON

// MARK: - 一级位置模型
class PrimaryLocationModel: HandyJSON {
    var id: String = ""
    var name: String = ""
    var icon: String = "📍"
    var color: String = "#2196F3"
    var userId: String?
    var sortOrder: Int = 0
    var isSystem: Bool = false
    var createdAt: Date?
    var updatedAt: Date?
    
    // 关联的二级位置
    var secondaryLocations: [SecondaryLocationModel]?
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.id <-- "_id"
    }
    
    static func example() -> PrimaryLocationModel {
        let location = PrimaryLocationModel()
        location.id = "1"
        location.name = "冰箱"
        location.icon = "❄️"
        location.color = "#2196F3"
        location.isSystem = true
        return location
    }
}

// MARK: - 二级位置模型
class SecondaryLocationModel: HandyJSON {
    var id: String = ""
    var name: String = ""
    var primaryLocationId: String = ""
    var icon: String = "📦"
    var color: String = "#4CAF50"
    var userId: String?
    var sortOrder: Int = 0
    var isSystem: Bool = false
    var createdAt: Date?
    var updatedAt: Date?
    
    // 关联的一级位置（用于UI展示）
    var primaryLocation: PrimaryLocationModel?
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.id <-- "_id"
        mapper <<< self.primaryLocationId <-- "primaryLocationId"
    }
    
    static func example() -> SecondaryLocationModel {
        let location = SecondaryLocationModel()
        location.id = "1"
        location.name = "冷藏室"
        location.primaryLocationId = "1"
        location.icon = "🥶"
        location.color = "#4CAF50"
        location.isSystem = true
        return location
    }
}

