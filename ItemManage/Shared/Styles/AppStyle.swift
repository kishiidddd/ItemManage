//
//  AppStyle.swift
//  ItemManage
//
//  Created by xiny on 2025/12/13.
//
import UIKit

struct AppStyle{
    //颜色
    struct Color {
        // 主色调
        static let primaryBlue = UIColor(hex: "#26BFF1")
        static let warmBlue = UIColor(hex: "#1FA8DC")//5DBCEC
        static let lightBule = UIColor(hex: "#ECFAFD")
        
        // 辅助色
        //红色
        static let red = UIColor(hex: "#DB232E")
        static let warmRed = UIColor(hex: "#DC535B")
        static let lightRed = UIColor(hex: "#FCEBF0")
        //绿色
        static let green = UIColor(hex: "#45CC21")
        static let warmGreen = UIColor(hex: "#69CB4F")
        static let lightGreen = UIColor(hex: "#E6F5E4")
        //橙色
        static let orange = UIColor(hex: "#F27827")
        static let warmOrange = UIColor(hex: "#EF8F50")
        static let lightOrange = UIColor(hex: "#FDF3EA")
        
        // 中性色
        static let textRegular = UIColor(hex: "#333333")
        static let textSecondary = UIColor(hex: "#666666")
        static let textHint = UIColor(hex: "#999999")
        static let background = UIColor(hex: "#F5F5F5")
        static let card = UIColor(hex: "#FFFFFF")
    }
    
    //字号
    struct Font {
        static let title1 = UIFont.systemFont(ofSize: 22, weight: .semibold)
        static let title2 = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let title3 = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        static let headline = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let subBody = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        static let caption = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    //尺寸
    struct Size {
        static let cornerS: CGFloat = 4
        static let cornerM: CGFloat = 8
        static let cornerL: CGFloat = 12
        
        static let cornerButton: CGFloat = 8
        static let cornerCard: CGFloat = 12
        
        static let spacingXS: CGFloat = 4
        static let spacingS: CGFloat = 8
        static let spacingM: CGFloat = 16
        static let spacingL: CGFloat = 24
        static let spacingXL: CGFloat = 32
        
        static let iconXS: CGFloat = 16
        static let iconS: CGFloat = 20
        static let iconM: CGFloat = 24
        static let iconL: CGFloat = 28
    }
    
    
}
