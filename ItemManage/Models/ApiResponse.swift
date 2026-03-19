//
//
//  CategoryModel.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation
import HandyJSON

// MARK: - API 响应模型
class ApiResponse<T: HandyJSON>: HandyJSON {
    var success: Bool = false
    var data: T?
    var message: String?
    var code: Int = 200
    
    required init() {}
}

class ItemsListResponse: HandyJSON {
    var items: [ItemModel] = []
    var pagination: PaginationModel?
    
    required init() {}
}

// 实际返回的JSON数据示例
//{
//    "items": [
//        { "id": "1", "name": "苹果", ... },
//        { "id": "2", "name": "牛奶", ... },
//        { "id": "3", "name": "面包", ... }
//        // ... 共20条数据
//    ],
//    "pagination": {
//        "page": 1,        // 当前第1页
//        "limit": 20,      // 每页20条
//        "total": 156,     // 总共156条记录
//        "pages": 8        // 总共8页
//    }
//}

class PaginationModel: HandyJSON {
    var page: Int = 1
    var limit: Int = 20
    var total: Int = 0
    var pages: Int = 0
    var hasNextPage:Bool = false
    
    required init() {}
}
