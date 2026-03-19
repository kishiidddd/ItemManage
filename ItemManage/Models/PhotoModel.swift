//
//
//  CategoryModel.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation
import HandyJSON

// MARK: - 照片模型
class PhotoModel: HandyJSON {
    var url: String = ""
    var filename: String = ""
    var sortOrder: Int = 0
    var uploadedAt: Date = Date()
    var localPath: String?  // 本地临时路径，用于新上传的照片
    
    required init() {}
    
    // 用于创建新照片
    convenience init(localPath: String, sortOrder: Int) {
        self.init()
        self.localPath = localPath
        self.sortOrder = sortOrder
        self.uploadedAt = Date()
    }
}
