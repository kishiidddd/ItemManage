//
//  BackendDateTransform.swift
//  ItemManage
//
//  服务端 JSON：Express 将 Date 序列化为 ISO8601 字符串；创建接口也可能传毫秒时间戳。
//

import Foundation
import HandyJSON

/// 将 API 中的日期字段转为 `Date`（兼容 ISO8601 字符串、秒/毫秒时间戳）
final class BackendDateTransform: TransformType {
    init() {}
    func transformFromJSON(_ value: Any?) -> Date? {
        BackendDateTransform.parse(value)
    }

    func transformToJSON(_ value: Date?) -> Double? {
        value.map { $0.timeIntervalSince1970 }
    }

    static func parse(_ value: Any?) -> Date? {
        guard let value = value, !(value is NSNull) else { return nil }

        if let d = value as? Double {
            return fromNumeric(d)
        }
        if let n = value as? NSNumber {
            return fromNumeric(n.doubleValue)
        }
        if let s = value as? String, !s.isEmpty {
            if let n = Double(s), n > 1_000_000_000 {
                return fromNumeric(n)
            }
            return parseISO8601(s)
        }
        return nil
    }

    private static func fromNumeric(_ d: Double) -> Date? {
        guard d.isFinite, d != 0 else { return nil }
        if d > 1_000_000_000_000 {
            return Date(timeIntervalSince1970: d / 1000.0)
        }
        if d > 1_000_000_000 {
            return Date(timeIntervalSince1970: d)
        }
        return nil
    }

    private static func parseISO8601(_ s: String) -> Date? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: s) { return d }
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: s) { return d }

        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        if let d = f.date(from: s) { return d }
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return f.date(from: s)
    }
}

/// `createdAt` / `updatedAt` 等非可选字段：解析失败时用当前时间，避免整项反序列化失败
struct BackendRequiredDateTransform: TransformType {
    func transformFromJSON(_ value: Any?) -> Date? {
        BackendDateTransform.parse(value) ?? Date()
    }

    func transformToJSON(_ value: Date?) -> Double? {
        value.map { $0.timeIntervalSince1970 }
    }
}
