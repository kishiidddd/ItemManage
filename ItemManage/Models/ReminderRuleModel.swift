//
//
//  CategoryModel.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation
import HandyJSON


// MARK: - 提醒规则模型
class ReminderRuleModel: HandyJSON {
    var id: String = ""
    var name: String = ""
    var daysBefore: Int?
    var desc: String = ""
    var sortOrder: Int = 0
    var isSystem: Bool = true
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.id <-- "_id"
            self.desc <-- "description"  // 因为 description 是 Swift 保留关键字
    }
    
    static func example() -> ReminderRuleModel {
        let rule = ReminderRuleModel()
        rule.id = "1"
        rule.name = "提前3天"
        rule.daysBefore = 3
        rule.desc = "过期前3天提醒"
        return rule
    }
}
