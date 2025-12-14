//
//
//  TabBarConfig.swift
//  ItemManage
//
//  Created by xiny on 2025/12/14.
//

import UIKit
import SnapKit

class TabItemView:UIView{
    private let iconContainer:UIView = {
        let icon = UIView()
        icon.isUserInteractionEnabled = true
        return icon
    }()
    private let iconButton : UIButton = {
        let btn = UIButton(type: .custom)
        btn.isUserInteractionEnabled = false
        btn.contentMode = .center
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    private let titleLabel:UILabel={
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.textAlignment = .center
        label.font = AppStyle.Font.caption
        return label
    }()
    
    private let index :Int
    private let title:String
    private let normalImageName:String
    private let selectedImageName:String
    var tapHandle:((Int)->Void)?
    
    var isSelected = false{
        didSet{
            updateAppearance()
        }
    }
    
    init(index: Int,title:String,normalImageName: String, selectedImageName: String) {
        self.index = index
        self.title = title
        self.normalImageName = normalImageName
        self.selectedImageName = selectedImageName
        super.init(frame: .zero)
        
        setupUI()
        setupGesture()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI(){
        titleLabel.text = title
        
        addSubview(iconContainer)
        iconContainer.addSubview(iconButton)
        addSubview(titleLabel)
    }
    
    private func setupConstraints(){
        // 图标容器约束
        iconContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(TabBarConfig.iconTopPadding)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(TabBarConfig.iconContainerSize)
        }
        
        // 图标按钮约束
        iconButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(TabBarConfig.iconSize)
        }
        
        // 标题标签约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainer.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
            make.bottom.lessThanOrEqualToSuperview().offset(-TabBarConfig.iconTopPadding)
        }
    }
    
    private func setupGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(){
        tapHandle?(index)
    }
    
    private func updateAppearance(){
        iconButton.isSelected = isSelected//把 TabItemView 的 isSelected 同步给按钮的 isSelected
        titleLabel.textColor = isSelected ? AppStyle.Color.primaryBlue : AppStyle.Color.textHint
        iconButton.setImage(UIImage(named: normalImageName), for: .normal)
        iconButton.setImage(UIImage(named: selectedImageName), for: .selected)
    }
    
}

