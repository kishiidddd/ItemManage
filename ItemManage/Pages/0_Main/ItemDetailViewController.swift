//
//  ItemDetailPopupViewController.swift
//  ItemManage
//

import UIKit
import SnapKit
import Kingfisher

class ItemDetailPopupViewController: UIViewController {
    
    // MARK: - Properties
    private let item: ItemModel
    private let repository = ItemRepository.shared
    
    // MARK: - UI Elements
    // 卡片容器
    private lazy var cardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    // 卡片内部的滚动视图
    private lazy var cardScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = true
        sv.backgroundColor = .clear
        sv.alwaysBounceVertical = true
        sv.isScrollEnabled = true
        return sv
    }()
    
    private lazy var cardContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - 基本信息区域
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)  // 字体调大
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 6  // 圆角调大
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.92, alpha: 1)
        return view
    }()
    
    // MARK: - 信息行容器
    private lazy var infoContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - 按钮容器
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("编辑", for: .normal)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("删除", for: .normal)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 卡片高度约束
    private var cardHeightConstraint: Constraint?
    
    // MARK: - Init
    init(item: ItemModel) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithItem()
        
        // 点击背景关闭
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCardHeight()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        // 添加卡片容器
        view.addSubview(cardContainer)
        cardContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(30)
            self.cardHeightConstraint = make.height.equalTo(500).constraint
        }
        
        // 卡片内部滚动视图
        cardContainer.addSubview(cardScrollView)
        cardScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cardScrollView.addSubview(cardContentView)
        cardContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(cardScrollView)
        }
        
        // 添加内容到卡片内容视图
        setupCardContent()
    }
    
    private func setupCardContent() {
        // 名称和分类行
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.spacing = 12
        topStack.alignment = .center
        cardContentView.addSubview(topStack)
        topStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(16)
        }
        
        topStack.addArrangedSubview(nameLabel)
        topStack.addArrangedSubview(categoryLabel)
        categoryLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        // 分割线
        cardContentView.addSubview(dividerLine)
        dividerLine.snp.makeConstraints { make in
            make.top.equalTo(topStack.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }
        
        // 信息容器
        cardContentView.addSubview(infoContainer)
        infoContainer.snp.makeConstraints { make in
            make.top.equalTo(dividerLine.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 按钮容器
        cardContentView.addSubview(buttonStack)
        buttonStack.addArrangedSubview(editButton)
        buttonStack.addArrangedSubview(deleteButton)
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(infoContainer.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 设置按钮高度
        editButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        deleteButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    private func updateCardHeight() {
        let contentHeight = cardContentView.systemLayoutSizeFitting(
            CGSize(width: cardContainer.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        
        let maxHeight = UIScreen.main.bounds.height * 0.8
        let finalHeight = min(contentHeight, maxHeight)
        
        cardHeightConstraint?.update(offset: finalHeight)
        cardScrollView.isScrollEnabled = contentHeight > maxHeight
    }
    
    // MARK: - Configure
    private func configureWithItem() {
        nameLabel.text = item.name
        
        // 分类
        if let category = item.category {
            categoryLabel.text = " \(category.icon) \(category.name) "
            let color = UIColor(hex: category.color)
            categoryLabel.backgroundColor = color
            
            categoryLabel.isHidden = false
        } else {
            categoryLabel.isHidden = true
        }
        
        // 数量
        addInfoRow(icon: "number", title: "数量", value: "\(item.quantity)")
        
        // 单位
        if let unit = item.unit {
            addInfoRow(icon: "ruler", title: "单位", value: unit.name)
        }
        
        // 价格
        if let totalPrice = item.totalPrice {
            addInfoRow(icon: "yensign.circle", title: "价格", value: String(format: "¥%.2f", totalPrice))
        }
        
        // 位置信息
        configureLocationInfo()
        
        // 时效信息
        configureTimeInfo()
        
        // 备注
        if let remarks = item.remarks, !remarks.isEmpty {
            addInfoRow(icon: "note.text", title: "备注", value: remarks)
        }
        
        if infoContainer.arrangedSubviews.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "暂无其他信息"
            emptyLabel.font = UIFont.systemFont(ofSize: 14)
            emptyLabel.textColor = .lightGray
            emptyLabel.textAlignment = .center
            infoContainer.addArrangedSubview(emptyLabel)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        updateCardHeight()
    }
    
    private func addInfoRow(icon: String, title: String, value: String) {
        let row = InfoRow(icon: icon, title: title)
        row.setValue(value)
        infoContainer.addArrangedSubview(row)
    }
    
    private func configureLocationInfo() {
        var locationPath: [String] = []
        
        // 添加一级位置
        if let primaryLocation = item.primaryLocation {
            locationPath.append(primaryLocation.name)
        }
        
        // 添加二级位置
        if let secondaryLocation = item.secondaryLocation {
            locationPath.append(secondaryLocation.name)
        }
        
        if !locationPath.isEmpty {
            addInfoRow(icon: "location.fill", title: "位置", value: locationPath.joined(separator: " → "))
        }
    }
    
    private func configureTimeInfo() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        
        if let productionDate = item.productionDate {
            addInfoRow(icon: "calendar", title: "生产日期", value: formatter.string(from: productionDate))
        }
        
        if let shelfLife = item.shelfLife {
            addInfoRow(icon: "timer", title: "保质期", value: "\(shelfLife)天")
        }
        
        if let expiryDate = item.expiryDate {
            addInfoRow(icon: "exclamationmark.triangle", title: "过期日期", value: formatter.string(from: expiryDate))
            
            let daysUntilExpire = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
            
            var statusText = ""
            var statusColor: UIColor = .black
            
            if daysUntilExpire < 0 {
                statusText = "已过期"
                statusColor = .red
            } else if daysUntilExpire <= 3 {
                statusText = "即将过期（\(daysUntilExpire)天后）"
                statusColor = .orange
            } else {
                statusText = "正常（\(daysUntilExpire)天后过期）"
                statusColor = .green
            }
            
            let statusRow = InfoRow(icon: "info.circle", title: "状态")
            statusRow.setValue(statusText)
            statusRow.valueLabel.textColor = statusColor
            infoContainer.addArrangedSubview(statusRow)
        }
    }
    
    // MARK: - Actions
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
    
    @objc private func editButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let item = self?.item else { return }
            let editVC = AddItemViewController(item: item)
            if let topVC = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController() {
                topVC.navigationController?.pushViewController(editVC, animated: true)
            }
        }
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "删除物品",
            message: "确定要删除「\(item.name)」吗？此操作不可撤销。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.deleteItem()
        })
        
        present(alert, animated: true)
    }
    
    private func deleteItem() {
        // 直接通过 Repository 删除
        repository.deleteItem(id: item.id)
        
        // 发送通知（可选，因为 Repository 的 @Published 会自动触发 UI 更新）
        NotificationCenter.default.post(name: NSNotification.Name("ItemDeleted"), object: item.id)
        
        // 关闭弹窗
        dismiss(animated: true)
    }
    
//    @objc private func editButtonTapped() {
//        dismiss(animated: true) { [weak self] in
//            guard let item = self?.item else { return }
//            let editVC = AddItemViewController(item: item)
//            if let topVC = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController() {
//                topVC.navigationController?.pushViewController(editVC, animated: true)
//            }
//        }
//    }
//    
//    @objc private func deleteButtonTapped() {
//        let alert = UIAlertController(
//            title: "删除物品",
//            message: "确定要删除「\(item.name)」吗？此操作不可撤销。",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
//        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
//            self?.deleteItem()
//        })
//        
//        present(alert, animated: true)
//    }
//    
//    private func deleteItem() {
//        ItemDataService.shared.deleteItem(id: item.id) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    NotificationCenter.default.post(name: NSNotification.Name("ItemDeleted"), object: self?.item.id)
//                    self?.dismiss(animated: true)
//                case .failure(let error):
//                    let alert = UIAlertController(title: "提示", message: error.localizedDescription, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "确定", style: .default))
//                    self?.present(alert, animated: true)
//                }
//            }
//        }
//    }
}

// MARK: - InfoRow 自定义视图
class InfoRow: UIView {
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .systemBlue
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    init(icon: String, title: String) {
        super.init(frame: .zero)
        setupUI()
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 左侧固定宽度
        let leftContainer = UIView()
        leftContainer.snp.makeConstraints { make in
            make.width.equalTo(85)
        }
        
        let leftStack = UIStackView()
        leftStack.axis = .horizontal
        leftStack.spacing = 8
        leftStack.alignment = .center
        leftContainer.addSubview(leftStack)
        leftStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        leftStack.addArrangedSubview(iconImageView)
        leftStack.addArrangedSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(18)
        }
        
        stack.addArrangedSubview(leftContainer)
        stack.addArrangedSubview(valueLabel)
    }
    
    func setValue(_ value: String) {
        valueLabel.text = value
    }
}

// MARK: - UIViewController Extension
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? self
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? self
        }
        return self
    }
}
