//
//
//  TabBarConfig.swift
//  ItemManage
//
//  Created by xiny on 2025/12/14.
//
import UIKit

struct TabBarConfig{
    struct TabItem{
        let title:String
        let normalIcon:String
        let selectedIcon:String
    }
    
    static let tabItems:[TabItem] = [
        TabItem(title: "首页", normalIcon: "tab_home", selectedIcon: "tab_home"),
        TabItem(title: "分类", normalIcon: "tab_category", selectedIcon: "tab_category"),
        TabItem(title: "指南", normalIcon: "tab_guide", selectedIcon: "tab_guide")
    ]
    
    // 样式配置
    static let backgroundColor: UIColor = .white
    static let cornerRadius: CGFloat = 30
    static let width: CGFloat = 340
    static let height: CGFloat = 56
    static let stackSpacing: CGFloat = 0
    static let padding = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    
    // 阴影配置
    static let shadowColor: UIColor = .black
    static let shadowOpacity: Float = 0.05
    static let shadowOffset = CGSize(width: 0, height: 8)
    static let shadowRadius: CGFloat = 16
    
    // Tab项配置
    static let iconSize: CGFloat = 18
    static let iconContainerSize: CGFloat = 24
    
    // 间距配置
    static let iconTopPadding: CGFloat = 6
    
}
