//
//  StorageGuideViewController.swift
//  ItemManage — 收纳指南（原「统计」Tab）
//

import UIKit
import SnapKit

final class StorageGuideViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = true
        return sv
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.alignment = .fill
        return s
    }()

    /// 与 `starButtons` 下标一致，用于刷新星标状态
    private var displayedItems: [StorageGuideItem] = []
    private var starButtons: [Int: UIButton] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = nil
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-24)
            make.width.equalTo(scrollView.snp.width).offset(-40)
        }

        let headerRow = UIStackView()
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.distribution = .fill
        let headerSpacer = UIView()
        let favEntry = UIButton(type: .system)
        favEntry.setImage(UIImage(systemName: "star.square.on.square"), for: .normal)
        favEntry.tintColor = .label
        favEntry.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 22, weight: .medium),
            forImageIn: .normal
        )
        favEntry.addTarget(self, action: #selector(openFavorites), for: .touchUpInside)
        favEntry.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }
        headerRow.addArrangedSubview(headerSpacer)
        headerRow.addArrangedSubview(favEntry)
        contentStack.addArrangedSubview(headerRow)

        reloadTipCards(with: StorageGuideRuntimeData.displayItems)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesDidChange),
            name: .storageGuideFavoritesDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadTipsFromNetwork()
    }

    private func reloadTipCards(with items: [StorageGuideItem]) {
        while contentStack.arrangedSubviews.count > 1 {
            let v = contentStack.arrangedSubviews.last!
            contentStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        starButtons.removeAll()
        displayedItems = items
        for (index, item) in items.enumerated() {
            contentStack.addArrangedSubview(guideCard(item: item, index: index))
        }
    }

    private func loadTipsFromNetwork() {
        StorageGuideAPI.fetchTips { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let items):
                    StorageGuideRuntimeData.applyServerItems(items)
                    self.reloadTipCards(with: items)
                    self.favoritesDidChange()
                case .failure:
                    break
                }
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func openFavorites() {
        let vc = StorageGuideFavoritesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func favoritesDidChange() {
        let store = StorageGuideFavoritesStore.shared
        for idx in 0..<displayedItems.count {
            let item = displayedItems[idx]
            guard let button = starButtons[idx] else { continue }
            updateStarButton(button, favorited: store.isFavorite(title: item.title, body: item.body))
        }
    }

    private func toggleFavorite(at index: Int) {
        guard index >= 0, index < displayedItems.count else { return }
        let item = displayedItems[index]
        let store = StorageGuideFavoritesStore.shared
        if store.isFavorite(title: item.title, body: item.body) {
            store.remove(title: item.title, body: item.body)
            if let b = starButtons[index] { updateStarButton(b, favorited: false) }
            return
        }
        switch store.add(title: item.title, body: item.body) {
        case .success:
            if let b = starButtons[index] { updateStarButton(b, favorited: true) }
        case .failure:
            let alert = UIAlertController(
                title: "已达收藏上限",
                message: "最多只能收藏 \(StorageGuideFavoritesStore.maxFavorites) 条贴士，可在收藏列表中取消部分后再试。",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "好的", style: .default))
            present(alert, animated: true)
        }
    }

    private func updateStarButton(_ button: UIButton, favorited: Bool) {
        let name = favorited ? "star.fill" : "star"
        button.setImage(UIImage(systemName: name), for: .normal)
    }

    private func guideCard(item: StorageGuideItem, index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12

        let tl = UILabel()
        tl.text = item.title
        tl.font = .systemFont(ofSize: 17, weight: .semibold)
        tl.textColor = .label
        tl.numberOfLines = 0

        let bl = UILabel()
        bl.text = item.body
        bl.font = .systemFont(ofSize: 15)
        bl.textColor = .secondaryLabel
        bl.numberOfLines = 0

        let starButton = UIButton(type: .system)
        starButton.tintColor = .systemYellow
        starButton.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 18, weight: .medium),
            forImageIn: .normal
        )
        let idx = index
        starButton.addAction(UIAction { [weak self] _ in
            self?.toggleFavorite(at: idx)
        }, for: .touchUpInside)

        starButtons[index] = starButton
        updateStarButton(starButton, favorited: StorageGuideFavoritesStore.shared.isFavorite(title: item.title, body: item.body))

        card.addSubview(tl)
        card.addSubview(bl)
        card.addSubview(starButton)

        starButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(36)
        }
        tl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.lessThanOrEqualTo(starButton.snp.left).offset(-8)
        }
        bl.snp.makeConstraints { make in
            make.top.equalTo(tl.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }

        return card
    }
}
