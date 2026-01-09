//
//  HomeCategoryUIView.swift
//  ItemManage
//
//  Created by a on 2025/12/23.
//

import UIKit

class HomeRecentUIView: UIView {
    lazy var arrayImage:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "home_array")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var title:UILabel = {
        let title = UILabel()
        title.textColor = AppStyle.Color.textRegular
        title.font = AppStyle.Font.title3
        return title
    }()

    lazy var imageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.layer.borderColor = AppStyle.Color.card.cgColor
        imageView.layer.borderWidth = 2
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var imageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    lazy var imageView3: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    lazy var recentAddLabel:UILabel = {
        let label = UILabel()
        label.text = "最近添加"
        return label
    }()
    
    lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.backgroundColor = AppStyle.Color.primaryBlue
        label.numberOfLines = 1
        label.text = "3天前"
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        return label
    }()
    
    lazy var acountLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = AppStyle.Color.textHint
        label.font = AppStyle.Font.caption
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "共 0 项目"
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = AppStyle.Color.card
        layer.cornerRadius = 20
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupViews(){
        addSubview(arrayImage)
        arrayImage.snp.makeConstraints{ make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(12)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        addSubview(title)
        title.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalTo(arrayImage)
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(42)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalTo(0)
        }
        
        contentView.addSubview(imageView1)
        imageView1.snp.makeConstraints{ make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        contentView.insertSubview(imageView2, belowSubview: imageView1)
        imageView2.snp.makeConstraints{ make in
            make.left.equalTo(imageView1.snp.left).offset(41)
            make.width.equalTo(85)
            make.height.equalTo(85)
            make.bottom.equalTo(imageView1.snp.bottom)
        }
        
        contentView.insertSubview(imageView3, belowSubview: imageView2)
        imageView3.snp.makeConstraints{ make in
            make.left.equalTo(imageView2.snp.left).offset(40)
            make.width.equalTo(70)
            make.height.equalTo(70)
            make.bottom.equalTo(imageView2.snp.bottom)
        }
        
        contentView.addSubview(recentAddLabel)
        recentAddLabel.snp.makeConstraints{ make in
            make.left.equalToSuperview()
            make.top.equalTo(imageView1.snp.bottom).offset(8)
            make.height.equalTo(24)
        }
        
        contentView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints{ make in
            make.left.equalTo(recentAddLabel.snp.right).offset(4)
            make.centerY.equalTo(recentAddLabel)
            make.height.equalTo(24)
            make.width.equalTo(60)
        }
        
        contentView.addSubview(acountLabel)
        acountLabel.snp.makeConstraints{ make in
            make.left.equalTo(recentAddLabel.snp.left)
            make.top.equalTo(recentAddLabel.snp.bottom).offset(2)
            make.height.equalTo(20)
        }
    }
    

}
