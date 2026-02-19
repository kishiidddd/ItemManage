//
//  HomeMessageScrollView.swift
//  ItemManage
//
//  Created by xiny on 2026/2/19.
//

import UIKit
import SnapKit

class HomeMessageScrollView: UIView {
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceHorizontal = true
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    // 存储卡片
    private var cardViews: [UIView] = []
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupCards()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    // MARK: - Setup UI
    
    private func setupUI() {
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview() // 关键：固定高度
        }
    }
    
    
    // MARK: - Setup Cards
    
    private func setupCards() {
        
        let cardWidth: CGFloat = 220
        let cardHeight: CGFloat = 92
        let spacing: CGFloat = 12
        
        var lastView: UIView?
        
        for i in 0..<4 {
            
            let card = UIView()
            card.backgroundColor = .yellowColor
            card.layer.cornerRadius = 22
            card.layer.masksToBounds = true
            
            contentView.addSubview(card)
            
            card.snp.makeConstraints { make in
                
                make.width.equalTo(cardWidth)
                make.height.equalTo(cardHeight)
                make.centerY.equalToSuperview()
                
                if let last = lastView {
                    make.left.equalTo(last.snp.right).offset(spacing)
                } else {
                    make.left.equalToSuperview().offset(16)
                }
            }
            
            lastView = card
            cardViews.append(card)
        }
        
        // 关键：决定 scrollView contentSize
        lastView?.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
        }
    }
}
