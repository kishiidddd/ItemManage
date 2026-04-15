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
        sv.backgroundColor = .lightGrayBgColor
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
    

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .lightGrayBgColor
        title = "账号管理"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加注销账号卡片
        contentView.addSubview(logoutAccountCard)
        logoutAccountCard.addSubview(logoutAccountLabel)
        logoutAccountCard.addSubview(logoutAccountArrow)
        logoutAccountCard.addSubview(logoutAccountButton)
        
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

        // 退出按钮必须约束在 contentView 内并撑开底部，否则相对于外层 view 定位会落在滚动区域外/被裁切，导致点击无响应
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(logoutAccountCard.snp.bottom).offset(44)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(50)
            make.bottom.equalTo(contentView).offset(-30)
        }
    }
    
    // MARK: - Actions
    @objc private func logoutAccountButtonTapped() {
        print("点击了注销账号")
        
        showCustomAlert(
            title: "注销账号",
            subtitle: "注销后，您的所有数据将被永久删除。确定要注销吗？",
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
        guard AuthSession.shared.isLoggedIn else {
            presentMessageAlert(title: "提示", message: "请先登录")
            return
        }
        view.isUserInteractionEnabled = false
        ItemDataService.shared.deleteAccount { [weak self] result in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            switch result {
            case .failure(let error):
                self.presentMessageAlert(title: "注销失败", message: error.localizedDescription)
            case .success:
                AuthSession.shared.clear()
                ItemRepository.shared.clearLocalCache()
                ItemRepository.shared.loadData()
                self.presentMessageAlert(title: "提示", message: "账号已注销") { [weak self] in
                    self?.popToMineTabRoot()
                }
            }
        }
    }

    private func performLogout() {
        AuthSession.shared.clear()
        ItemRepository.shared.clearLocalCache()
        ItemRepository.shared.loadData()
        popToMineTabRoot()
    }

    /// 「我的」页所在导航栈回到根（`SettingViewController`），以便 `viewWillAppear` 刷新登录态
    private func popToMineTabRoot() {
        navigationController?.popToRootViewController(animated: true)
    }

    private func presentMessageAlert(title: String, message: String, onOK: (() -> Void)? = nil) {
        showCustomAlert(
            title: title,
            subtitle: message,
            cancelTitle: nil,
            confirmTitle: "确定",
            onConfirm: onOK
        )
    }
}

