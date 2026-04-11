//
//  CalculateViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit

class CalculateViewController: UIViewController {

    // MARK: - Properties
    private var currentChartType: ChartType = .category
    private var chartData: StatisticsData = .empty

    enum ChartType: Int, CaseIterable {
        case category = 0
        case primaryLocation = 1
        case secondaryLocation = 2

        var title: String {
            switch self {
            case .category: return "数量统计"
            case .primaryLocation: return "一级位置"
            case .secondaryLocation: return "二级位置"
            }
        }
    }

    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .clear
        return sv
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "物品统计"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let statsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        sv.alignment = .fill
        return sv
    }()

    private lazy var countCard: StatsCardView = {
        let card = StatsCardView()
        card.configure(title: "物品数量", value: "0")
        return card
    }()

    private lazy var primaryTaggedCard: StatsCardView = {
        let card = StatsCardView()
        card.configure(title: "含一级位置", value: "0")
        return card
    }()

    private lazy var expiredCard: StatsCardView = {
        let card = StatsCardView()
        card.configure(title: "过期物品", value: "0")
        return card
    }()

    private let chartTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "分布图表"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let chartTypeStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fillEqually
        sv.alignment = .fill
        return sv
    }()

    private lazy var categoryButton: UIButton = {
        let button = createChartTypeButton(title: ChartType.category.title, tag: ChartType.category.rawValue)
        button.isSelected = true
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .selected)
        return button
    }()

    private lazy var primaryLocationButton: UIButton = {
        let button = createChartTypeButton(title: ChartType.primaryLocation.title, tag: ChartType.primaryLocation.rawValue)
        return button
    }()

    private lazy var secondaryLocationButton: UIButton = {
        let button = createChartTypeButton(title: ChartType.secondaryLocation.title, tag: ChartType.secondaryLocation.rawValue)
        return button
    }()

    private let chartContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()

    private var currentChartView: UIView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        applyStatistics()
        loadStatsData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatsData()
    }

    // MARK: - Setup
    private func setupUI() {

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)

        contentView.addSubview(statsStackView)
        statsStackView.addArrangedSubview(countCard)
        statsStackView.addArrangedSubview(primaryTaggedCard)
        statsStackView.addArrangedSubview(expiredCard)

        contentView.addSubview(chartTitleLabel)

        contentView.addSubview(chartTypeStackView)
        chartTypeStackView.addArrangedSubview(categoryButton)
        chartTypeStackView.addArrangedSubview(primaryLocationButton)
        chartTypeStackView.addArrangedSubview(secondaryLocationButton)

        contentView.addSubview(chartContainerView)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.left.equalTo(contentView).offset(20)
        }

        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(80)
        }

        chartTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(30)
            make.left.equalTo(contentView).offset(20)
        }

        chartTypeStackView.snp.makeConstraints { make in
            make.top.equalTo(chartTitleLabel.snp.bottom).offset(12)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(40)
        }

        chartContainerView.snp.makeConstraints { make in
            make.top.equalTo(chartTypeStackView.snp.bottom).offset(20)
            make.left.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.bottom.equalTo(contentView).offset(-30)
        }
    }

    private func createChartTypeButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.tag = tag
        button.addTarget(self, action: #selector(chartTypeButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    // MARK: - Data Loading
    private func loadStatsData() {
        ItemRepository.shared.loadData { [weak self] in
            DispatchQueue.main.async {
                self?.applyStatistics()
            }
        }
    }

    private func applyStatistics() {
        let repo = ItemRepository.shared
        let items = repo.getAllItems()
        chartData = StatisticsData.build(items: items, repository: repo)

        countCard.updateValue("\(items.count)")
        let primaryTagged = items.filter { !($0.primaryLocationId ?? "").isEmpty }.count
        primaryTaggedCard.updateValue("\(primaryTagged)")
        let expiredCount = items.filter { $0.isExpired }.count
        expiredCard.updateValue("\(expiredCount)")

        showChart(type: currentChartType)
    }

    // MARK: - Chart Management
    private func showChart(type: ChartType) {
        currentChartView?.removeFromSuperview()

        let rows: [StatisticsData.DistributionStat]
        switch type {
        case .category:
            rows = chartData.categoryData
        case .primaryLocation:
            rows = chartData.primaryLocationData
        case .secondaryLocation:
            rows = chartData.secondaryLocationData
        }

        let chartView = DistributionBarChartView(data: rows)
        chartContainerView.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        currentChartView = chartView
    }

    // MARK: - Actions
    @objc private func chartTypeButtonTapped(_ sender: UIButton) {
        [categoryButton, primaryLocationButton, secondaryLocationButton].forEach { button in
            button.isSelected = false
            button.backgroundColor = .white
            button.setTitleColor(.gray, for: .normal)
        }

        sender.isSelected = true
        sender.backgroundColor = .systemBlue
        sender.setTitleColor(.white, for: .selected)

        guard let type = ChartType(rawValue: sender.tag) else { return }
        currentChartType = type
        showChart(type: type)
    }
}

// MARK: - 统计卡片组件
class StatsCardView: UIView {

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4

        addSubview(valueLabel)
        addSubview(titleLabel)

        valueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(8)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }

    func updateValue(_ value: String) {
        valueLabel.text = value
    }
}

