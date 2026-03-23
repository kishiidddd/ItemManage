//
//  HomeItemsView.swift
//  ItemManage
//

import UIKit
import SnapKit
import Kingfisher

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
    
    // MARK: 物品列表 - 使用 UITableView
    private lazy var itemsTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = true
        tv.register(HomeItemCell.self, forCellReuseIdentifier: HomeItemCell.identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        return tv
    }()
    
    // MARK: 空状态视图
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "tray")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "该分类暂无物品"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.height.equalTo(60)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        
        view.isHidden = true
        return view
    }()
    
    // MARK: 分类状态
    private var categoryLabels: [UILabel] = []
    private var indicatorViews: [UIView] = []
    private var selectedIndex: Int = 0
    
    // MARK: - Data
    private var allItems: [ItemModel] = []
    private var currentItems: [ItemModel] = []
    private var categories: [CategoryModel] = []
    
    private var categoryNames: [String] {
        return ["全部", "最近添加"] + categories.map { $0.name }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        loadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        addSubview(containerView)
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
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
        
        // 物品列表
        containerView.addSubview(itemsTableView)
        itemsTableView.snp.makeConstraints {
            $0.top.equalTo(categoryScrollView.snp.bottom).offset(8)
            $0.left.right.bottom.equalToSuperview()
        }
        
        // 空状态视图
        itemsTableView.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(150)
        }
    }
    
    // MARK: - Data Loading - 直接使用 MockDataService
    private func loadData() {
        // 直接从 MockDataService 获取数据
        categories = MockDataService.shared.getCategories()
        allItems = MockDataService.shared.getItems()
        
        // 设置分类UI
        setupCategories()
        
        // 默认显示全部物品
        filterItemsByCategory(index: 0)
    }
    
    // MARK: - 分类设置
    private func setupCategories() {
        categoryContentView.subviews.forEach { $0.removeFromSuperview() }
        categoryLabels.removeAll()
        indicatorViews.removeAll()
        
        var lastView: UIView?
        
        for (index, categoryName) in categoryNames.enumerated() {
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
            
            let label = UILabel()
            label.text = categoryName
            label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.tag = index
            label.isUserInteractionEnabled = true
            
            container.addSubview(label)
            label.snp.makeConstraints { $0.top.left.right.equalToSuperview() }
            
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
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped(_:)))
            label.addGestureRecognizer(tap)
            
            categoryLabels.append(label)
            indicatorViews.append(indicator)
            lastView = container
        }
        
        lastView?.snp.makeConstraints { $0.right.equalToSuperview().offset(-16) }
        updateCategorySelection(index: 0)
    }
    
    @objc private func categoryTapped(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        updateCategorySelection(index: label.tag)
        filterItemsByCategory(index: label.tag)
    }
    
    private func updateCategorySelection(index: Int) {
        selectedIndex = index
        for i in 0..<categoryLabels.count {
            categoryLabels[i].textColor = i == index ? .black : .darkGray
            indicatorViews[i].isHidden = i != index
        }
    }
    
    // MARK: - 分类筛选 - 使用 MockDataService 的方法
    private func filterItemsByCategory(index: Int) {
        switch index {
        case 0: // 全部
            currentItems = allItems
        case 1: // 最近添加
            currentItems = MockDataService.shared.getRecentItems()
        default: // 具体分类
            let categoryIndex = index - 2
            if categoryIndex < categories.count {
                let categoryId = categories[categoryIndex].id
                currentItems = MockDataService.shared.getItems(byCategoryId: categoryId)
            } else {
                currentItems = []
            }
        }
        
        // 更新空状态显示
        emptyStateView.isHidden = !currentItems.isEmpty
        itemsTableView.reloadData()
    }
    
    // MARK: - Public Methods
    func refreshData() {
        loadData()
    }
    
    func addItem(_ item: ItemModel) {
        // 这里应该调用 MockDataService 的添加方法
        // 但 MockDataService 目前是只读的，如果需要添加功能，可以扩展
        allItems.append(item)
        filterItemsByCategory(index: selectedIndex)
    }
    
    func removeItem(withId id: String) {
        // 这里应该调用 MockDataService 的删除方法
        allItems.removeAll { $0.id == id }
        filterItemsByCategory(index: selectedIndex)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension HomeItemsView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeItemCell.identifier, for: indexPath) as? HomeItemCell else {
            return UITableViewCell()
        }
        
        let item = currentItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = currentItems[indexPath.row]

        // 发送通知或通过代理传递选中的物品
        NotificationCenter.default.post(name: NSNotification.Name("DidSelectItem"), object: item)
    }
}
