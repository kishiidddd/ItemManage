import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - 引导页判断
    static var isGuideFirst: Bool {
        get {
            // 如果key不存在，bool(forKey:)默认返回false
            // 但我们希望第一次是true，所以取反逻辑
            return false//!UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: "hasLaunchedBefore")
        }
    }
    
    var window: UIWindow?
    
    // MARK: - App启动
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 创建窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white // 设置背景色
        
        // 根据是否是第一次启动决定显示哪个页面
        if AppDelegate.isGuideFirst {
            showGuidePage()
        } else {
            showMainPage()
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - 显示主页面
    func showMainPage() {
        // 标记已经启动过
        AppDelegate.isGuideFirst = false
        
        let mainTabBarController = MainTabBarController()
        window?.rootViewController = mainTabBarController
        
        // 添加转场动画
        UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
    
    // MARK: - 显示引导页
    func showGuidePage() {
        // 创建一个简单的引导页（先用测试页）
        let testVC = UIViewController()
        testVC.view.backgroundColor = .systemBlue
        
        let label = UILabel()
        label.text = "这是引导页\n点击任意位置继续"
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        let button = UIButton(type: .system)
        button.setTitle("进入应用", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(guideButtonTapped), for: .touchUpInside)
        
        testVC.view.addSubview(label)
        testVC.view.addSubview(button)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: testVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: testVC.view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: testVC.view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: testVC.view.trailingAnchor, constant: -20),
            
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40),
            button.centerXAnchor.constraint(equalTo: testVC.view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(guideButtonTapped))
        testVC.view.addGestureRecognizer(tapGesture)
        
        window?.rootViewController = testVC
    }
    
    @objc func guideButtonTapped() {
        showMainPage()
    }
}

// MARK: - 扩展方法
extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    static var rootViewController: UIViewController? {
        return shared.window?.rootViewController
    }
    
    static var currentWindow: UIWindow? {
        return shared.window
    }
}
