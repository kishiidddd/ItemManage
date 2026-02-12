//
//  String+.swift
//  FebruaryWeather
//
//  Created by a on 2026/2/4.
//

import SwiftUI

extension UIColor {

    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)

        let r, g, b, a: UInt64
        switch hex.count {
        case 3:
            (r, g, b, a) = (
                (value >> 8) * 17,
                (value >> 4 & 0xF) * 17,
                (value & 0xF) * 17,
                255
            )
        case 6:
            (r, g, b, a) = (
                value >> 16,
                value >> 8 & 0xFF,
                value & 0xFF,
                255
            )
        case 8: // AARRGGBB
            (a, r, g, b) = (
                value >> 24,
                value >> 16 & 0xFF,
                value >> 8 & 0xFF,
                value & 0xFF
            )
        default:
            (r, g, b, a) = (0, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

extension Color {
    init(hex: String, opacity: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var wInt: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&wInt)
        let r, g, b: UInt64
        switch hex.count {
        case 3:
            (r, g, b) = ((wInt >> 8) * 17, (wInt >> 4 & 0xF) * 17, (wInt & 0xF) * 17)
        case 6:
            (r, g, b) = (wInt >> 16, wInt >> 8 & 0xFF, wInt & 0xFF)
        case 8:
            (r, g, b) = (wInt >> 16 & 0xFF, wInt >> 8 & 0xFF, wInt & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: opacity
        )
    }
}

extension UIColor {
    ///主题红色
    static var themeRedColor: UIColor {
        UIColor(hex: "#DC583B")
    }
    
    /// 主体棕色
    static var themeBrownColor: UIColor {
        UIColor(hex: "#824A11")
    }
    
    /// 粽黑色文字
    static var text1Color: UIColor {
        UIColor(hex: "#291700").withAlphaComponent(0.8)
    }
    
    /// 粽黑色文字 浅一点
    static var text2Color: UIColor {
        UIColor(hex: "#291700").withAlphaComponent(0.6)
    }
    
    ///米色弹框背景
    static var ThemeBeigeColor : UIColor {
        UIColor(hex: "#FFE5C3")
    }
    
    ///F9F6ED
    static var lightBgColor : UIColor {
        UIColor(hex: "#F9F6ED")
    }
}
