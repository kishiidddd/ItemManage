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
    private let sampleData = StatisticsData.sampleData()
    
    enum ChartType: Int, CaseIterable {
        case category = 0
        case price = 1
        case time = 2
        
        var title: String {
            switch self {
            case .category: return "数量统计"
            case .price: return "价格统计"
            case .time: return "时间统计"
            }
        }
    }
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = .clear
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // 标题
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "物品统计"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    // 统计卡片容器
    private let statsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        sv.alignment = .fill
        return sv
    }()
    
    // 物品数量卡片
    private lazy var countCard: StatsCardView = {
        let card = StatsCardView()
        card.configure(title: "物品数量", value: "0")
        return card
    }()
    
    // 物品总价卡片
    private lazy var totalPriceCard: StatsCardView = {
        let card = StatsCardView()
        card.configure(title: "物品总价", value: "¥0")
        return card
    }()
    
    // 过期物品卡片
    private lazy var expiredCard: StatsCardView = {
        let card = StatsCardView()
        card.configure(title: "过期物品", value: "0")
        return card
    }()
    
    // 图表标题
    private let chartTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "分布图表"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    // 图表类型选择按钮容器
    private let chartTypeStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fillEqually
        sv.alignment = .fill
        return sv
    }()
    
    // 数量统计按钮
    private lazy var categoryButton: UIButton = {
        let button = createChartTypeButton(title: "数量统计", tag: 0)
        button.isSelected = true
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .selected)
        return button
    }()
    
    // 价格统计按钮
    private lazy var priceButton: UIButton = {
        let button = createChartTypeButton(title: "价格统计", tag: 1)
        return button
    }()
    
    // 时间统计按钮
    private lazy var timeButton: UIButton = {
        let button = createChartTypeButton(title: "时间统计", tag: 2)
        return button
    }()
    
    // 图表容器视图
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
    
    // 当前显示的图表视图
    private var currentChartView: UIView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadStatsData()
        showChart(type: .category)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "统计"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        
        // 添加统计卡片
        contentView.addSubview(statsStackView)
        statsStackView.addArrangedSubview(countCard)
        statsStackView.addArrangedSubview(totalPriceCard)
        statsStackView.addArrangedSubview(expiredCard)
        
        contentView.addSubview(chartTitleLabel)
        
        // 添加图表类型按钮
        contentView.addSubview(chartTypeStackView)
        chartTypeStackView.addArrangedSubview(categoryButton)
        chartTypeStackView.addArrangedSubview(priceButton)
        chartTypeStackView.addArrangedSubview(timeButton)
        
        // 添加图表容器
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
            make.height.equalTo(350)
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
        // 模拟数据加载
        ItemDataService.shared.getItems(page: 1) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let totalCount = response.pagination?.total ?? 0
                    let totalPrice = response.items.reduce(0) { $0 + ($1.totalPrice ?? 0) }
                    let expiredCount = response.items.filter { $0.isExpired }.count
                    
                    self?.countCard.updateValue("\(totalCount)")
                    self?.totalPriceCard.updateValue(String(format: "¥%.0f", totalPrice))
                    self?.expiredCard.updateValue("\(expiredCount)")
                    
                case .failure:
                    // 使用示例数据
                    self?.countCard.updateValue("28")
                    self?.totalPriceCard.updateValue("¥1,259")
                    self?.expiredCard.updateValue("3")
                }
            }
        }
    }
    
    // MARK: - Chart Management
    private func showChart(type: ChartType) {
        // 移除当前图表
        currentChartView?.removeFromSuperview()
        
        // 创建新图表
        let chartView: UIView
        switch type {
        case .category:
            chartView = CategoryBarChartView(data: sampleData.categoryData)
        case .price:
            chartView = PriceBarChartView(data: sampleData.priceData)
        case .time:
            chartView = TimeLineChartView(data: sampleData.timeData)
        }
        
        chartContainerView.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        currentChartView = chartView
    }
    
    // MARK: - Actions
    @objc private func chartTypeButtonTapped(_ sender: UIButton) {
        // 更新按钮状态
        [categoryButton, priceButton, timeButton].forEach { button in
            button.isSelected = false
            button.backgroundColor = .white
            button.setTitleColor(.gray, for: .normal)
        }
        
        sender.isSelected = true
        sender.backgroundColor = .systemBlue
        sender.setTitleColor(.white, for: .selected)
        
        // 更新图表类型
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
    let categoryData: [CategoryStat]
    let priceData: [PriceStat]
    let timeData: [TimeStat]
    
    struct CategoryStat {
        let name: String
        let count: Int
        let total: Int
        let color: UIColor
    }
    
    struct PriceStat {
        let range: String
        let count: Int
        let total: Int
        let color: UIColor
    }
    
    struct TimeStat {
        let date: String
        let count: Int
    }
    
    static func sampleData() -> StatisticsData {
        return StatisticsData(
            categoryData: [
                CategoryStat(name: "食品", count: 15, total: 28, color: .systemBlue),
                CategoryStat(name: "日用品", count: 8, total: 28, color: .systemGreen),
                CategoryStat(name: "电子产品", count: 3, total: 28, color: .systemOrange),
                CategoryStat(name: "服装", count: 2, total: 28, color: .systemPurple)
            ],
            priceData: [
                PriceStat(range: "0-50元", count: 12, total: 28, color: .systemBlue),
                PriceStat(range: "50-100元", count: 8, total: 28, color: .systemGreen),
                PriceStat(range: "100-500元", count: 5, total: 28, color: .systemOrange),
                PriceStat(range: "500元以上", count: 3, total: 28, color: .systemRed)
            ],
            timeData: [
                TimeStat(date: "3/10", count: 3),
                TimeStat(date: "3/11", count: 5),
                TimeStat(date: "3/12", count: 2),
                TimeStat(date: "3/13", count: 7),
                TimeStat(date: "3/14", count: 4),
                TimeStat(date: "3/15", count: 6),
                TimeStat(date: "3/16", count: 1)
            ]
        )
    }
}

