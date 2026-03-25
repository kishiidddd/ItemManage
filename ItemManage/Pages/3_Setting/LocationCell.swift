//
//  LocationCell.swift
//  ItemManage
//
//  Created by a on 2026/3/24.
//
import UIKit
import SnapKit

// MARK: - LocationCell
class LocationCell: UITableViewCell {
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    private let selectionIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 2
        return view
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
        
        // 先添加所有子视图
        contentView.addSubview(selectionIndicator)
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(itemCountLabel)
        contentView.addSubview(textStack)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.addArrangedSubview(editButton)
        buttonStack.addArrangedSubview(deleteButton)
        contentView.addSubview(buttonStack)
        
        // 设置约束
        selectionIndicator.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(4)
        }
        
        textStack.snp.makeConstraints { make in
            make.left.equalTo(selectionIndicator.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(buttonStack.snp.left).offset(-12)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(36)
        }
    }
    
    func configure(with location: PrimaryLocationModel, isSelected: Bool) {
        nameLabel.text = location.name
        itemCountLabel.text = "\(ItemRepository.shared.getItems(byPrimaryLocationId: location.id).count) 个物品"
        
        let color = UIColor(hex: location.color)
        selectionIndicator.backgroundColor = color
        
        
        selectionIndicator.isHidden = !isSelected
    }
    
    func configure(with location: SecondaryLocationModel) {
        nameLabel.text = location.name
        itemCountLabel.text = "\(ItemRepository.shared.getItems(bySecondaryLocationId: location.id).count) 个物品"
    }
    
    private func getIconName(from icon: String) -> String? {
        // 如果是 emoji，返回默认图标
        if icon.containsEmoji() {
            return "location.fill"
        }
        return icon
    }
}

// MARK: - String Extension
extension String {
    func containsEmoji() -> Bool {
        for scalar in unicodeScalars {
            if scalar.properties.isEmoji {
                return true
            }
        }
        return false
    }
}
