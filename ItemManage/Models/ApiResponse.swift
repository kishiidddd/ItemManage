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

class PaginationModel: HandyJSON {
    var page: Int = 1
    var limit: Int = 20
    var total: Int = 0
    var pages: Int = 0
    var hasNextPage:Bool = false
    
    required init() {}
}
