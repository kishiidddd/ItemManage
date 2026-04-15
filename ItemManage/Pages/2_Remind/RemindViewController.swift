//
//  RemindViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit
import Kingfisher

class RemindViewController: UIViewController {
    
    // MARK: - Properties
    private var expiredItems: [ItemModel] = []
    private var selectedDate: Date = Date()
    
    /// 日历视图高度约束
    private var calendarHeightConstraint: Constraint?
    /// 表格视图高度约束（改为普通约束，不再动态更新）
    private var tableViewHeightConstraint: Constraint?
    
    // MARK: - UI Elements
    /// 日历视图
    private lazy var calendarView: CalenderView = {
        let view = CalenderView()
        // 监听高度变化
        view.onHeightChanged = { [weak self] height in
            self?.updateCalendarHeight(height)
        }
        view.onDateSelected = { [weak self] date in
            self?.updateSelectedDate(date)
        }
        
        return view
    }()
    
    /// 过期物品卡片
    private lazy var expiredCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        // 添加阴影
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        return view
    }()
    
    /// 卡片标题
    private lazy var cardTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.text = formatCardTitle(date: Date())
        return label
    }()
    
    /// 物品列表视图（有物品时显示）- 改为可滚动
    private lazy var itemsTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .singleLine
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        tv.register(ExpiredItemCell.self, forCellReuseIdentifier: ExpiredItemCell.identifier)
        tv.isScrollEnabled = true // 改为可滚动
        tv.delegate = self
        tv.dataSource = self
        tv.showsVerticalScrollIndicator = true
        tv.bounces = true
        return tv
    }()
    
    /// 空状态视图（无物品时显示）
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        
        let imageView = UIImageView()
        // 尝试加载图片，如果没有则使用系统图标
        if let image = UIImage(named: "remind_no_expired") {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "bell.slash")
            imageView.tintColor = .gray
        }
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "该日期暂无即将过期物品"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        
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
        
        return view
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadExpiredItems(for: selectedDate)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .lightGrayBgColor
        view.addSubview(calendarView)
        
        // 添加过期物品卡片
        view.addSubview(expiredCardView)
        expiredCardView.addSubview(cardTitleLabel)
        expiredCardView.addSubview(itemsTableView)
        expiredCardView.addSubview(emptyStateView)
        expiredCardView.addSubview(activityIndicator)
        
        // 初始隐藏空状态和表格
        emptyStateView.isHidden = true
        itemsTableView.isHidden = true
    }
    
    private func setupConstraints() {
        calendarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(80)
            calendarHeightConstraint = make.height.equalTo(370).constraint
        }
        
        // 过期卡片约束 - 底部延伸到 tab 上面（假设 tab 高度为 83）
        expiredCardView.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20) // 距离底部安全区域20
        }
        
        cardTitleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        // 表格视图 - 占满剩余空间，内部可滚动
        itemsTableView.snp.makeConstraints { make in
            make.top.equalTo(cardTitleLabel.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(cardTitleLabel.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(expiredCardView)
        }
    }
    
    // MARK: - Helper Methods
    private func formatCardTitle(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        let dateString = formatter.string(from: date)
        return "\(dateString)过期物品"
    }
    
    // MARK: - Data Loading
    private func loadExpiredItems(for date: Date) {
        activityIndicator.startAnimating()
        emptyStateView.isHidden = true
        itemsTableView.isHidden = true
        
        // 使用扩展方法获取过期物品
        ItemDataService.shared.getExpiredItems(for: date) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let items):
                    self.expiredItems = items
                    
                    if self.expiredItems.isEmpty {
                        // 无数据，显示空状态
                        self.emptyStateView.isHidden = false
                        self.itemsTableView.isHidden = true
                    } else {
                        // 有数据，显示表格
                        self.emptyStateView.isHidden = true
                        self.itemsTableView.isHidden = false
                        self.itemsTableView.reloadData()
                        
                        // 滚动到顶部
                        if self.expiredItems.count > 0 {
                            self.itemsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                        }
                    }
                    
                case .failure(let error):
                    // 错误处理
                    self.showError("加载数据失败：\(error.localizedDescription)")
                    self.emptyStateView.isHidden = false
                    self.itemsTableView.isHidden = true
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    private func updateSelectedDate(_ date: Date) {
        selectedDate = date
        cardTitleLabel.text = formatCardTitle(date: date)
        loadExpiredItems(for: date)
    }
    
    /// 更新日历高度
    private func updateCalendarHeight(_ height: CGFloat) {
        calendarHeightConstraint?.update(offset: height)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension RemindViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expiredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpiredItemCell.identifier, for: indexPath) as? ExpiredItemCell else {
            return UITableViewCell()
        }
        
        let item = expiredItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6) // 半透明黑色背景
        overlay.alpha = 0
        overlay.tag = 999
        
        // 获取 keyWindow
        guard let window = UIApplication.shared.keyWindow else { return }
        
        // 添加到 window 上，这样可以覆盖 tabbar
        window.addSubview(overlay)
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let item = expiredItems[indexPath.row]
        let popup = ItemDetailPopupViewController(item: item)
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: true)
    }
    
    // 可选：添加高度预估以优化滚动性能
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - ExpiredItemCell
class ExpiredItemCell: UITableViewCell {
    
