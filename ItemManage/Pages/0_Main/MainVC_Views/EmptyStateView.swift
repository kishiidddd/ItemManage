// EmptyStateView.swift
import UIKit
import SnapKit

class EmptyStateView: UIView {
    
    // MARK: - UI Elements
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "shippingbox")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无物品"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "点击右上角按钮添加物品"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray2
        label.textAlignment = .center
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .center
        return sv
    }()
    
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
        
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
    }
    
    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - Public Methods
    func configure(title: String? = nil, message: String? = nil, image: UIImage? = nil) {
        if let title = title {
            titleLabel.text = title
        }
        if let message = message {
            messageLabel.text = message
        }
        if let image = image {
            imageView.image = image
        }
    }
}
