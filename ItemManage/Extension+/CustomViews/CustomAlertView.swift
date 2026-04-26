//
//  CustomAlertView.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit

class CustomAlertView: UIView {
    
    // MARK: - Properties
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 16
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .text1Color
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .text2Color
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("确认", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 0
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        return view
    }()
    
    // MARK: - Callbacks
    var onCancel: (() -> Void)?
    var onConfirm: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(dimmedView)
        addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(confirmButton)
    }
    
    private func setupConstraints() {
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.width.lessThanOrEqualTo(400)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(24)
            make.left.equalTo(containerView).offset(20)
            make.right.equalTo(containerView).offset(-20)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalTo(containerView).offset(20)
            make.right.equalTo(containerView).offset(-20)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.left.equalTo(containerView).offset(24)
            make.right.equalTo(containerView).offset(-24)
            make.bottom.equalTo(containerView).offset(-20)
            make.height.equalTo(44)
        }
    }
    
    // MARK: - Public Methods
    func configure(title: String, subtitle: String, cancelTitle: String? = "取消", confirmTitle: String = "确认") {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        confirmButton.setTitle(confirmTitle, for: .normal)

        // 允许不传 cancelTitle，此时仅保留确认按钮（更适合纯提示场景）
        let arranged = buttonStackView.arrangedSubviews
        arranged.forEach { v in
            buttonStackView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        if let cancelTitle = cancelTitle, !cancelTitle.isEmpty {
            cancelButton.setTitle(cancelTitle, for: .normal)
            buttonStackView.addArrangedSubview(cancelButton)
            buttonStackView.addArrangedSubview(confirmButton)
            buttonStackView.distribution = .fillEqually
        } else {
            buttonStackView.addArrangedSubview(confirmButton)
            buttonStackView.distribution = .fill
        }
    }
    
    func show(in view: UIView) {
        // 设置初始状态
        self.frame = view.bounds
        self.alpha = 1
        dimmedView.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        view.addSubview(self)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.dimmedView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        onCancel?()
        dismiss()
    }
    
    @objc private func confirmButtonTapped() {
        onConfirm?()
        dismiss()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, touch.view == dimmedView {
            dismiss()
        }
    }
}

// MARK: - 便捷使用方法
extension UIViewController {
    func showCustomAlert(
        title: String,
        subtitle: String,
        cancelTitle: String? = "取消",
        confirmTitle: String = "确认",
        onCancel: (() -> Void)? = nil,
        onConfirm: (() -> Void)? = nil
    ) {
        let alertView = CustomAlertView()
        alertView.configure(
            title: title,
            subtitle: subtitle,
            cancelTitle: cancelTitle,
            confirmTitle: confirmTitle
        )
        alertView.onCancel = onCancel
        alertView.onConfirm = onConfirm
        alertView.show(in: view)
    }
}
