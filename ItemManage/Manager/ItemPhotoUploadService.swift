//
//  ItemPhotoUploadService.swift — 最小实现：POST …/api/upload/photo，字段 file
//

import Foundation

enum ItemPhotoUploadService {
    /// 上传本地文件，返回服务端给出的图片 URL
    static func upload(fileURL: URL) async throws -> String {
        guard let url = uploadURL() else {
            throw NSError(domain: "Upload", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的上传地址"])
        }
        let fileData = try Data(contentsOf: fileURL)
        let boundary = UUID().uuidString
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let token = AuthSession.shared.token, !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let filename = fileURL.lastPathComponent
        let partMime = mimeType(for: filename)
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        // 必须带 part 的 Content-Type，否则常为 application/octet-stream，服务端 multer 会拒掉
        body.append("Content-Type: \(partMime)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "Upload", code: -2, userInfo: [NSLocalizedDescriptionKey: "无有效响应"])
        }
        guard (200...299).contains(http.statusCode) else {
            let hint = String(data: data, encoding: .utf8).map { String($0.prefix(300)) } ?? ""
            throw NSError(domain: "Upload", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode) \(hint)"])
        }
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              obj["success"] as? Bool != false,
              let d = obj["data"] as? [String: Any],
              let s = d["url"] as? String, !s.isEmpty else {
            let hint = String(data: data, encoding: .utf8).map { String($0.prefix(300)) } ?? ""
            throw NSError(domain: "Upload", code: -3,
                          userInfo: [NSLocalizedDescriptionKey: "响应格式异常: \(hint)"])
        }
        return s
    }

    private static func mimeType(for filename: String) -> String {
        switch filename.lowercased() {
        case let n where n.hasSuffix(".png"): return "image/png"
        case let n where n.hasSuffix(".gif"): return "image/gif"
        case let n where n.hasSuffix(".webp"): return "image/webp"
        case let n where n.hasSuffix(".heic") || n.hasSuffix(".heif"): return "image/heic"
        default: return "image/jpeg"
        }
    }

    /// `apiBaseURLString` 形如 `http://host:3000` 或 `http://host:3000/api`
    private static func uploadURL() -> URL? {
        var b = ServerConfiguration.apiBaseURLString
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .trimmingCharacters(in: .whitespaces)
        while b.hasSuffix("/") { b.removeLast() }
        if !b.lowercased().hasSuffix("/api") { b += "/api" }
        return URL(string: b + "/upload/photo")
    }
}
