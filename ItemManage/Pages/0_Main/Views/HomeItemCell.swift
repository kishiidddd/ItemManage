//
//  HomeItemCell.swift
//  ItemManage
//
//  Created by a on 2026/3/18.
//
import UIKit
import SnapKit

// MARK: - HomeItemCell
class HomeItemCell: UITableViewCell {
    
    static let identifier = "HomeItemCell"
    
    // MARK: - UI Elements
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let itemImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "photo")
        iv.tintColor = .gray
        iv.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardView)
        cardView.addSubview(itemImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(quantityLabel)
        cardView.addSubview(statusLabel)
        cardView.addSubview(priceLabel)
        
        // 卡片：自适应高度，保证第三行「过期状态」不被 80pt 固定高度压没
        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-6)
        }
        
        itemImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(56)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(itemImageView.snp.right).offset(12)
            make.right.lessThanOrEqualTo(priceLabel.snp.left).offset(-8)
        }
        
        quantityLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalTo(nameLabel)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(quantityLabel.snp.bottom).offset(4)
            make.left.equalTo(nameLabel)
            make.right.lessThanOrEqualToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-12)
            make.width.greaterThanOrEqualTo(60)
        }
    }
    
    func configure(with item: ItemModel) {
        nameLabel.text = item.name
        quantityLabel.text = "数量：\(item.quantity)"
        
        // 加载图片
        if let firstPhoto = item.photos.first, let url = URL(string: firstPhoto.url) {
            itemImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        } else {
            itemImageView.image = UIImage(systemName: "photo")
        }
        
        // 设置过期状态
        if let expiryDate = item.expiryDate {
            let daysUntilExpire = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
            
            if daysUntilExpire < 0 {
                statusLabel.text = "已过期"
                statusLabel.textColor = .red
            } else if daysUntilExpire <= 3 {
                statusLabel.text = "即将过期"
                statusLabel.textColor = .orange
            } else {
                statusLabel.text = "\(daysUntilExpire)天后过期"
                statusLabel.textColor = .gray
            }
        } else {
            statusLabel.text = "无过期时间"
            statusLabel.textColor = .gray
        }
        
        // 设置价格
        if let totalPrice = item.totalPrice {
            priceLabel.text = String(format: "¥%.2f", totalPrice)
        } else {
            priceLabel.text = "¥0.00"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.kf.cancelDownloadTask()
        itemImageView.image = UIImage(systemName: "photo")
    }
}
