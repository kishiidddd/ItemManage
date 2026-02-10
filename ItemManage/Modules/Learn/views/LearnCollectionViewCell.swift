//
//  LearnCollectionViewCell.swift
//  ItemManage
//
//  Created by a on 2026/1/9.
//
import UIKit

class LearnCollectionViewCell: UICollectionViewCell{
    static let identifier = "LearnCollectionViewCell"
    
    private let thumbnail:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    private let titleBg:UIView = {
        let bg = UIView()
        bg.backgroundColor = AppStyle.Color.card
        return bg
    }()
    
    private let titleLabel:UILabel = {
        let title = UILabel()
        title.font = AppStyle.Font.title3
        title.textColor = AppStyle.Color.textRegular
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setupContraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI(){
        addSubview(thumbnail)
        addSubview(titleBg)
        titleBg.addSubview(titleLabel)
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds=true
    }
    
    private func setupContraints(){
        thumbnail.snp.makeConstraints{ make in
            make.top.left.right.equalToSuperview()
        }
        
        titleBg.snp.makeConstraints{ make in
            make.bottom.left.right.equalToSuperview()
            make.top.equalToSuperview().multipliedBy(0.25)
        }
        
        titleLabel.snp.makeConstraints{ make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(12)
        }
    }
    
    func configure(image:UIImage?,title:String){
        thumbnail.image = image
        titleLabel.text = title
    }
    
}
