//
//  StorageGuideFavoritesViewController.swift
//  ItemManage — 收纳指南收藏列表（本地存标题+正文，最多 8 条）
//

import UIKit
import SnapKit

final class StorageGuideFavoritesViewController: UIViewController {

    private var entries: [StorageGuideFavoriteEntry] = []

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.register(FavoriteTipCell.self, forCellReuseIdentifier: FavoriteTipCell.reuseId)
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 100
        return t
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "暂无收藏\n在指南中点击星标添加（最多 8 条）"
        l.font = .systemFont(ofSize: 16)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的收藏"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(32)
        }

        tableView.dataSource = self
        tableView.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .storageGuideFavoritesDidChange, object: nil)
        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func reload() {
        entries = StorageGuideFavoritesStore.shared.entries
        tableView.reloadData()
        emptyLabel.isHidden = !entries.isEmpty
        tableView.isHidden = entries.isEmpty
    }
}

extension StorageGuideFavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTipCell.reuseId, for: indexPath) as! FavoriteTipCell
        let entry = entries[indexPath.row]
        cell.configure(entry: entry) { [weak self] in
            StorageGuideFavoritesStore.shared.remove(title: entry.title, body: entry.body)
            self?.reload()
        }
        return cell
    }
}

// MARK: - Cell

private final class FavoriteTipCell: UITableViewCell {
    static let reuseId = "FavoriteTipCell"

    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let starButton = UIButton(type: .system)
    private var onUnfavorite: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        bodyLabel.font = .systemFont(ofSize: 15)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 0

        starButton.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 20, weight: .medium),
            forImageIn: .normal
        )
        starButton.tintColor = .systemYellow
        starButton.addTarget(self, action: #selector(starTapped), for: .touchUpInside)

        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(starButton)

        starButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(36)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.lessThanOrEqualTo(starButton.snp.left).offset(-8)
        }
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(entry: StorageGuideFavoriteEntry, onUnfavorite: @escaping () -> Void) {
        titleLabel.text = entry.title
        bodyLabel.text = entry.body
        self.onUnfavorite = onUnfavorite
        starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
    }

    @objc private func starTapped() {
        onUnfavorite?()
    }
}
