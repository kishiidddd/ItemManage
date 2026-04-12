//
//  StorageGuideSupport.swift
//  ItemManage — 收纳指南条目与收藏存储（最多 8 条）
//

import Foundation

struct StorageGuideItem: Codable, Equatable {
    let id: String
    let title: String
    let body: String
}

enum StorageGuideCatalog {
    static let tips: [StorageGuideItem] = [
        StorageGuideItem(id: "zoning", title: "分区存放", body: "按使用场景划区：厨房、卧室、玄关等；重物放低处，轻物与常用放顺手高度。"),
        StorageGuideItem(id: "vertical", title: "垂直空间", body: "层架、挂钩、门后收纳袋，把墙面和柜内纵向空间用起来。"),
        StorageGuideItem(id: "labels", title: "透明与标签", body: "密闭盒可贴标签或用手机拍照封面，减少翻找时间。"),
        StorageGuideItem(id: "oneinoneout", title: "进一出一", body: "新购物品入库前，考虑淘汰一件同类，控制总量。"),
        StorageGuideItem(id: "expiry", title: "过期管理", body: "结合本 App 的过期提醒，定期清理食品与耗材，避免积压。")
    ]

    static func item(id: String) -> StorageGuideItem? {
        tips.first { $0.id == id }
    }
}

extension Notification.Name {
    static let storageGuideFavoritesDidChange = Notification.Name("storageGuideFavoritesDidChange")
}

enum StorageGuideFavoriteError: LocalizedError {
    case limitReached

    var errorDescription: String? {
        switch self {
        case .limitReached: return "最多只能收藏 8 条"
        }
    }
}

final class StorageGuideFavoritesStore {
    static let shared = StorageGuideFavoritesStore()
    static let maxFavorites = 8

    private let key = "StorageGuideFavoriteIds"

    private init() {}

    var favoriteIds: [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    var count: Int { favoriteIds.count }

    func isFavorite(id: String) -> Bool {
        favoriteIds.contains(id)
    }

    /// 设为收藏或取消；新增时若已满则失败
    func setFavorite(id: String, starred: Bool) -> Result<Void, StorageGuideFavoriteError> {
        var ids = favoriteIds
        if starred {
            if ids.contains(id) {
                UserDefaults.standard.set(ids, forKey: key)
                postChange()
                return .success(())
            }
            guard ids.count < Self.maxFavorites else { return .failure(.limitReached) }
            ids.append(id)
        } else {
            ids.removeAll { $0 == id }
        }
        UserDefaults.standard.set(ids, forKey: key)
        postChange()
        return .success(())
    }

    func orderedFavoriteItems() -> [StorageGuideItem] {
        favoriteIds.compactMap { StorageGuideCatalog.item(id: $0) }
    }

    private func postChange() {
        NotificationCenter.default.post(name: .storageGuideFavoritesDidChange, object: nil)
    }
}
