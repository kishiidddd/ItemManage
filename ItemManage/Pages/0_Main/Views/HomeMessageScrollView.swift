//
//  HomeMessageScrollView.swift
//  ItemManage
//
//  横向三条：收纳贴士、已过期数量、即将过期数量；有数据相对上次变化的一类排到前面。
//

import UIKit
import SnapKit

private enum HomeMessageCardKind: Int, CaseIterable {
    case guide = 0
    case expired = 1
    case soon = 2
}

class HomeMessageScrollView: UIView {

    /// 点击「今日贴士」卡片
    var onGuideSpotlightTapped: (() -> Void)?

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceHorizontal = true
        view.alwaysBounceVertical = false
        // 默认 delaysContentTouches=true，便于在可点卡片上仍能识别横向滑动
        view.canCancelContentTouches = true
        return view
    }()

    private lazy var contentView: UIView = UIView()

    private lazy var cardsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 12
        s.alignment = .center
        s.distribution = .fill
        return s
    }()

    private let cardWidth: CGFloat = 220
    private let cardHeight: CGFloat = 92
    /// 三张卡片 + 间距 + 左右边距（显式宽度，避免 contentSize 算不出来导致横滑失效）
    private var messageStripContentWidth: CGFloat {
        let cardCount: CGFloat = 3
        let gaps = max(0, cardCount - 1) * 12
        return 16 + cardWidth * cardCount + gaps + 16
    }

    // MARK: 贴士卡片
    private let guideSpotlightTitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.numberOfLines = 2
        l.text = "收纳指南"
        return l
    }()

    private lazy var guideSpotlightCard: UIView = {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 22
        card.layer.masksToBounds = true

        let icon = UIImageView(image: UIImage(systemName: "books.vertical.fill"))
        icon.tintColor = .systemIndigo
        icon.contentMode = .scaleAspectFit
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)

        let subtitle = UILabel()
        subtitle.text = "今日贴士"
        subtitle.font = .systemFont(ofSize: 12, weight: .medium)
        subtitle.textColor = .secondaryLabel

        let hit = UIButton(type: .custom)
        hit.backgroundColor = .clear
        hit.addTarget(self, action: #selector(guideCardTapped), for: .touchUpInside)
        card.addSubview(hit)
        hit.snp.makeConstraints { $0.edges.equalToSuperview() }

        card.addSubview(icon)
        card.addSubview(subtitle)
        card.addSubview(guideSpotlightTitleLabel)
        icon.isUserInteractionEnabled = false
        subtitle.isUserInteractionEnabled = false
        guideSpotlightTitleLabel.isUserInteractionEnabled = false

        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        subtitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalTo(icon.snp.right).offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-12)
        }
        guideSpotlightTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitle.snp.bottom).offset(4)
            make.left.equalTo(icon.snp.right).offset(12)
            make.right.equalToSuperview().offset(-14)
            make.bottom.lessThanOrEqualToSuperview().offset(-14)
        }

        card.snp.makeConstraints { make in
            make.width.equalTo(cardWidth)
            make.height.equalTo(cardHeight)
        }
        return card
    }()

    // MARK: 已过期卡片
    private let expiredCountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .label
        l.text = "0"
        return l
    }()

    private lazy var expiredCard: UIView = {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 22
        card.layer.masksToBounds = true

        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        icon.tintColor = .systemRed
        icon.contentMode = .scaleAspectFit
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)

        let subtitle = UILabel()
        subtitle.text = "已过期"
        subtitle.font = .systemFont(ofSize: 12, weight: .medium)
        subtitle.textColor = .secondaryLabel

        let hit = UIButton(type: .custom)
        hit.backgroundColor = .clear
        hit.addTarget(self, action: #selector(expiredCardTapped), for: .touchUpInside)
        card.addSubview(hit)
        hit.snp.makeConstraints { $0.edges.equalToSuperview() }

        card.addSubview(icon)
        card.addSubview(subtitle)
        card.addSubview(expiredCountLabel)
        icon.isUserInteractionEnabled = false
        subtitle.isUserInteractionEnabled = false
        expiredCountLabel.isUserInteractionEnabled = false

        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        subtitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalTo(icon.snp.right).offset(12)
        }
        expiredCountLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitle.snp.bottom).offset(4)
            make.left.equalTo(icon.snp.right).offset(12)
            make.right.equalToSuperview().offset(-14)
        }

        card.snp.makeConstraints { make in
            make.width.equalTo(cardWidth)
            make.height.equalTo(cardHeight)
        }
        return card
    }()

    // MARK: 即将过期卡片
    private let soonCountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .label
        l.text = "0"
        return l
    }()

    private lazy var soonCard: UIView = {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 22
        card.layer.masksToBounds = true

        let icon = UIImageView(image: UIImage(systemName: "clock.fill"))
        icon.tintColor = .systemOrange
        icon.contentMode = .scaleAspectFit
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)

        let subtitle = UILabel()
        subtitle.text = "即将过期"
        subtitle.font = .systemFont(ofSize: 12, weight: .medium)
        subtitle.textColor = .secondaryLabel

        let hit = UIButton(type: .custom)
        hit.backgroundColor = .clear
        hit.addTarget(self, action: #selector(soonCardTapped), for: .touchUpInside)
        card.addSubview(hit)
        hit.snp.makeConstraints { $0.edges.equalToSuperview() }

        card.addSubview(icon)
        card.addSubview(subtitle)
        card.addSubview(soonCountLabel)
        icon.isUserInteractionEnabled = false
        subtitle.isUserInteractionEnabled = false
        soonCountLabel.isUserInteractionEnabled = false

        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        subtitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalTo(icon.snp.right).offset(12)
        }
        soonCountLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitle.snp.bottom).offset(4)
            make.left.equalTo(icon.snp.right).offset(12)
            make.right.equalToSuperview().offset(-14)
        }

        card.snp.makeConstraints { make in
            make.width.equalTo(cardWidth)
            make.height.equalTo(cardHeight)
        }
        return card
    }()

    /// 当前用于弹窗的列表快照
    private var expiredItemsSnapshot: [ItemModel] = []
    private var soonItemsSnapshot: [ItemModel] = []

    /// 用于判断「相对上次是否变化」
    private var lastGuideKey: String = ""
    private var lastExpiredSignature: String = ""
    private var lastSoonSignature: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        applyCardOrder([.guide, .expired, .soon])
        updateGuideSpotlight()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    /// 同步贴士标题 + 过期统计 + 卡片顺序（在 `allItems` 与指南缓存更新后调用）
    func updateFromHome(allItems: [ItemModel]) {
        updateGuideSpotlight()

        let expired = allItems.filter { $0.isExpired }
        let soon = allItems.filter { !$0.isExpired && $0.isExpiringSoon }

        expiredItemsSnapshot = expired
        soonItemsSnapshot = soon
        expiredCountLabel.text = "\(expired.count)"
        soonCountLabel.text = "\(soon.count)"

        let guideKey = StorageGuideItem.spotlight(in: StorageGuideRuntimeData.displayItems)?.title ?? ""
        let expSig = itemSignature(expired)
        let soonSig = itemSignature(soon)

        var changed = Set<HomeMessageCardKind>()
        if guideKey != lastGuideKey { changed.insert(.guide) }
        if expSig != lastExpiredSignature { changed.insert(.expired) }
        if soonSig != lastSoonSignature { changed.insert(.soon) }

        lastGuideKey = guideKey
        lastExpiredSignature = expSig
        lastSoonSignature = soonSig

        let base: [HomeMessageCardKind] = [.guide, .expired, .soon]
        let movedToFront = base.filter { changed.contains($0) }
        let rest = base.filter { !changed.contains($0) }
        applyCardOrder(movedToFront + rest)
    }

    /// 仅刷新贴士文案（兼容原调用）
    func updateGuideSpotlight() {
        let items = StorageGuideRuntimeData.displayItems
        if let spot = StorageGuideItem.spotlight(in: items) {
            guideSpotlightTitleLabel.text = spot.title
            guideSpotlightTitleLabel.textColor = .label
        } else {
            guideSpotlightTitleLabel.text = "收纳指南"
            guideSpotlightTitleLabel.textColor = .secondaryLabel
        }
    }

    private func itemSignature(_ items: [ItemModel]) -> String {
        items.map(\.id).sorted().joined(separator: ",")
    }

    private func applyCardOrder(_ order: [HomeMessageCardKind]) {
        cardsStack.arrangedSubviews.forEach {
            cardsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for k in order {
            switch k {
            case .guide: cardsStack.addArrangedSubview(guideSpotlightCard)
            case .expired: cardsStack.addArrangedSubview(expiredCard)
            case .soon: cardsStack.addArrangedSubview(soonCard)
            }
        }
        setNeedsLayout()
    }

    @objc private func guideCardTapped() {
        onGuideSpotlightTapped?()
    }

    /// 由 `MainViewController` 注入，用于弹出大卡片
    weak var presentingHost: UIViewController?

    @objc private func expiredCardTapped() {
        guard let host = presentingHost else { return }
        let vc = HomeExpiryItemsListViewController(mode: .expired, items: expiredItemsSnapshot)
        host.present(vc, animated: true)
    }

    @objc private func soonCardTapped() {
        guard let host = presentingHost else { return }
        let vc = HomeExpiryItemsListViewController(mode: .expiringSoon, items: soonItemsSnapshot)
        host.present(vc, animated: true)
    }

    private func setupUI() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(contentView)
        contentView.addSubview(cardsStack)
        // 不用 Auto Layout 绑 contentSize（部分环境下 contentLayoutGuide 宽度仍等于可视宽 → 整根条滑不动）
        contentView.translatesAutoresizingMaskIntoConstraints = true
        cardsStack.translatesAutoresizingMaskIntoConstraints = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let sh = scrollView.bounds.height
        let sw = scrollView.bounds.width
        guard sh > 1, sw > 1 else { return }
        let cw = messageStripContentWidth
        scrollView.contentSize = CGSize(width: cw, height: sh)
        contentView.frame = CGRect(x: 0, y: 0, width: cw, height: sh)
        let stackY = (sh - cardHeight) / 2
        cardsStack.frame = CGRect(x: 16, y: stackY, width: cw - 32, height: cardHeight)
        cardsStack.layoutIfNeeded()
    }
}
