//
//  ItemDetailPopupViewController.swift
//  ItemManage
//

import UIKit
import SnapKit
import Kingfisher

class ItemDetailPopupViewController: UIViewController {

    private final class InsetLabel: UILabel {
        var textInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)

        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: textInsets))
        }

        override var intrinsicContentSize: CGSize {
            let s = super.intrinsicContentSize
            return CGSize(
                width: s.width + textInsets.left + textInsets.right,
                height: s.height + textInsets.top + textInsets.bottom
            )
        }
    }
    
    // MARK: - Properties
    private let item: ItemModel
    private let repository = ItemRepository.shared
    
    // MARK: - UI Elements
    // 卡片容器
    private lazy var cardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
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

    private lazy var locationTopLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor(white: 0.2, alpha: 1)
        label.numberOfLines = 1
        label.textAlignment = .right
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private lazy var categoryLabel: InsetLabel = {
        let label = InsetLabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)  // 字体调大
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 8  // 圆角调大
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    private lazy var quantityBadge: InsetLabel = {
        let label = InsetLabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.backgroundColor = UIColor(hex: "#6C7A89")
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    private lazy var statusBadge: InsetLabel = {
        let label = InsetLabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.backgroundColor = UIColor(hex: "#4CAF50")
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    private let badgesRow: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 10
        s.alignment = .center
        s.distribution = .fill
        return s
    }()

    private let badgesSpacer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private lazy var remarksPlainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(white: 0.55, alpha: 1)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.92, alpha: 1)
        return view
    }()

    /// 详情页展示物品照片（与列表/编辑页一致：优先本地路径，其次网络 URL）
    private lazy var photosScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = true
        sv.alwaysBounceHorizontal = true
        sv.clipsToBounds = true
        return sv
    }()

    private let photosStackView: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 12
        s.alignment = .center
        return s
    }()

    private var photosHeightConstraint: Constraint?

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
        button.setImage(nil, for: .normal)
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
        button.setImage(nil, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
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
        // 名称 + 位置（同一行）
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
        topStack.addArrangedSubview(locationTopLabel)
        locationTopLabel.setContentHuggingPriority(.required, for: .horizontal)
        locationTopLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // 分割线
        cardContentView.addSubview(dividerLine)
        dividerLine.snp.makeConstraints { make in
            make.top.equalTo(topStack.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }

        cardContentView.addSubview(photosScrollView)
        photosScrollView.addSubview(photosStackView)
        photosStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(photosScrollView.snp.height)
        }
        photosScrollView.snp.makeConstraints { make in
            make.top.equalTo(dividerLine.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            photosHeightConstraint = make.height.equalTo(0).constraint
        }

        // 分类 / 数量 / 状态 badges（放在图片下面；无图片时会紧贴分割线下方）
        cardContentView.addSubview(badgesRow)
        badgesRow.addArrangedSubview(categoryLabel)
        badgesRow.addArrangedSubview(quantityBadge)
        badgesRow.addArrangedSubview(statusBadge)
        badgesRow.addArrangedSubview(badgesSpacer)
        [categoryLabel, quantityBadge, statusBadge].forEach { label in
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        badgesSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        badgesSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        badgesRow.snp.makeConstraints { make in
            make.top.equalTo(photosScrollView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(26)
        }

        // 备注（灰色纯文本，放在标签下面）
        cardContentView.addSubview(remarksPlainLabel)
        remarksPlainLabel.snp.makeConstraints { make in
            make.top.equalTo(badgesRow.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 信息容器
        cardContentView.addSubview(infoContainer)
        infoContainer.snp.makeConstraints { make in
            make.top.equalTo(remarksPlainLabel.snp.bottom).offset(16)
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
        // 使用仓库中的最新数据（含合并后的 photos），避免弹窗持有旧引用导致图片为空
        let model = repository.getItem(byId: item.id) ?? item

        // 避免重复追加信息行
        infoContainer.arrangedSubviews.forEach { v in
            infoContainer.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        nameLabel.text = model.name
        configurePhotos(from: model)
        
        // 分类
        if let category = model.category {
            categoryLabel.text = " \(category.name) "
            let color = UIColor(hex: category.color)
            categoryLabel.backgroundColor = color
            
            categoryLabel.isHidden = false
        } else {
            categoryLabel.isHidden = true
        }

        // 数量 badge：显示“数量+单位”；无单位则显示“3(数量)”
        if let unit = model.unit, !unit.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            quantityBadge.text = "\(model.quantity)\(unit.name)"
        } else {
            quantityBadge.text = "\(model.quantity)(数量)"
        }
        quantityBadge.isHidden = false

        // 状态 badge：显示在图片下面（不在信息行里显示）
        if let expiryDate = model.expiryDate {
            let daysUntilExpire = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
            if daysUntilExpire < 0 {
                statusBadge.text = "已过期"
                statusBadge.backgroundColor = .systemRed
            } else if daysUntilExpire <= 3 {
                statusBadge.text = "即将过期"
                statusBadge.backgroundColor = .systemOrange
            } else {
                statusBadge.text = "正常"
                statusBadge.backgroundColor = .systemGreen
            }
            statusBadge.isHidden = false
        } else {
            statusBadge.isHidden = true
        }
        
        // 价格字段已移除（totalPrice）
        
        // 位置信息
        configureLocationInfo()
        // 原来的数量 / 生产日期 / 保质期 / 过期日期 / 状态：不显示
        
        // 备注
        if let remarks = model.remarks, !remarks.isEmpty {
            remarksPlainLabel.text = remarks
            remarksPlainLabel.isHidden = false
        } else {
            remarksPlainLabel.text = nil
            remarksPlainLabel.isHidden = true
        }
        
        // 不显示“暂无其他信息”
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        updateCardHeight()
    }

    private func configurePhotos(from model: ItemModel) {
        photosStackView.arrangedSubviews.forEach {
            photosStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        guard !model.photos.isEmpty else {
            photosHeightConstraint?.update(offset: 0)
            photosScrollView.isHidden = true
            return
        }

        photosScrollView.isHidden = false
        photosHeightConstraint?.update(offset: 112)

        for photo in model.photos {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 8
            iv.backgroundColor = .systemGray6
            iv.snp.makeConstraints { make in
                make.width.height.equalTo(100)
            }

            if let localPath = photo.localPath, !localPath.isEmpty, let img = UIImage(contentsOfFile: localPath) {
                iv.image = img
            } else {
                let raw = photo.remoteURLString.trimmingCharacters(in: .whitespacesAndNewlines)
                if !raw.isEmpty, let url = ItemDetailPopupViewController.resolvedPhotoURL(from: raw) {
                    iv.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
                } else {
                    iv.image = UIImage(systemName: "photo")
                    iv.tintColor = .systemGray3
                    iv.contentMode = .scaleAspectFit
                }
            }

            photosStackView.addArrangedSubview(iv)
        }
    }

    /// 支持 `http(s)://` 绝对地址。若为以 `/` 开头的相对路径，需后端返回完整 URL，或与 `ItemAPIClient` 共用同一套 base 后再拼接。
    private static func resolvedPhotoURL(from string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let u = URL(string: trimmed), u.scheme != nil {
            return u
        }
        return URL(string: trimmed)
    }
    
    private func addInfoRow(icon: String, title: String, value: String) {
        let row = InfoRow(icon: icon, title: title)
        row.setValue(value)
        infoContainer.addArrangedSubview(row)
    }
    
    private func configureLocationInfo() {
        let model = repository.getItem(byId: item.id) ?? item
        var locationPath: [String] = []
        
        // 添加一级位置
        if let primaryLocation = model.primaryLocation {
            locationPath.append(primaryLocation.name)
        }
        
        // 添加二级位置
        if let secondaryLocation = model.secondaryLocation {
            locationPath.append(secondaryLocation.name)
        }

        let text = locationPath.joined(separator: " → ")
        locationTopLabel.text = text
        locationTopLabel.isHidden = text.isEmpty
    }
    
    private func configureTimeInfo() {
        let model = repository.getItem(byId: item.id) ?? item
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        
        if let productionDate = model.productionDate {
            addInfoRow(icon: "calendar", title: "生产日期", value: formatter.string(from: productionDate))
        }
        
        if let shelfLife = model.shelfLife {
            addInfoRow(icon: "timer", title: "保质期", value: "\(shelfLife)天")
        }
        
        if let expiryDate = model.expiryDate {
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
        showCustomAlert(
            title: "删除物品",
            subtitle: "确定要删除「\(item.name)」吗？此操作不可撤销。",
            cancelTitle: "取消",
            confirmTitle: "删除",
            onCancel: nil,
            onConfirm: { [weak self] in
                self?.deleteItem()
            }
        )
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
