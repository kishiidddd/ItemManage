//
//  HomeTopView.swift
//  ItemManage
//
//  Created by xiny on 2026/2/19.
//

import UIKit

class HomeTopView: UIView {
    
    private lazy var topBgImageView : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "home_bg")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var topTextImageView : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "home_text_add")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var topBtnImageView : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "home_btn_add")
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        bringSubviewToFront(topBtnImageView)
        let btnTap = UITapGestureRecognizer(target: self, action: #selector(addBtnTapped))
        topBtnImageView.addGestureRecognizer(btnTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI(){
        addSubview(topBgImageView)
        topBgImageView.snp.makeConstraints{ make in
            make.top.right.left.equalToSuperview()
            
        }
        
        addSubview(topTextImageView)
        topTextImageView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(60)
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(20)
        }
        
        addSubview(topBtnImageView)
        topBtnImageView.snp.makeConstraints{ make in
            make.top.equalTo(topTextImageView.snp.bottom).offset(16)
            make.height.equalTo(42)
            make.centerX.equalTo(topTextImageView)
        }
    }
    
    @objc func addBtnTapped(){
        print("tapped")
    }

}
