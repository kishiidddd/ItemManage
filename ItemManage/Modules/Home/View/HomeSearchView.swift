//
//  HomeSearchView.swift
//  ItemManage
//
//  Created by xiny on 2026/2/19.
//

import UIKit
import SnapKit

class HomeSearchView: UIView {
    
    // MARK: - UI
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "search_glass")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "搜索物品"
        field.font = UIFont.systemFont(ofSize: 16)
        field.textColor = .black
        
        // placeholder 颜色（可选）
        field.attributedPlaceholder = NSAttributedString(
            string: "搜索物品",
            attributes: [
                .foregroundColor: UIColor.lightGray
            ]
        )
        
        field.clearButtonMode = .whileEditing
        
        return field
    }()
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    // MARK: - Setup
    
    private func setupUI() {
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(48)
        }
        
        containerView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        containerView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }
    }
    
    
    // MARK: - Public
    
    func getText() -> String? {
        return textField.text
    }
    
    func setPlaceholder(_ text: String) {
        textField.placeholder = text
    }
    
    func becomeFirstResponder() {
        textField.becomeFirstResponder()
    }
}