// MARK: - 数据模型
struct StatisticsData {
    let categoryData: [DistributionStat]
    let primaryLocationData: [DistributionStat]
    let secondaryLocationData: [DistributionStat]

    struct DistributionStat {
        let name: String
        let count: Int
        let total: Int
        let color: UIColor
    }

    static let empty = StatisticsData(categoryData: [], primaryLocationData: [], secondaryLocationData: [])

    private static let palette: [UIColor] = [
        .systemBlue, .systemGreen, .systemOrange, .systemPurple,
        .systemTeal, .systemIndigo, .systemPink, .systemBrown
    ]

    static func build(items: [ItemModel], repository: ItemRepository) -> StatisticsData {
        let totalCount = max(items.count, 1)

        if items.isEmpty {
            let placeholder = DistributionStat(name: "暂无物品", count: 0, total: 1, color: .systemGray3)
            return StatisticsData(
                categoryData: [placeholder],
                primaryLocationData: [placeholder],
                secondaryLocationData: [placeholder]
            )
        }

        // 分类
        let byCategory = Dictionary(grouping: items) { $0.categoryId }
        let categoryData: [DistributionStat] = byCategory
            .map { id, arr -> (String, [ItemModel]) in
                let name = repository.categories.first { $0.id == id }?.name ?? "未分类"
                return (name, arr)
            }
            .sorted { $0.1.count > $1.1.count }
            .enumerated()
            .map { idx, pair in
                DistributionStat(
                    name: pair.0,
                    count: pair.1.count,
                    total: items.count,
                    color: palette[idx % palette.count]
                )
            }

        // 一级位置
        let byPrimary = Dictionary(grouping: items) { $0.primaryLocationId ?? "" }
        let primaryLocationData: [DistributionStat] = byPrimary
            .map { key, arr -> (String, [ItemModel]) in
                let name: String
                if key.isEmpty {
                    name = "未设置一级位置"
                } else if let loc = repository.getPrimaryLocation(byId: key) {
                    name = loc.name
                } else {
                    name = "未知一级位置"
                }
                return (name, arr)
            }
            .sorted { $0.1.count > $1.1.count }
            .enumerated()
            .map { idx, pair in
                DistributionStat(
                    name: pair.0,
                    count: pair.1.count,
                    total: totalCount,
                    color: palette[idx % palette.count]
                )
            }

        // 二级位置
        let bySecondary = Dictionary(grouping: items) { $0.secondaryLocationId ?? "" }
        let secondaryLocationData: [DistributionStat] = bySecondary
            .map { key, arr -> (String, [ItemModel]) in
                let name: String
                if key.isEmpty {
                    name = "未设置二级位置"
                } else if let loc = repository.getSecondaryLocation(byId: key) {
                    name = loc.name
                } else {
                    name = "未知二级位置"
                }
                return (name, arr)
            }
            .sorted { $0.1.count > $1.1.count }
            .enumerated()
            .map { idx, pair in
                DistributionStat(
                    name: pair.0,
                    count: pair.1.count,
                    total: totalCount,
                    color: palette[idx % palette.count]
                )
            }

        return StatisticsData(
            categoryData: categoryData,
            primaryLocationData: primaryLocationData,
            secondaryLocationData: secondaryLocationData
        )
    }
}
// MARK: - 分布条形图（分类 / 一级位置 / 二级位置，高度随内容撑开，由外层页面 ScrollView 滚动）
class DistributionBarChartView: UIView {

    private let data: [StatisticsData.DistributionStat]

    init(data: [StatisticsData.DistributionStat]) {
        self.data = data
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        if data.isEmpty {
            let label = UILabel()
            label.text = "暂无数据"
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: 15)
            label.textAlignment = .center
            addSubview(label)
            label.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(24)
                make.bottom.equalToSuperview().offset(-24)
                make.left.right.equalToSuperview().inset(16)
            }
            return
        }

        var lastView: UIView?

        for (index, item) in data.enumerated() {
            let barView = createBarView(for: item, index: index)
            addSubview(barView)

            barView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(70)

                if let lastView = lastView {
                    make.top.equalTo(lastView.snp.bottom).offset(16)
                } else {
                    make.top.equalToSuperview().offset(16)
                }
            }

            lastView = barView
        }

        lastView?.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func createBarView(for item: StatisticsData.DistributionStat, index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.text = item.name
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail

        let valueLabel = UILabel()
        valueLabel.text = "\(item.count)/\(item.total)"
        valueLabel.font = .systemFont(ofSize: 12)
        valueLabel.textColor = .gray
        valueLabel.textAlignment = .right
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let backgroundBar = UIView()
        backgroundBar.backgroundColor = .systemGray5
        backgroundBar.layer.cornerRadius = 6

        let progressBar = UIView()
        progressBar.backgroundColor = item.color
        progressBar.layer.cornerRadius = 6

        let denominator = max(item.total, 1)
        let percentage = Float(item.count) / Float(denominator)

        view.addSubview(titleLabel)
        view.addSubview(valueLabel)
        view.addSubview(backgroundBar)
        backgroundBar.addSubview(progressBar)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.lessThanOrEqualTo(valueLabel.snp.left).offset(-8)
        }

        valueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview()
        }

        backgroundBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(24)
            make.bottom.equalToSuperview()
        }

        progressBar.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(backgroundBar.snp.width).multipliedBy(percentage)
        }

        return view
    }
}

