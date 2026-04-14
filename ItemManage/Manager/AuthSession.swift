//
//  AuthSession.swift
//  ItemManage
//

import Foundation

final class AuthSession {
    static let shared = AuthSession()

    private enum Key {
        static let token = "authToken"
        static let userId = "authUserId"
        static let username = "username"
        static let isLoggedIn = "isLoggedIn"
    }

    private init() {}

    var token: String? {
        UserDefaults.standard.string(forKey: Key.token)
    }

    var userId: String? {
        UserDefaults.standard.string(forKey: Key.userId)
    }

    var username: String? {
        UserDefaults.standard.string(forKey: Key.username)
    }

    var isLoggedIn: Bool {
        guard let t = token, !t.isEmpty else { return false }
        return UserDefaults.standard.bool(forKey: Key.isLoggedIn)
    }

    func saveLogin(token: String, userId: String, username: String) {
        UserDefaults.standard.set(token, forKey: Key.token)
        UserDefaults.standard.set(userId, forKey: Key.userId)
        UserDefaults.standard.set(username, forKey: Key.username)
        UserDefaults.standard.set(true, forKey: Key.isLoggedIn)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: Key.token)
        UserDefaults.standard.removeObject(forKey: Key.userId)
        UserDefaults.standard.removeObject(forKey: Key.username)
        UserDefaults.standard.set(false, forKey: Key.isLoggedIn)
    }
}
