//
//  HomeExpiryItemsListViewController.swift
//  ItemManage — 首页消息条：已过期 / 即将过期 物品大卡片列表
//

import UIKit
import SnapKit

/// 半屏大卡片，列出过期或即将过期物品；点击行进入详情弹窗
final class HomeExpiryItemsListViewController: UIViewController {

    enum Mode {
        case expired
        case expiringSoon
    }

    private let mode: Mode
    private let items: [ItemModel]

    private lazy var dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        v.addGestureRecognizer(tap)
        return v
    }()

    private lazy var panel: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .label
        return l
    }()

    private lazy var closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        b.tintColor = .secondaryLabel
        b.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return b
    }()

    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.register(HomeItemCell.self, forCellReuseIdentifier: HomeItemCell.identifier)
        t.separatorStyle = .singleLine
        t.backgroundColor = .clear
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 100
        return t
    }()

    init(mode: Mode, items: [ItemModel]) {
        self.mode = mode
        self.items = items
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        switch mode {
        case .expired:
            titleLabel.text = "已过期 · \(items.count) 件"
        case .expiringSoon:
            titleLabel.text = "即将过期 · \(items.count) 件"
        }

        view.addSubview(dimView)
        view.addSubview(panel)
        panel.addSubview(titleLabel)
        panel.addSubview(closeButton)
        panel.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self

        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }
        panel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.height.equalTo(view.snp.height).multipliedBy(0.62)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(20)
            make.right.lessThanOrEqualTo(closeButton.snp.left).offset(-8)
        }
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(36)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }

        if items.isEmpty {
            let empty = UILabel()
            empty.text = "暂无物品"
            empty.textColor = .secondaryLabel
            empty.font = .systemFont(ofSize: 16)
            empty.textAlignment = .center
            panel.addSubview(empty)
            empty.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(40)
            }
            tableView.isHidden = true
        }
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

extension HomeExpiryItemsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeItemCell.identifier, for: indexPath) as! HomeItemCell
        cell.configure(with: items[indexPath.row])
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        let popup = ItemDetailPopupViewController(item: item)
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: true)
    }
}
