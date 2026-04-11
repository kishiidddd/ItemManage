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
    /// 部分接口使用 `imageUrl` 等与 `url` 不同的字段
    var imageUrl: String = ""
    var filename: String = ""
    var sortOrder: Int = 0
    var uploadedAt: Date = Date()
    var localPath: String?  // 本地临时路径，用于新上传的照片；不参与服务端 JSON 时可保留在内存

    required init() {}

    func mapping(mapper: HelpingMapper) {
        mapper <<< self.url <-- "url"
        mapper <<< self.imageUrl <-- "imageUrl"
    }

    func didFinishMapping() {
        if url.isEmpty && !imageUrl.isEmpty {
            url = imageUrl
        }
    }

    /// 用于加载网络图（已兼容 didFinishMapping 合并到 `url`）
    var remoteURLString: String {
        if !url.isEmpty { return url }
        return imageUrl
    }
    
    // 用于创建新照片
    convenience init(localPath: String, sortOrder: Int) {
        self.init()
        self.localPath = localPath
        self.sortOrder = sortOrder
        self.uploadedAt = Date()
    }
}
