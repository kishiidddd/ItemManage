//
//  MainTabBarViewController.swift
//  ItemManage
//
//  Created by xiny on 2025/12/13.
//

import UIKit

class MainTabBarController: UITabBarController {
 
    private var customTabBar: UIView!
    private var tabItemViews: [TabItemView] = []
    private var currentSelectedIndex: Int = 1
    private var isTabBarHiddenAction: Bool = false
    private var isFirst = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        hideSystemTabBar()
        setupCustomTabBar()
        showTabBar()
        
        view.backgroundColor = .init(AppStyle.Color.background)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCustomTabBarPosition()
    }
    
    private func setupViewControllers() {
        let homeVC = HomeTabViewController()
        let categoryVC = CategoryTabViewController()
        let guideVC = LearnTabViewController()
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let categoryNav = UINavigationController(rootViewController: categoryVC)
        let guideNav = UINavigationController(rootViewController: guideVC)
        
        homeNav.delegate = self
        categoryNav.delegate = self
        guideNav.delegate = self
        
        guideNav.setNavigationBarHidden(true, animated: false)
        
        viewControllers = [homeNav, categoryNav, guideNav]
        selectedIndex = currentSelectedIndex
    }
    
    private func hideSystemTabBar() {
        tabBar.isHidden = true
        tabBar.alpha = 0
        tabBar.isTranslucent = false
    }
    
    private func setupCustomTabBar() {
        createTabBarContainer()
        setupTabItems()
    }
    
    private func createTabBarContainer() {
        customTabBar = UIView()
        customTabBar.backgroundColor = TabBarConfig.backgroundColor
        customTabBar.layer.cornerRadius = TabBarConfig.cornerRadius
        customTabBar.layer.masksToBounds = false
        
        // 设置阴影
        customTabBar.layer.shadowColor = TabBarConfig.shadowColor.cgColor
        customTabBar.layer.shadowOffset = TabBarConfig.shadowOffset
        customTabBar.layer.shadowRadius = TabBarConfig.shadowRadius
        customTabBar.layer.shadowOpacity = TabBarConfig.shadowOpacity
        
        view.addSubview(customTabBar)
        
        customTabBar.snp.makeConstraints { make in
            make.width.equalTo(TabBarConfig.width)
            make.height.equalTo(TabBarConfig.height)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    private func setupTabItems() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = TabBarConfig.stackSpacing
        
        customTabBar.addSubview(stackView)
        
        for (index, item) in TabBarConfig.tabItems.enumerated() {
            let tabItemView = TabItemView(
                index: index,
                title: item.title,
                normalImageName: item.normalIcon,
                selectedImageName: item.selectedIcon
            )
            
            tabItemView.tapHandle = { [weak self] tappedIndex in
                self?.switchToTab(at: tappedIndex)
            }
            
            stackView.addArrangedSubview(tabItemView)
            tabItemViews.append(tabItemView)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(TabBarConfig.padding)
        }
        
        updateTabSelection()
    }
    
    private func showTabBar() {
        customTabBar.alpha = 1
        customTabBar.transform = .identity
    }
    

    private func updateCustomTabBarPosition() {
        hideSystemTabBar()
        
        if let nav = selectedViewController as? UINavigationController {
            let isRootViewController = nav.viewControllers.count <= 1
            setTabBarHidden(!isRootViewController, animated: false)
        }
    }

    override func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        guard hidden != isTabBarHiddenAction else { return }
        isTabBarHiddenAction = hidden
        
        let animations = {
            if hidden {
                self.customTabBar.transform = CGAffineTransform(translationX: 0, y: 100)
                self.customTabBar.alpha = 0
            } else {
                self.showTabBar()
            }
            self.view.layoutIfNeeded()
        }
        
        animated ? UIView.animate(withDuration: 0.3, animations: animations) : animations()
    }
    
    private func switchToTab(at index: Int) {
        guard index >= 0 && index < viewControllers?.count ?? 0 else { return }
        
        selectedIndex = index
        currentSelectedIndex = index
        updateTabSelection()
        
        UIView.animate(withDuration: 0.2) {
            self.customTabBar.layoutIfNeeded()
        }
    }
    
    private func updateTabSelection() {
        for (index, tabItemView) in tabItemViews.enumerated() {
            tabItemView.isSelected = (index == currentSelectedIndex)
        }
    }
    
    override var selectedIndex: Int {
        didSet {
            super.selectedIndex = selectedIndex
            currentSelectedIndex = selectedIndex
            updateTabSelection()
            updateCustomTabBarPosition()
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension MainTabBarController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                            willShow viewController: UIViewController,
                            animated: Bool) {
        hideSystemTabBar()
        let isRootViewController = navigationController.viewControllers.count <= 1
        setTabBarHidden(!isRootViewController, animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController,
                            didShow viewController: UIViewController,
                            animated: Bool) {
        hideSystemTabBar()
        let isRootViewController = navigationController.viewControllers.count <= 1
        setTabBarHidden(!isRootViewController, animated: animated)
    }
}
