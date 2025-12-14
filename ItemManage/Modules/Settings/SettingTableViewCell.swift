//
//  SettingTableViewCell.swift
//  ItemManage
//
//  Created by xiny on 2025/12/14.
//

import UIKit



class SettingTableViewCell: UITableViewCell {

    private lazy var iconImage:UIImageView={
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    private lazy var titleLabel:UILabel={
        let label = UILabel()
        label.font = AppStyle.Font.body
        label.textColor = AppStyle.Color.textRegular
        label.contentMode = .left
        return label
    }()
    
    private lazy var enterImage:UIImageView={
        let img = UIImageView()
        img.image = UIImage(named: "setting_enter")
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder:NSCoder){
        fatalError()
    }
    
    private func setupUI(){
        contentView.addSubview(iconImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(enterImage)
    }
    
    private func setupConstraints(){
        iconImage.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconImage.snp.right).offset(8)
        }
        
        enterImage.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
    }
    
    func configure(with item:settingItem){
        iconImage.image = UIImage(named: item.iconImageName)
        titleLabel.text = item.title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
