//
//  CustomTextFieldAlertView.swift
//  ItemManage
//
//  Created by Cursor Agent on 2026/4/15.
//

import UIKit
import SnapKit

final class CustomTextFieldAlertView: UIView {

    // MARK: - UI

    private let dimmedView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.alpha = 0
        return v
    }()

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

    private let textFieldContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray6
        v.layer.cornerRadius = 12
        return v
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 16)
        tf.textColor = .label
        tf.clearButtonMode = .whileEditing
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        return tf
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        button.layer.cornerRadius = 24
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("确认", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 24
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        sv.alignment = .fill
        return sv
    }()

    // MARK: - Callbacks

    var onCancel: (() -> Void)?
    var onConfirm: ((String) -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(dimmedView)
        addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(textFieldContainer)
        textFieldContainer.addSubview(textField)
        containerView.addSubview(buttonStackView)

        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(confirmButton)
    }

    private func setupConstraints() {
        dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }

        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.width.lessThanOrEqualTo(420)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(24)
            make.left.equalTo(containerView).offset(20)
            make.right.equalTo(containerView).offset(-20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalTo(containerView).offset(20)
            make.right.equalTo(containerView).offset(-20)
        }

        textFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.left.equalTo(containerView).offset(20)
            make.right.equalTo(containerView).offset(-20)
            make.height.equalTo(44)
        }

        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        }

        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(textFieldContainer.snp.bottom).offset(20)
            make.left.equalTo(containerView).offset(24)
            make.right.equalTo(containerView).offset(-24)
            make.bottom.equalTo(containerView).offset(-20)
            make.height.equalTo(50)
        }
    }

    // MARK: - Public

    func configure(
        title: String,
        subtitle: String? = nil,
        placeholder: String,
        initialText: String? = nil,
        cancelTitle: String = "取消",
        confirmTitle: String = "确认",
        confirmEnabledWhenEmpty: Bool = false
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = (subtitle == nil || subtitle?.isEmpty == true)
        textField.placeholder = placeholder
        textField.text = initialText
        cancelButton.setTitle(cancelTitle, for: .normal)
        confirmButton.setTitle(confirmTitle, for: .normal)

        let t = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        confirmButton.isEnabled = confirmEnabledWhenEmpty ? true : !t.isEmpty
        confirmButton.alpha = confirmButton.isEnabled ? 1.0 : 0.45
    }

    func show(in view: UIView) {
        frame = view.bounds
        alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        view.addSubview(self)

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.containerView.transform = .identity
        } completion: { _ in
            self.textField.becomeFirstResponder()
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        onCancel?()
        dismiss()
    }

    @objc private func confirmTapped() {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        onConfirm?(text)
        dismiss()
    }

    @objc private func textChanged() {
        let t = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        confirmButton.isEnabled = !t.isEmpty
        confirmButton.alpha = confirmButton.isEnabled ? 1.0 : 0.45
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, touch.view == dimmedView {
            dismiss()
        }
    }
}

extension UIViewController {
    func showCustomTextFieldAlert(
        title: String,
        subtitle: String? = nil,
        placeholder: String,
        initialText: String? = nil,
        cancelTitle: String = "取消",
        confirmTitle: String = "确认",
        onCancel: (() -> Void)? = nil,
        onConfirm: @escaping (String) -> Void
    ) {
        let alertView = CustomTextFieldAlertView()
        alertView.configure(
            title: title,
            subtitle: subtitle,
            placeholder: placeholder,
            initialText: initialText,
            cancelTitle: cancelTitle,
            confirmTitle: confirmTitle
        )
        alertView.onCancel = onCancel
        alertView.onConfirm = onConfirm
        alertView.show(in: view)
    }
}

