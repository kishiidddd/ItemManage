//
//  SettingViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit

class SettingViewController: UIViewController {
    
    // MARK: - Properties
    private var isLoggedIn: Bool = false // 登录状态，可以从 UserDefaults 获取
    
    // MARK: - UI Elements
    private lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "setting_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = .clear
        return sv
    }()
    
    // MARK: - 登录卡片
    private lazy var loginCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "setting_avatar") ?? UIImage(systemName: "person.circle.fill")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.systemBlue.cgColor
        iv.backgroundColor = .systemGray6
        iv.tintColor = .systemBlue
        return iv
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("点击登录", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()

    /// 覆盖整张登录卡片：已登录时也可点击进入登录页切换账号
    private lazy var loginCardTapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(loginCardTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "用户名"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.isHidden = true // 默认隐藏，登录后显示
        return label
    }()
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "欢迎使用物品管理APP"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private lazy var userInfoStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .leading
        return sv
    }()

    // MARK: - 物品统计（进入统计页）
    private lazy var statsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 4
        return view
    }()

    private lazy var statsIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "setting_cal") ?? UIImage(systemName: "chart.bar.fill")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemBlue
        return iv
    }()

    private lazy var statsLabel: UILabel = {
        let label = UILabel()
        label.text = "物品统计"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()

    private lazy var statsArrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .gray
        return iv
    }()

    private lazy var statsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(statsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 规则设置卡片（点击跳转到单独页面）
    private lazy var rulesCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var rulesIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "gear.badge") ?? UIImage(systemName: "gearshape.2.fill")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemBlue
        return iv
    }()
    
    private lazy var rulesLabel: UILabel = {
        let label = UILabel()
        label.text = "物品规则设置"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var rulesArrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .gray
        return iv
    }()
    
    private lazy var rulesButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(rulesButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 设置选项
    private lazy var settingsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()
    
    // 设置选项数据（已移除：隐私设置/用户协议/隐私政策）
    private let settingItems: [(icon: String, title: String, tag: Int)] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateLoginState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLoginState()
    }
    
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        
        // 添加背景图
        view.addSubview(backgroundImageView)
        
        // 添加滚动视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加登录卡片
        contentView.addSubview(loginCardView)
        loginCardView.addSubview(avatarImageView)
        loginCardView.addSubview(userInfoStackView)
        loginCardView.addSubview(loginCardTapButton)
        
        userInfoStackView.addArrangedSubview(loginButton)
        userInfoStackView.addArrangedSubview(usernameLabel)
        userInfoStackView.addArrangedSubview(welcomeLabel)

        contentView.addSubview(statsCardView)
        statsCardView.addSubview(statsIconImageView)
        statsCardView.addSubview(statsLabel)
        statsCardView.addSubview(statsArrowImageView)
        statsCardView.addSubview(statsButton)
        
        // 添加规则设置卡片
        setupRulesCard()
        
        // 设置选项已移除
    }
    
    private func setupRulesCard() {
        contentView.addSubview(rulesCardView)
        
        // 添加图标、标题和箭头
        rulesCardView.addSubview(rulesIconImageView)
        rulesCardView.addSubview(rulesLabel)
        rulesCardView.addSubview(rulesArrowImageView)
        rulesCardView.addSubview(rulesButton)
    }
    
    private func createSettingItems() {
        for item in settingItems {
            let settingCell = createSettingCell(icon: item.icon, title: item.title, tag: item.tag)
            settingsStackView.addArrangedSubview(settingCell)
        }
    }
    
    private func createSettingCell(icon: String, title: String, tag: Int) -> UIView {
        let cellView = UIView()
        cellView.backgroundColor = .white
        cellView.layer.cornerRadius = 12
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.05
        cellView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cellView.layer.shadowRadius = 4
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: icon) ?? UIImage(systemName: "gearshape.fill")
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .black
        
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tintColor = .gray
        
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.tag = tag
        // 设置选项已移除；保留 cell 构造代码以便后续恢复时使用
        
        cellView.addSubview(iconImageView)
        cellView.addSubview(titleLabel)
        cellView.addSubview(arrowImageView)
        cellView.addSubview(button)
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return cellView
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(260)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        // 登录卡片约束
        loginCardView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(100)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(100)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalTo(loginCardView).offset(16)
            make.centerY.equalTo(loginCardView)
            make.width.height.equalTo(60)
        }
        
        userInfoStackView.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(16)
            make.centerY.equalTo(loginCardView)
            make.right.equalTo(loginCardView).offset(-16)
        }
        loginCardTapButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        statsCardView.snp.makeConstraints { make in
            make.top.equalTo(loginCardView.snp.bottom).offset(20)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(70)
        }

        statsIconImageView.snp.makeConstraints { make in
            make.left.equalTo(statsCardView).offset(16)
            make.centerY.equalTo(statsCardView)
            make.width.height.equalTo(24)
        }

        statsLabel.snp.makeConstraints { make in
            make.left.equalTo(statsIconImageView.snp.right).offset(12)
            make.centerY.equalTo(statsCardView)
        }

        statsArrowImageView.snp.makeConstraints { make in
            make.right.equalTo(statsCardView).offset(-16)
            make.centerY.equalTo(statsCardView)
            make.width.height.equalTo(16)
        }

        statsButton.snp.makeConstraints { make in
            make.edges.equalTo(statsCardView)
        }
        
        // 规则卡片约束
        rulesCardView.snp.makeConstraints { make in
            make.top.equalTo(statsCardView.snp.bottom).offset(20)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(70)
            // 作为页面最后一个模块时，兜底撑开 scrollView 的 contentSize
            make.bottom.equalTo(contentView).offset(-30)
        }
        
        rulesIconImageView.snp.makeConstraints { make in
            make.left.equalTo(rulesCardView).offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        rulesLabel.snp.makeConstraints { make in
            make.left.equalTo(rulesIconImageView.snp.right).offset(12)
            make.centerY.equalTo(rulesIconImageView)
        }
        
        rulesArrowImageView.snp.makeConstraints { make in
            make.right.equalTo(rulesCardView).offset(-16)
            make.centerY.equalTo(rulesIconImageView)
            make.width.height.equalTo(16)
        }
        
        rulesButton.snp.makeConstraints { make in
            make.edges.equalTo(rulesCardView)
        }
        
        // 设置选项已移除（因此 contentView 的 bottom 由 rulesCardView 约束撑开）
    }
    
    // MARK: - Data Loading
    private func updateLoginState() {
        // 从 UserDefaults 或其他地方获取登录状态
        isLoggedIn = AuthSession.shared.isLoggedIn
        
        if isLoggedIn {
            let savedUsername = AuthSession.shared.username ?? "用户"
            usernameLabel.text = savedUsername
            usernameLabel.isHidden = false
            loginButton.isHidden = true
        } else {
            usernameLabel.isHidden = true
            loginButton.isHidden = false
        }
    }
    
    // MARK: - Actions
    @objc private func loginButtonTapped() {
        print("点击了登录按钮")
        openLoginPage()
    }

    @objc private func loginCardTapped() {
        print("点击了登录卡片")
        openLoginPage()
    }

    private func openLoginPage() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @objc private func statsButtonTapped() {
        let vc = CalculateViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func rulesButtonTapped() {
        print("点击了规则设置卡片")
        let rulesVC = ItemRulesViewController()
        navigationController?.pushViewController(rulesVC, animated: true)
    }
    
    // settingItemTapped 已移除
}



