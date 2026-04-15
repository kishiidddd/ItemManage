//
//  FWMainTabViewController.swift
//  FebruaryWeather
//
//  Created by a on 2026/2/4.
//

import UIKit
import SnapKit

class FWMainTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        view.backgroundColor = .lightGrayBgColor
        tabBar.tintColor = .themeBlueColor // 选中 icon 和文字颜色
        tabBar.unselectedItemTintColor = UIColor(hex: "#999999") // 未选中颜色，可自定义
    }

    private func setupViewControllers() {
        let vc1 = MainViewController()
        vc1.tabBarItem = UITabBarItem(title: "首页",
                                      image: UIImage(named: "tab_main_icon")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "tab_main_icon_select")?.withRenderingMode(.alwaysOriginal))

        let vc2 = RemindViewController()
        vc2.tabBarItem = UITabBarItem(title: "提醒",
                                      image: UIImage(named: "tab_remind_icon")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "tab_remind_icon_select")?.withRenderingMode(.alwaysOriginal))
        
        let vc3 = GuideViewController()
        vc3.tabBarItem = UITabBarItem(title: "指南",
                                      image: UIImage(named: "tab_add_icon")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "tab_add_icon_select")?.withRenderingMode(.alwaysOriginal))

        let vc4 = SettingViewController()
        vc4.tabBarItem = UITabBarItem(title: "我的",
                                      image: UIImage(named: "tab_setting_icon")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "tab_setting_icon_select")?.withRenderingMode(.alwaysOriginal))

        viewControllers = [
            UINavigationController(rootViewController: vc1),
            UINavigationController(rootViewController: vc2),
            UINavigationController(rootViewController: vc3),
            UINavigationController(rootViewController: vc4)
        ]
        
        // 设置背景色（iOS 13+ 推荐）
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white // 背景颜色
            
            // 标准外观
            tabBar.standardAppearance = appearance
            
            // 滚动边缘外观（iOS 15+）
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        } else {
            // iOS 13 以下
            tabBar.barTintColor = .white // 背景色
        }
    }

}

