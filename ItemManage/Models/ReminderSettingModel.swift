//
//
//  CategoryModel.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation
import HandyJSON


// MARK: - 提醒设置模型
class ReminderSettingModel: HandyJSON {
    var ruleId: String?
    var rule: ReminderRuleModel?  // 关联的完整规则对象
    var daysBefore: Int?
    var isNotified: Bool = false
    
    required init() {}
    
    // 是否启用提醒
    var isEnabled: Bool {
        return ruleId != nil && !(ruleId?.isEmpty ?? true)
    }
    
    // 获取提醒描述
    var reminderDescription: String {
        if let rule = rule {
            return rule.name
        } else if let days = daysBefore {
            return "提前\(days)天"
        }
        return "不提醒"
    }
    
    static func `default`() -> ReminderSettingModel {
        return ReminderSettingModel()
    }
}
