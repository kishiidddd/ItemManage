//
//  ServerConfiguration.swift
//  ItemManage
//

import Foundation

enum ServerConfiguration {
    /// Info.plist 中 `API_BASE_URL`，例如 `http://127.0.0.1:3000/api`（模拟器连本机）
    /// 真机调试请改为电脑局域网 IP，如 `http://192.168.1.10:3000/api`
    static var apiBaseURLString: String {
        if let s = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return s.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }
        return "http://127.0.0.1:3000/api"
    }
}
