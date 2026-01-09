//
//  GuideViewController.swift
//  ItemManage
//
//  Created by a on 2025/12/23.
//
//引导页

import UIKit
import SnapKit

class GuideViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("立即体验", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 8
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.alpha = 0
        button.transform = CGAffineTransform(translationX: 0, y: 50)
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("跳过", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var guidePages: [GuidePage] = []
    private var pageViews: [GuidePageView] = []
    
    struct GuidePage {
        let title: String
        let description: String
        let imageName: String
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        createGuidePages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    private func setupData() {
        guidePages = [
            GuidePage(
                title: "智能物品管理",
                description: "轻松记录和管理您的所有物品\n分类清晰，查找方便",
                imageName: "guide_manage"
            ),
            GuidePage(
                title: "专业收纳指南",
                description: "学习科学收纳方法\n让生活空间更整洁有序",
                imageName: "guide_organize"
            ),
            GuidePage(
                title: "定期提醒维护",
                description: "设置物品维护提醒\n保持物品最佳状态",
                imageName: "guide_reminder"
            ),
            GuidePage(
                title: "数据分析报告",
                description: "查看物品使用统计\n优化您的消费习惯",
                imageName: "guide_analytics"
            )
        ]
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(startButton)
        
        // Setup constraints
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        skipButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(pageControl.snp.top).offset(-30)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        // Configure page control
        pageControl.numberOfPages = guidePages.count
    }
    
    private func createGuidePages() {
        for (index, page) in guidePages.enumerated() {
            let pageView = GuidePageView()
            pageView.configure(with: page)
            
            scrollView.addSubview(pageView)
            pageViews.append(pageView)
            
            pageView.snp.makeConstraints { make in
                make.width.height.equalTo(scrollView)
                make.top.bottom.equalToSuperview()
                
                if index == 0 {
                    make.left.equalTo(scrollView)
                } else {
                    make.left.equalTo(pageViews[index - 1].snp.right)
                }
                
                if index == guidePages.count - 1 {
                    make.right.equalTo(scrollView)
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func startButtonTapped() {
        saveGuideCompletion()
        navigateToMain()
    }
    
    @objc private func skipButtonTapped() {
        saveGuideCompletion()
        navigateToMain()
    }
    
    private func saveGuideCompletion() {
        UserDefaults.standard.set(true, forKey: "hasShownGuide")
        UserDefaults.standard.synchronize()
    }
    
    private func navigateToMain() {
        // 根据您的实际主页面进行调整
//        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//            sceneDelegate.setupMainInterface()
//        }
        
        // 或者使用以下方式之一：
        // 1. 切换 window 的根视图控制器
        // UIApplication.shared.windows.first?.rootViewController = MainTabBarController()
        
        // 2. 如果是 modal 展示的引导页
        // dismiss(animated: true)
        
        // 3. 如果是在导航控制器中
        // navigationController?.popViewController(animated: true)
        // navigationController?.setViewControllers([MainViewController()], animated: true)
    }
    
    private func updateButtonVisibility() {
        let isLastPage = pageControl.currentPage == guidePages.count - 1
        UIView.animate(withDuration: 0.3) {
            self.startButton.alpha = isLastPage ? 1 : 0
            self.skipButton.alpha = isLastPage ? 0 : 1
            self.startButton.transform = isLastPage ? .identity : CGAffineTransform(translationX: 0, y: 50)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension GuideViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        updateButtonVisibility()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateButtonVisibility()
    }
}

// MARK: - Custom Page View
class GuidePageView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Add subviews
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        // Setup constraints
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.width.height.equalTo(280)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(40)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(40)
        }
    }
    
    func configure(with page: GuideViewController.GuidePage) {
        titleLabel.text = page.title
        descriptionLabel.text = page.description
        
        // 在实际项目中，您应该使用实际的图片资源
        // imageView.image = UIImage(named: page.imageName)
        
        // 临时使用系统图标
        let configuration = UIImage.SymbolConfiguration(pointSize: 100, weight: .thin)
        imageView.image = UIImage(systemName: getSystemIconName(for: page.imageName),
                                 withConfiguration: configuration)
        imageView.tintColor = .systemBlue
    }
    
    private func getSystemIconName(for imageName: String) -> String {
        switch imageName {
        case "guide_manage":
            return "cube.box.fill"
        case "guide_organize":
            return "shippingbox.fill"
        case "guide_reminder":
            return "bell.badge.fill"
        case "guide_analytics":
            return "chart.bar.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
}

// MARK: - SceneDelegate Extension (如果使用SceneDelegate)
/*
extension SceneDelegate {
    func setupMainInterface() {
        let mainVC = MainTabBarController() // 或者您的主页面控制器
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
    }
}
*/

// MARK: - 使用示例（在AppDelegate或SceneDelegate中调用）
/*
func checkAndShowGuide() {
    let hasShownGuide = UserDefaults.standard.bool(forKey: "hasShownGuide")
    
    if !hasShownGuide {
        let guideVC = GuideViewController()
        guideVC.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(guideVC, animated: false)
    }
}
*/