// MARK: - 数量统计条形图（可滚动）
class CategoryBarChartView: UIScrollView {
    
    private let data: [StatisticsData.CategoryStat]
    private let containerView = UIView()
    
    init(data: [StatisticsData.CategoryStat]) {
        self.data = data
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        
        addSubview(containerView)
        
        var lastView: UIView?
        var totalHeight: CGFloat = 0
        
        for (index, item) in data.enumerated() {
            let barView = createBarView(for: item, index: index)
            containerView.addSubview(barView)
            
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
            totalHeight += 86
        }
        
        if let lastView = lastView {
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.width.equalToSuperview()
                make.bottom.equalTo(lastView).offset(16)
            }
            
            contentSize = CGSize(width: 0, height: totalHeight)
        }
    }
    
    private func createBarView(for item: StatisticsData.CategoryStat, index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = item.name
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .black
        
        // 数值
        let valueLabel = UILabel()
        valueLabel.text = "\(item.count)/\(item.total)"
        valueLabel.font = .systemFont(ofSize: 12)
        valueLabel.textColor = .gray
        valueLabel.textAlignment = .right
        
        // 背景条（灰色）
        let backgroundBar = UIView()
        backgroundBar.backgroundColor = .systemGray5
        backgroundBar.layer.cornerRadius = 6
        
        // 进度条（彩色）
        let progressBar = UIView()
        progressBar.backgroundColor = item.color
        progressBar.layer.cornerRadius = 6
        
        // 百分比
        let percentage = Float(item.count) / Float(item.total)
        
        view.addSubview(titleLabel)
        view.addSubview(valueLabel)
        view.addSubview(backgroundBar)
        backgroundBar.addSubview(progressBar)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
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

// MARK: - 价格统计条形图（可滚动）
class PriceBarChartView: UIScrollView {
    
    private let data: [StatisticsData.PriceStat]
    private let containerView = UIView()
    
    init(data: [StatisticsData.PriceStat]) {
        self.data = data
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        
        addSubview(containerView)
        
        var lastView: UIView?
        var totalHeight: CGFloat = 0
        
        for (index, item) in data.enumerated() {
            let barView = createBarView(for: item, index: index)
            containerView.addSubview(barView)
            
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
            totalHeight += 86
        }
        
        if let lastView = lastView {
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.width.equalToSuperview()
                make.bottom.equalTo(lastView).offset(16)
            }
            
            contentSize = CGSize(width: 0, height: totalHeight)
        }
    }
    
    private func createBarView(for item: StatisticsData.PriceStat, index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = item.range
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .black
        
        // 数值
        let valueLabel = UILabel()
        valueLabel.text = "\(item.count)件"
        valueLabel.font = .systemFont(ofSize: 12)
        valueLabel.textColor = .gray
        valueLabel.textAlignment = .right
        
        // 背景条（灰色）
        let backgroundBar = UIView()
        backgroundBar.backgroundColor = .systemGray5
        backgroundBar.layer.cornerRadius = 6
        
        // 进度条（彩色）
        let progressBar = UIView()
        progressBar.backgroundColor = item.color
        progressBar.layer.cornerRadius = 6
        
        // 百分比
        let percentage = Float(item.count) / Float(item.total)
        
        view.addSubview(titleLabel)
        view.addSubview(valueLabel)
        view.addSubview(backgroundBar)
        backgroundBar.addSubview(progressBar)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
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

// MARK: - 时间统计折线图
class TimeLineChartView: UIView {
    
    private let data: [StatisticsData.TimeStat]
    private let lineLayer = CAShapeLayer()
    private let dotLayers: [CALayer] = []
    
    init(data: [StatisticsData.TimeStat]) {
        self.data = data
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawLineChart(in: rect)
        drawAxes(in: rect)
    }
    
    private func drawAxes(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 设置轴线颜色
        context.setStrokeColor(UIColor.systemGray4.cgColor)
        context.setLineWidth(1)
        
        // 绘制Y轴
        context.move(to: CGPoint(x: 40, y: 20))
        context.addLine(to: CGPoint(x: 40, y: rect.height - 40))
        context.strokePath()
        
        // 绘制X轴
        context.move(to: CGPoint(x: 40, y: rect.height - 40))
        context.addLine(to: CGPoint(x: rect.width - 20, y: rect.height - 40))
        context.strokePath()
        
        // 绘制X轴标签
        let stepX = (rect.width - 80) / CGFloat(data.count - 1)
        for (index, item) in data.enumerated() {
            let x = 40 + CGFloat(index) * stepX
            let label = item.date as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            let size = label.size(withAttributes: attributes)
            label.draw(at: CGPoint(x: x - size.width / 2, y: rect.height - 35), withAttributes: attributes)
        }
        
        // 绘制Y轴标签和网格线
        let maxValue = data.map { $0.count }.max() ?? 1
        for i in 0...5 {
            let value = maxValue * i / 5
            let y = rect.height - 40 - CGFloat(i) * (rect.height - 80) / 5
            let label = "\(value)" as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            label.draw(at: CGPoint(x: 10, y: y - 7), withAttributes: attributes)
            
            // 绘制水平网格线
            context.setStrokeColor(UIColor.systemGray6.cgColor)
            context.setLineWidth(0.5)
            context.move(to: CGPoint(x: 40, y: y))
            context.addLine(to: CGPoint(x: rect.width - 20, y: y))
            context.strokePath()
        }
    }
    
    private func drawLineChart(in rect: CGRect) {
        guard data.count > 1 else { return }
        
        let path = UIBezierPath()
        let stepX = (rect.width - 80) / CGFloat(data.count - 1)
        let maxValue = CGFloat(data.map { $0.count }.max() ?? 1)
        let scaleY = (rect.height - 80) / maxValue
        
        // 绘制折线
        for (index, item) in data.enumerated() {
            let x = 40 + CGFloat(index) * stepX
            let y = rect.height - 40 - CGFloat(item.count) * scaleY
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        // 设置折线样式
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.systemBlue.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 2
        lineLayer.lineJoin = .round
        lineLayer.lineCap = .round
        
        // 添加动画
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        lineLayer.add(animation, forKey: "lineAnimation")
        
        layer.addSublayer(lineLayer)
        
        // 绘制数据点
        for (index, item) in data.enumerated() {
            let x = 40 + CGFloat(index) * stepX
            let y = rect.height - 40 - CGFloat(item.count) * scaleY
            
            let dotLayer = CAShapeLayer()
            dotLayer.path = UIBezierPath(ovalIn: CGRect(x: x - 4, y: y - 4, width: 8, height: 8)).cgPath
            dotLayer.fillColor = UIColor.white.cgColor
            dotLayer.strokeColor = UIColor.systemBlue.cgColor
            dotLayer.lineWidth = 2
            
            // 添加数值标签
            let valueLabel = "\(item.count)" as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.systemBlue
            ]
            UIGraphicsBeginImageContext(rect.size)
            valueLabel.draw(at: CGPoint(x: x - 8, y: y - 20), withAttributes: attributes)
            UIGraphicsEndImageContext()
            
            layer.addSublayer(dotLayer)
        }
    }
}
