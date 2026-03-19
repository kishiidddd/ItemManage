//
//  RegisterViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit

class RegistViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "regist_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var titleImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "regist_text")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        view.layer.shadowRadius = 10
        return view
    }()
    
    // 账号输入框
    private lazy var accountField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "请输入账号"
        tf.font = .systemFont(ofSize: 16)
        tf.borderStyle = .none
        tf.clearButtonMode = .whileEditing
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        let iconView = UIImageView(image: UIImage(systemName: "person"))
        iconView.tintColor = .gray
        iconView.frame = CGRect(x: 10, y: 15, width: 20, height: 20)
        leftView.addSubview(iconView)
        tf.leftView = leftView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    // 密码输入框
    private lazy var passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "请输入密码"
        tf.font = .systemFont(ofSize: 16)
        tf.borderStyle = .none
        tf.isSecureTextEntry = true
        tf.clearButtonMode = .whileEditing
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        let iconView = UIImageView(image: UIImage(systemName: "lock"))
        iconView.tintColor = .gray
        iconView.frame = CGRect(x: 10, y: 15, width: 20, height: 20)
        leftView.addSubview(iconView)
        tf.leftView = leftView
        tf.leftViewMode = .always
        
        let rightButton = UIButton(type: .system)
        rightButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        rightButton.tintColor = .gray
        rightButton.frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        rightButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        tf.rightView = rightButton
        tf.rightViewMode = .whileEditing
        
        return tf
    }()
    
    // 确认密码输入框
    private lazy var confirmPasswordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "请再次输入密码"
        tf.font = .systemFont(ofSize: 16)
        tf.borderStyle = .none
        tf.isSecureTextEntry = true
        tf.clearButtonMode = .whileEditing
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        let iconView = UIImageView(image: UIImage(systemName: "lock"))
        iconView.tintColor = .gray
        iconView.frame = CGRect(x: 10, y: 15, width: 20, height: 20)
        leftView.addSubview(iconView)
        tf.leftView = leftView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    // 分隔线1
    private let separatorLine1: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    // 分隔线2
    private let separatorLine2: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    // 注册按钮
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("注册", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 去登录按钮
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "已有账号？ ", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.gray
        ])
        attributedTitle.append(NSAttributedString(string: "立即登录", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.systemBlue
        ]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backgroundImageView)
        view.addSubview(titleImageView)
        view.addSubview(cardView)
        
        cardView.addSubview(accountField)
        cardView.addSubview(separatorLine1)
        cardView.addSubview(passwordField)
        cardView.addSubview(separatorLine2)
        cardView.addSubview(confirmPasswordField)
        cardView.addSubview(registerButton)
        cardView.addSubview(loginButton)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(260)
        }
        
        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(60)
        }
        
        cardView.snp.makeConstraints { make in
            make.top.equalTo(backgroundImageView.snp.bottom).offset(-30)
            make.left.right.bottom.equalToSuperview()
        }
        
        accountField.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(40)
            make.left.equalTo(cardView).offset(30)
            make.right.equalTo(cardView).offset(-30)
            make.height.equalTo(50)
        }
        
        separatorLine1.snp.makeConstraints { make in
            make.top.equalTo(accountField.snp.bottom)
            make.left.equalTo(cardView).offset(30)
            make.right.equalTo(cardView).offset(-30)
            make.height.equalTo(1)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(separatorLine1.snp.bottom)
            make.left.equalTo(cardView).offset(30)
            make.right.equalTo(cardView).offset(-30)
            make.height.equalTo(50)
        }
        
        separatorLine2.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom)
            make.left.equalTo(cardView).offset(30)
            make.right.equalTo(cardView).offset(-30)
            make.height.equalTo(1)
        }
        
        confirmPasswordField.snp.makeConstraints { make in
            make.top.equalTo(separatorLine2.snp.bottom)
            make.left.equalTo(cardView).offset(30)
            make.right.equalTo(cardView).offset(-30)
            make.height.equalTo(50)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordField.snp.bottom).offset(40)
            make.left.equalTo(cardView).offset(30)
            make.right.equalTo(cardView).offset(-30)
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(20)
            make.centerX.equalTo(cardView)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordField.isSecureTextEntry.toggle()
        let imageName = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func registerButtonTapped() {
        guard let account = accountField.text, !account.isEmpty else {
            showAlert(message: "请输入账号")
            return
        }
        
        guard let password = passwordField.text, !password.isEmpty else {
            showAlert(message: "请输入密码")
            return
        }
        
        guard let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            showAlert(message: "请再次输入密码")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(message: "两次输入的密码不一致")
            return
        }
        
        // 这里添加注册逻辑
        print("注册：账号：\(account)，密码：\(password)")
        
        // 模拟注册成功
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(account, forKey: "username")
        
        // 返回上一页
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func loginButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        (view as? UIScrollView)?.contentInset = contentInsets
        (view as? UIScrollView)?.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        (view as? UIScrollView)?.contentInset = .zero
        (view as? UIScrollView)?.scrollIndicatorInsets = .zero
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
