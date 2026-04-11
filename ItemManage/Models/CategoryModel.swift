//
//  CategoryModel.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation
import HandyJSON

// MARK: - 分类模型
class CategoryModel: HandyJSON {
    var id: String = ""
    var name: String = ""
    var icon: String = "📦"
    var color: String = "#4CAF50"
    var userId: String?
    var sortOrder: Int = 0
    var isSystem: Bool = false
    var itemCount: Int = 0
    var createdAt: Date?
    var updatedAt: Date?
    
    required init() {}
    
    // 自定义映射（如果服务器返回的字段名不同）
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.id <-- "_id"  // 如果服务器返回的是 _id
    }
}
