//
//
//  CategoryModel.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation
import HandyJSON

// MARK: - 单位模型
class UnitModel: HandyJSON {
    var id: String = ""
    var name: String = ""
    var abbreviation: String = ""
    var userId: String?
    var sortOrder: Int = 0
    var isSystem: Bool = false
    var createdAt: Date?
    var updatedAt: Date?
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.id <-- "_id"
    }
    
    static func example() -> UnitModel {
        let unit = UnitModel()
        unit.id = "1"
        unit.name = "个"
        unit.abbreviation = "个"
        unit.isSystem = true
        return unit
    }
}
