//
//  ItemAPIClient.swift
//  ItemManage
//

import Foundation
import HandyJSON

enum ItemAPIError: LocalizedError {
    case invalidURL
    case badStatus(Int, String?)
    case emptyBody
    case notJSON
    case decodeFailed
    case serverMessage(String)
    
    var errorDescription: String? {
        switch self {
        case .serverMessage(let m): return m
        case .badStatus(let c, let b): return b ?? "HTTP \(c)"
        case .decodeFailed: return "数据解析失败"
        default: return "网络错误"
        }
    }
}

final class ItemAPIClient {
    static let shared = ItemAPIClient()
    private let session: URLSession
    
    private init() {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 45
        session = URLSession(configuration: c)
    }
    
    private func url(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        let base = ServerConfiguration.apiBaseURLString
        let p = path.hasPrefix("/") ? String(path.dropFirst()) : path
        guard var comp = URLComponents(string: base + "/" + p) else { return nil }
        if !queryItems.isEmpty {
            comp.queryItems = queryItems
        }
        return comp.url
    }
    
    func perform(
        path: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        jsonBody: [String: Any]? = nil,
        completion: @escaping (Result<Any, Error>) -> Void
    ) {
        guard let u = url(path: path, queryItems: queryItems) else {
            completion(.failure(ItemAPIError.invalidURL))
            return
        }
        var req = URLRequest(url: u)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = AuthSession.shared.token, !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let jsonBody = jsonBody {
            req.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody, options: [])
        }
        
        session.dataTask(with: req) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let http = response as? HTTPURLResponse
            let code = http?.statusCode ?? 0
            let raw = data.flatMap { String(data: $0, encoding: .utf8) }
            
            guard let data = data, !data.isEmpty else {
                if (200...299).contains(code) {
                    completion(.success([:]))
                } else {
                    completion(.failure(ItemAPIError.badStatus(code, raw)))
                }
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) else {
                completion(.failure(ItemAPIError.notJSON))
                return
            }
            
            if let dict = json as? [String: Any], dict["success"] as? Bool == false {
                let msg = dict["error"] as? String ?? "请求失败"
                completion(.failure(ItemAPIError.serverMessage(msg)))
                return
            }
            
            if !(200...299).contains(code) {
                let msg = (json as? [String: Any])?["error"] as? String ?? raw
                completion(.failure(ItemAPIError.badStatus(code, msg)))
                return
            }
            
            completion(.success(json))
        }.resume()
    }
}

// MARK: - HandyJSON helpers
enum ItemJSONMapper {
    static func object<T: HandyJSON>(_ type: T.Type, from any: Any?) -> T? {
        guard let d = any as? [String: Any] else { return nil }
        return T.deserialize(from: d)
    }
    
    static func array<T: HandyJSON>(_ type: T.Type, from any: Any?) -> [T] {
        guard let arr = any as? [[String: Any]] else { return [] }
        return arr.compactMap { T.deserialize(from: $0) }
    }
}
