//
//  ItemCell.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//
import UIKit

// MARK: - Item Cell
class ItemCell: UITableViewCell {
    
    static let identifier = "ItemCell"
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let itemImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .systemGray6
        iv.image = UIImage(systemName: "photo")
        iv.tintColor = .systemGray3
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGreen
        return label
    }()
    
    private let expiryBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .leading
        return sv
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(itemImageView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(categoryLabel)
        stackView.addArrangedSubview(quantityLabel)
        
        containerView.addSubview(priceLabel)
        containerView.addSubview(expiryBadge)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        itemImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(60)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(itemImageView)
            make.leading.equalTo(itemImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(priceLabel.snp.leading).offset(-8)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(itemImageView)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        expiryBadge.snp.makeConstraints { make in
            make.leading.equalTo(stackView)
            make.bottom.equalToSuperview().offset(-12)
            make.width.greaterThanOrEqualTo(60)
            make.height.equalTo(24)
        }
    }
    
    // MARK: - Configure
    func configure(with item: ItemModel) {
        nameLabel.text = item.name
        categoryLabel.text = item.category?.name ?? "未分类"
        
        // 数量显示
        if let unit = item.unit {
            quantityLabel.text = "数量: \(item.quantity) \(unit.name)"
        } else {
            quantityLabel.text = "数量: \(item.quantity)"
        }
        
        // 价格显示
        priceLabel.text = item.displayPrice
        
        // 过期状态显示
        if item.isExpired {
            expiryBadge.text = "已过期"
            expiryBadge.backgroundColor = .systemRed.withAlphaComponent(0.1)
            expiryBadge.textColor = .systemRed
        } else if let days = item.daysUntilExpiry, days <= 3 {
            expiryBadge.text = "即将过期"
            expiryBadge.backgroundColor = .systemOrange.withAlphaComponent(0.1)
            expiryBadge.textColor = .systemOrange
        } else {
            expiryBadge.text = "正常"
            expiryBadge.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            expiryBadge.textColor = .systemGreen
        }
        
        // 加载图片
        if let firstPhoto = item.photos.first, !firstPhoto.url.isEmpty {
            itemImageView.kf.setImage(with: URL(string: firstPhoto.url), placeholder: UIImage(systemName: "photo"))
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.kf.cancelDownloadTask()
        itemImageView.image = UIImage(systemName: "photo")
    }
}
