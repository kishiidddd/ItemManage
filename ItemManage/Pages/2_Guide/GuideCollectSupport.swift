//
//  StorageGuideSupport.swift
//  ItemManage — 收纳指南条目、网络拉取、收藏（本地存标题+正文，最多 8 条）
//

import Foundation

struct GuideCollectItem: Codable, Equatable {
    let title: String
    let body: String
    /// 首页 / 指南页顶部主推；未返回该字段时视为 false
    let showInMain: Bool

    init(title: String, body: String, showInMain: Bool = false) {
        self.title = title
        self.body = body
        self.showInMain = showInMain
    }

    /// 第一个 `showInMain == true` 的条目，否则取列表第一条
    static func spotlight(in items: [GuideCollectItem]) -> GuideCollectItem? {
        guard let first = items.first else { return nil }
        return items.first { $0.showInMain } ?? first
    }
}

/// 收藏条目：仅存标题与正文
struct GuideCollectEntry: Codable, Equatable {
    let title: String
    let body: String
}

/// 离线兜底（请求失败且尚未成功拉取过服务端时使用）
enum GuideCollectCatalog {
    static let fallbackTips: [GuideCollectItem] = [
        GuideCollectItem(title: "分区存放", body: "按使用场景划区：厨房、卧室、玄关等；重物放低处，轻物与常用放顺手高度。", showInMain: true),
        GuideCollectItem(title: "垂直空间", body: "层架、挂钩、门后收纳袋，把墙面和柜内纵向空间用起来。"),
        GuideCollectItem(title: "透明与标签", body: "密闭盒可贴标签或用手机拍照封面，减少翻找时间。"),
        GuideCollectItem(title: "进一出一", body: "新购物品入库前，考虑淘汰一件同类，控制总量。"),
        GuideCollectItem(title: "过期管理", body: "结合本 App 的过期提醒，定期清理食品与耗材，避免积压。")
    ]
}

// MARK: - 当前展示数据（以服务端为准，成功拉取后有几条显示几条）

enum GuideCollectRuntimeData {
    private static let lock = NSLock()
    private static var loadedFromServer = false
    private static var serverItems: [GuideCollectItem] = []

    static var displayItems: [GuideCollectItem] {
        lock.lock()
        defer { lock.unlock() }
        if loadedFromServer { return serverItems }
        return GuideCollectCatalog.fallbackTips
    }

    static func applyServerItems(_ items: [GuideCollectItem]) {
        lock.lock()
        defer { lock.unlock() }
        loadedFromServer = true
        serverItems = items
    }
}

// MARK: - API

enum GuideCollectAPI {
    static func fetchTips(completion: @escaping (Result<[GuideCollectItem], Error>) -> Void) {
        ItemAPIClient.shared.perform(path: "storage-guide/tips", method: "GET") { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success(let any):
                guard let dict = any as? [String: Any],
                      let data = dict["data"] as? [String: Any],
                      let arr = data["items"] as? [[String: Any]] else {
                    completion(.failure(ItemAPIError.decodeFailed))
                    return
                }
                let items: [GuideCollectItem] = arr.compactMap { o in
                    guard let title = o["title"] as? String,
                          let body = o["body"] as? String else { return nil }
                    let show: Bool = {
                        if let b = o["showInMain"] as? Bool { return b }
                        if let n = o["showInMain"] as? NSNumber { return n.boolValue }
                        return false
                    }()
                    return GuideCollectItem(title: title, body: body, showInMain: show)
                }
                completion(.success(items))
            }
        }
    }
}

extension Notification.Name {
    static let storageGuideFavoritesDidChange = Notification.Name("storageGuideFavoritesDidChange")
}

enum GuideCollectError: LocalizedError {
    case limitReached

    var errorDescription: String? {
        switch self {
        case .limitReached: return "最多只能收藏 8 条"
        }
    }
}

final class GuideCollectStore {
    static let shared = GuideCollectStore()
    static let maxFavorites = 8

    /// 与旧版「只存 id」区分，避免解码失败
    private let storageKey = "StorageGuideFavoriteEntriesV1"

    private init() {}

    var entries: [GuideCollectEntry] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let list = try? JSONDecoder().decode([GuideCollectEntry].self, from: data) else {
            return []
        }
        return list
    }

    var count: Int { entries.count }

    func isFavorite(title: String, body: String) -> Bool {
        entries.contains { $0.title == title && $0.body == body }
    }

    func add(title: String, body: String) -> Result<Void, GuideCollectError> {
        var list = entries
        if list.contains(where: { $0.title == title && $0.body == body }) {
            postChange()
            return .success(())
        }
        guard list.count < Self.maxFavorites else { return .failure(.limitReached) }
        list.append(GuideCollectEntry(title: title, body: body))
        save(list)
        postChange()
        return .success(())
    }

    func remove(title: String, body: String) {
        var list = entries
        list.removeAll { $0.title == title && $0.body == body }
        save(list)
        postChange()
    }

    private func save(_ list: [GuideCollectEntry]) {
        guard let data = try? JSONEncoder().encode(list) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func postChange() {
        NotificationCenter.default.post(name: .storageGuideFavoritesDidChange, object: nil)
    }
}