    static let identifier = "ExpiredItemCell"
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let itemImageView = UIImageView()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let quantityLabel = UILabel()
    private let expireDateLabel = UILabel()
    private let warningIcon = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 容器视图
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)
        
        // 物品图片
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.clipsToBounds = true
        itemImageView.backgroundColor = .lightGray.withAlphaComponent(0.3)
        itemImageView.layer.cornerRadius = 8
        itemImageView.image = UIImage(systemName: "photo")
        itemImageView.tintColor = .gray
        
        // 名称
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 1
        
        // 分类
        categoryLabel.font = UIFont.systemFont(ofSize: 12)
        categoryLabel.textColor = .gray
        categoryLabel.numberOfLines = 1
        
        // 数量
        quantityLabel.font = UIFont.systemFont(ofSize: 14)
        quantityLabel.textColor = .darkGray
        quantityLabel.textAlignment = .right
        
        // 过期日期
        expireDateLabel.font = UIFont.systemFont(ofSize: 12)
        expireDateLabel.textColor = .gray
        expireDateLabel.textAlignment = .right
        expireDateLabel.numberOfLines = 1
        
        // 警告图标
        warningIcon.image = UIImage(systemName: "exclamationmark.triangle.fill")
        warningIcon.tintColor = .orange
        warningIcon.isHidden = true
        
        // 添加到容器
        containerView.addSubview(itemImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(quantityLabel)
        containerView.addSubview(expireDateLabel)
        containerView.addSubview(warningIcon)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }
        
        itemImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(itemImageView.snp.right).offset(12)
            make.right.lessThanOrEqualTo(quantityLabel.snp.left).offset(-8)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        quantityLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.width.greaterThanOrEqualTo(40)
        }
        
        expireDateLabel.snp.makeConstraints { make in
            make.top.equalTo(quantityLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-12)
            make.left.greaterThanOrEqualTo(categoryLabel.snp.right).offset(8)
        }
        
        warningIcon.snp.makeConstraints { make in
            make.right.equalTo(expireDateLabel.snp.left).offset(-4)
            make.centerY.equalTo(expireDateLabel)
            make.width.height.equalTo(16)
        }
    }
    
    func configure(with item: ItemModel) {
        nameLabel.text = item.name
        
        // 分类名称
        if let category = item.category {
            categoryLabel.text = category.name
        } else {
            categoryLabel.text = "未分类"
        }
        
        // 数量
        quantityLabel.text = "x\(item.quantity)"
        
        // 过期日期
        if let expiryDate = item.expiryDate {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "yyyy-MM-dd"
            expireDateLabel.text = formatter.string(from: expiryDate)
            
            // 判断过期状态
            let calendar = Calendar.current
            let daysUntilExpire = calendar.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
            
            if daysUntilExpire < 0 {
                // 已过期
                warningIcon.isHidden = false
                warningIcon.tintColor = .red
                expireDateLabel.textColor = .red
            } else if daysUntilExpire <= 3 {
                // 即将过期（3天内）
                warningIcon.isHidden = false
                warningIcon.tintColor = .orange
                expireDateLabel.textColor = .orange
            } else {
                // 正常
                warningIcon.isHidden = true
                expireDateLabel.textColor = .gray
            }
        } else {
            expireDateLabel.text = "无过期时间"
            warningIcon.isHidden = true
            expireDateLabel.textColor = .gray
        }
        
        // 加载图片
        if let firstPhoto = item.photos.first, let url = URL(string: firstPhoto.url) {
            itemImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        } else {
            itemImageView.image = UIImage(systemName: "photo")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.kf.cancelDownloadTask()
        itemImageView.image = UIImage(systemName: "photo")
    }
}

