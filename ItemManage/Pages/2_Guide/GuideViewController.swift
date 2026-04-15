//
//  StorageGuideViewController.swift
//  ItemManage — 收纳指南（原「统计」Tab）
//

import UIKit
import SnapKit

final class GuideViewController: UIViewController {

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.separatorStyle = .none
        t.backgroundColor = .lightGrayBgColor
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 160
        return t
    }()

    private var displayedItems: [GuideCollectItem] = []
    /// 主推在 `displayedItems` 中的下标
    private var spotlightIndex: Int = 0
    /// 除主推外的原始下标顺序
    private var otherIndices: [Int] = []
    private var selectedOriginalIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = nil
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .lightGrayBgColor

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StorageGuideHeroTableCell.self, forCellReuseIdentifier: StorageGuideHeroTableCell.reuseId)
        tableView.register(StorageGuideTipTableCell.self, forCellReuseIdentifier: StorageGuideTipTableCell.reuseId)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        setupTableHeader()
        applyItems(GuideCollectRuntimeData.displayItems)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesDidChange),
            name: .storageGuideFavoritesDidChange,
            object: nil
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let header = tableView.tableHeaderView else { return }
        let w = tableView.bounds.width
        if w > 0, header.frame.width != w {
            header.frame = CGRect(x: 0, y: 0, width: w, height: 52)
            tableView.tableHeaderView = header
        }
    }

    private func setupTableHeader() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 52))
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "icon_tips")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(openFavorites), for: .touchUpInside)
        header.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
        tableView.tableHeaderView = header
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadTipsFromNetwork()
    }

    private func applyItems(_ items: [GuideCollectItem]) {
        displayedItems = items
        selectedOriginalIndex = nil
        if items.isEmpty {
            otherIndices = []
        } else {
            spotlightIndex = items.firstIndex { $0.showInMain } ?? 0
            otherIndices = items.indices.filter { $0 != spotlightIndex }
        }
        tableView.reloadData()
    }

    private func loadTipsFromNetwork() {
        GuideCollectAPI.fetchTips { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let items):
                    GuideCollectRuntimeData.applyServerItems(items)
                    self.applyItems(items)
                    self.favoritesDidChange()
                case .failure:
                    break
                }
            }
        }
    }

    private func originalIndex(for indexPath: IndexPath) -> Int {
        if indexPath.row == 0 { return spotlightIndex }
        return otherIndices[indexPath.row - 1]
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func openFavorites() {
        let vc = GuideCollectViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func favoritesDidChange() {
        tableView.reloadData()
    }

    @objc private func starTapped(_ sender: UIButton) {
        toggleFavorite(at: sender.tag)
    }

    private func toggleFavorite(at originalIndex: Int) {
        guard originalIndex >= 0, originalIndex < displayedItems.count else { return }
        let item = displayedItems[originalIndex]
        let store = GuideCollectStore.shared
        if store.isFavorite(title: item.title, body: item.body) {
            store.remove(title: item.title, body: item.body)
            tableView.reloadData()
            return
        }
        switch store.add(title: item.title, body: item.body) {
        case .success:
            tableView.reloadData()
        case .failure:
            let alert = UIAlertController(
                title: "已达收藏上限",
                message: "最多只能收藏 \(GuideCollectStore.maxFavorites) 条贴士，可在收藏列表中取消部分后再试。",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "好的", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - UITableView

extension GuideViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedItems.isEmpty ? 0 : 1 + otherIndices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orig = originalIndex(for: indexPath)
        let item = displayedItems[orig]
        let selected = selectedOriginalIndex == orig
        let favorited = GuideCollectStore.shared.isFavorite(title: item.title, body: item.body)

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: StorageGuideHeroTableCell.reuseId, for: indexPath) as! StorageGuideHeroTableCell
            cell.configure(
                item: item,
                originalIndex: orig,
                selected: selected,
                favorited: favorited,
                starTarget: self,
                starAction: #selector(starTapped(_:))
            )
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: StorageGuideTipTableCell.reuseId, for: indexPath) as! StorageGuideTipTableCell
        cell.configure(
            item: item,
            originalIndex: orig,
            selected: selected,
            favorited: favorited,
            starTarget: self,
            starAction: #selector(starTapped(_:))
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        selectedOriginalIndex = originalIndex(for: indexPath)
        tableView.reloadData()
    }
}

// MARK: - Cells

private final class StorageGuideHeroTableCell: UITableViewCell {
    static let reuseId = "StorageGuideHeroTableCell"

    private let card = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let starButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.layer.cornerRadius = 12
        card.backgroundColor = .systemBlue

        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        bodyLabel.font = .systemFont(ofSize: 16)
        bodyLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0

        starButton.tintColor = .systemYellow
        starButton.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 22, weight: .medium),
            forImageIn: .normal
        )

        contentView.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(bodyLabel)
        card.addSubview(starButton)

        card.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview().offset(-12)
        }
        starButton.snp.makeConstraints { make in
            make.top.equalTo(card).offset(18)
            make.right.equalTo(card).offset(-12)
            make.width.height.equalTo(40)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(starButton)
            make.left.equalTo(card).offset(36)
            make.right.equalTo(starButton.snp.left).offset(-4)
        }
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.left.equalTo(card).offset(18)
            make.right.equalTo(card).offset(-18)
            make.bottom.equalTo(card).offset(-22)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(
        item: GuideCollectItem,
        originalIndex: Int,
        selected: Bool,
        favorited: Bool,
        starTarget: Any?,
        starAction: Selector
    ) {
        titleLabel.text = item.title
        bodyLabel.text = item.body
        starButton.tag = originalIndex
        starButton.removeTarget(nil, action: nil, for: .touchUpInside)
        starButton.addTarget(starTarget, action: starAction, for: .touchUpInside)
        let starName = favorited ? "star.fill" : "star"
        starButton.setImage(UIImage(systemName: starName), for: .normal)
        card.layer.borderWidth = selected ? 2 : 0
        card.layer.borderColor = selected ? UIColor.white.cgColor : nil
    }
}

private final class StorageGuideTipTableCell: UITableViewCell {
    static let reuseId = "StorageGuideTipTableCell"

    private let card = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let starButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.layer.cornerRadius = 12
        card.backgroundColor = .secondarySystemGroupedBackground

        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        bodyLabel.font = .systemFont(ofSize: 15)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 0

        starButton.tintColor = .systemYellow
        starButton.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 18, weight: .medium),
            forImageIn: .normal
        )

        contentView.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(bodyLabel)
        card.addSubview(starButton)

        card.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview().offset(-12)
        }
        starButton.snp.makeConstraints { make in
            make.top.equalTo(card).offset(12)
            make.right.equalTo(card).offset(-12)
            make.width.height.equalTo(36)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(card).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.lessThanOrEqualTo(starButton.snp.left).offset(-8)
        }
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-16)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(
        item: GuideCollectItem,
        originalIndex: Int,
        selected: Bool,
        favorited: Bool,
        starTarget: Any?,
        starAction: Selector
    ) {
        titleLabel.text = item.title
        bodyLabel.text = item.body
        starButton.tag = originalIndex
        starButton.removeTarget(nil, action: nil, for: .touchUpInside)
        starButton.addTarget(starTarget, action: starAction, for: .touchUpInside)
        let starName = favorited ? "star.fill" : "star"
        starButton.setImage(UIImage(systemName: starName), for: .normal)
        card.layer.borderWidth = selected ? 2 : 0
        card.layer.borderColor = selected ? UIColor.systemBlue.cgColor : nil
    }
}
