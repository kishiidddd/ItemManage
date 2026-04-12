//
//  HomeMessageScrollView.swift
//  ItemManage
//
//  Created by xiny on 2026/2/19.
//

import UIKit
import SnapKit

class HomeMessageScrollView: UIView {

    /// 点击首页「收纳指南」主推卡片时回调（由 `MainViewController` 切到指南 Tab）
    var onGuideSpotlightTapped: (() -> Void)?

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceHorizontal = true
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    private var cardViews: [UIView] = []

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

        card.addSubview(icon)
        card.addSubview(subtitle)
        card.addSubview(guideSpotlightTitleLabel)

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

        let tap = UITapGestureRecognizer(target: self, action: #selector(guideCardTapped))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true

        return card
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupCards()
        updateGuideSpotlight()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    /// 根据当前 `StorageGuideRuntimeData` 刷新首张卡片标题（网络或兜底数据）
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

    @objc private func guideCardTapped() {
        onGuideSpotlightTapped?()
    }

    private func setupUI() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    private func setupCards() {
        let cardWidth: CGFloat = 220
        let cardHeight: CGFloat = 92
        let spacing: CGFloat = 12

        var lastView: UIView?

        for i in 0..<4 {
            let card: UIView
            if i == 0 {
                card = guideSpotlightCard
            } else {
                let c = UIView()
                c.backgroundColor = .systemYellow.withAlphaComponent(0.35)
                c.layer.cornerRadius = 22
                c.layer.masksToBounds = true
                card = c
            }

            contentView.addSubview(card)

            card.snp.makeConstraints { make in
                make.width.equalTo(cardWidth)
                make.height.equalTo(cardHeight)
                make.centerY.equalToSuperview()

                if let last = lastView {
                    make.left.equalTo(last.snp.right).offset(spacing)
                } else {
                    make.left.equalToSuperview().offset(16)
                }
            }

            lastView = card
            cardViews.append(card)
        }

        lastView?.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
        }
    }
}
