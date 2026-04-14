//
//  AccManageViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit

class AccManageViewController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = .clear
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // 注销账号卡片
    private lazy var logoutAccountCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let logoutAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "注销账号"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let logoutAccountArrow: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .gray
        return iv
    }()
    
    private lazy var logoutAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(logoutAccountButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 退出账号按钮
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("退出账号", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 提示标签
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "注销账号后将无法恢复，请谨慎操作"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "账号管理"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加注销账号卡片
        contentView.addSubview(logoutAccountCard)
        logoutAccountCard.addSubview(logoutAccountLabel)
        logoutAccountCard.addSubview(logoutAccountArrow)
        logoutAccountCard.addSubview(logoutAccountButton)
        contentView.addSubview(warningLabel)//提示
        
        // 添加退出按钮
        contentView.addSubview(logoutButton)
        
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        // 注销账号卡片约束
        logoutAccountCard.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(60)
        }
        
        logoutAccountLabel.snp.makeConstraints { make in
            make.left.equalTo(logoutAccountCard).offset(16)
            make.centerY.equalTo(logoutAccountCard)
        }
        
        logoutAccountArrow.snp.makeConstraints { make in
            make.right.equalTo(logoutAccountCard).offset(-16)
            make.centerY.equalTo(logoutAccountCard)
            make.width.height.equalTo(16)
        }
        
        logoutAccountButton.snp.makeConstraints { make in
            make.edges.equalTo(logoutAccountCard)
        }
        
        // 提示标签约束
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(logoutAccountCard.snp.bottom).offset(16)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.bottom.equalTo(contentView).offset(-30)
        }
        
        // 退出按钮约束
        logoutButton.snp.makeConstraints { make in
            make.bottom.equalTo(view).offset(-32)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(50)
        }
        

    }
    
    // MARK: - Actions
    @objc private func logoutAccountButtonTapped() {
        print("点击了注销账号")
        
        showCustomAlert(
            title: "注销账号",
            subtitle: "注销后，您的所有数据将被永久删除，且无法恢复。确定要继续吗？",
            cancelTitle: "再想想",
            confirmTitle: "确认注销",
            onCancel: {
                print("用户取消注销账号")
            },
            onConfirm: { [weak self] in
                print("用户确认注销账号")
                self?.performLogoutAccount()
            }
        )
    }
    
    @objc private func logoutButtonTapped() {
        print("点击了退出账号")
        
        showCustomAlert(
            title: "退出账号",
            subtitle: "确定要退出当前账号吗？",
            cancelTitle: "取消",
            confirmTitle: "确认退出",
            onCancel: {
                print("用户取消退出账号")
            },
            onConfirm: { [weak self] in
                print("用户确认退出账号")
                self?.performLogout()
            }
        )
    }
    
    // MARK: - Private Methods
    private func performLogoutAccount() {
        // 这里执行注销账号的逻辑
        // 比如调用API、清除本地数据等
        
        // 显示成功提示（可选）

    }
    
    private func performLogout() {
        // 这里执行退出登录的逻辑
        // 比如清除用户信息、跳转到登录页等
        
        // 清除本地登录态（含 token）
        AuthSession.shared.clear()
        ItemRepository.shared.loadData()
        
        // 返回到登录页或首页
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 跳转到登录页
//            let loginVC = LoginViewController()
//            loginVC.modalPresentationStyle = .fullScreen
//            self.present(loginVC, animated: true)
            
            // 或者如果有导航控制器，可以 pop 到根视图
            // self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

