//
//  UIViewController+.swift
//  FebruaryWeather
//
//  Created by a on 2026/2/4.
//

import UIKit

extension UIViewController {
    static var current: UIViewController? {
        return getCurrent(base: UIApplication.shared.connectedScenes
                            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                            .first?.rootViewController)
    }
    
    private static func getCurrent(base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getCurrent(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return getCurrent(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return getCurrent(base: presented)
        }
        return base
    }
}
