//
//  HomeItemsView.swift
//  ItemManage
//

import UIKit
import SnapKit

class HomeItemsView: UIView {
    
    // MARK: - UI
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    
    // MARK: 分类横向 scroll
    
    private lazy var categoryScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private lazy var categoryContentView = UIView()
    
    
    // MARK: 物品纵向 scroll
    
    private lazy var itemsScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    
    private lazy var itemsContentView = UIView()
    
    
    // MARK: stack
    
    private lazy var itemsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    
    // MARK: 分类状态
    
    private var categoryLabels: [UILabel] = []
    private var indicatorViews: [UIView] = []
    
    private var selectedIndex: Int = 0
    
    
    // MARK: Data
    
    private var categories = [
        "全部",
        "最近添加",
        "书籍",
        "电子",
        "衣服",
        "游戏",
        "数码"
    ]
    
    private var items: [(name: String, count: Int)] = [
        ("MacBook Pro", 1),
        ("Sony 相机", 2),
        ("AirPods", 1),
        ("键盘", 3),
        ("显示器", 1),
        ("iPad", 2),
        ("耳机", 1),
        ("鼠标", 2),
        ("PS5", 1),
        ("Switch", 1),
        ("相机镜头", 3),
        ("充电器", 4),
        ("U盘", 5),
        ("路由器", 1),
        ("音响", 2)
    ]
    
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupCategories()
        setupItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    // MARK: UI
    
    private func setupUI() {
        
        addSubview(containerView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        
        // 分类 scroll
        containerView.addSubview(categoryScrollView)
        
        categoryScrollView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        
        categoryScrollView.addSubview(categoryContentView)
        
        categoryContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        
        // 物品 scroll
        containerView.addSubview(itemsScrollView)
        
        itemsScrollView.snp.makeConstraints {
            $0.top.equalTo(categoryScrollView.snp.bottom).offset(16)
            $0.left.right.bottom.equalToSuperview()
        }
        
        
        // content view
        itemsScrollView.addSubview(itemsContentView)
        
        itemsContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview() // 关键：竖直滚动必须
        }
        
        
        // stack view
        itemsContentView.addSubview(itemsStackView)
        
        itemsStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    
    // MARK: 分类
    
    private func setupCategories() {
        
        var lastView: UIView?
        
        for (index, category) in categories.enumerated() {
            
            let container = UIView()
            categoryContentView.addSubview(container)
            
            
            container.snp.makeConstraints { make in
                
                make.centerY.equalToSuperview()
                
                if let last = lastView {
                    make.left.equalTo(last.snp.right).offset(20)
                } else {
                    make.left.equalToSuperview().offset(16)
                }
            }
            
            
            // label
            let label = UILabel()
            label.text = category
            
            label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            
            label.tag = index
            
            label.isUserInteractionEnabled = true
            
            container.addSubview(label)
            
            label.snp.makeConstraints {
                $0.top.left.right.equalToSuperview()
            }
            
            
            // indicator
            let indicator = UIView()
            indicator.backgroundColor = .systemBlue
            indicator.layer.cornerRadius = 3
            indicator.isHidden = true
            
            container.addSubview(indicator)
            
            indicator.snp.makeConstraints {
                $0.top.equalTo(label.snp.bottom).offset(6)
                $0.centerX.equalToSuperview()
                $0.width.equalTo(24)
                $0.height.equalTo(6)
                $0.bottom.equalToSuperview()
            }
            
            
            // tap
            let tap = UITapGestureRecognizer(
                target: self,
                action: #selector(categoryTapped(_:))
            )
            
            label.addGestureRecognizer(tap)
            
            
            categoryLabels.append(label)
            indicatorViews.append(indicator)
            
            lastView = container
        }
        
        
        lastView?.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
        }
        
        
        updateCategorySelection(index: 0)
    }
    
    
    @objc private func categoryTapped(_ gesture: UITapGestureRecognizer) {
        
        guard let label = gesture.view as? UILabel else { return }
        
        updateCategorySelection(index: label.tag)
    }
    
    
    private func updateCategorySelection(index: Int) {
        
        selectedIndex = index
        
        for i in 0..<categoryLabels.count {
            
            let label = categoryLabels[i]
            let indicator = indicatorViews[i]
            
            if i == index {
                
                label.textColor = .black
                indicator.isHidden = false
                
            } else {
                
                label.textColor = .darkGray
                indicator.isHidden = true
            }
        }
    }
    
    
    // MARK: Items
    
    private func setupItems() {
        
        for item in items {
            
            let itemView = createItemView(
                name: item.name,
                count: item.count
            )
            
            itemsStackView.addArrangedSubview(itemView)
        }
    }
    
    
    // MARK: Item View
    
    private func createItemView(
        name: String,
        count: Int
    ) -> UIView {
        
        let card = UIView()
        
        card.backgroundColor = UIColor(
            white: 0.97,
            alpha: 1
        )
        
        card.layer.cornerRadius = 16
        
        
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "item_default")
        
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.cornerRadius = 8
        
        imageView.clipsToBounds = true
        
        
        let nameLabel = UILabel()
        
        nameLabel.text = name
        
        nameLabel.font = UIFont.systemFont(
            ofSize: 16,
            weight: .medium
        )
        
        
        let countLabel = UILabel()
        
        countLabel.text = "数量：\(count)"
        
        countLabel.font = UIFont.systemFont(
            ofSize: 14
        )
        
        countLabel.textColor = .gray
        
        
        card.addSubview(imageView)
        card.addSubview(nameLabel)
        card.addSubview(countLabel)
        
        
        card.snp.makeConstraints {
            $0.height.equalTo(72)
        }
        
        
        imageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(imageView)
            $0.left.equalTo(imageView.snp.right).offset(12)
            $0.right.equalToSuperview().offset(-12)
        }
        
        
        countLabel.snp.makeConstraints {
            $0.bottom.equalTo(imageView)
            $0.left.equalTo(nameLabel)
        }
        
        
        return card
    }
}
