//
//  CalenderView.swift
//  SweetWeather
//
//  Created by WeatherTeam on 2026/1/12.
//

import UIKit
import SnapKit

/// 日历视图 - 支持左右滑动切换月份，使用 UICollectionView 显示日期
final class CalenderView: UIView {

    // MARK: - Properties
    
    /// 当前显示的月份
    private var displayedMonth: Date = Date() {
        didSet {
            if !isScrolling {
                refreshMonthDisplay()
            }
        }
    }
    
    /// 是否正在滚动（用于避免在滑动过程中触发布局更新）
    private var isScrolling: Bool = false
    
    /// 选中的日期
    private var pickedDate: Date? = Date()
    
    /// 高度变化回调
    var onHeightChanged: ((CGFloat) -> Void)?
    
    /// 日期选中回调
    var onDateSelected: ((Date) -> Void)?
    
    /// 当前高度约束
    private var heightConstraintRef: Constraint?
    
    /// 公历日历
    private let gregorianCalendar = Calendar(identifier: .gregorian)
    
    /// 今天日期
    private let todayDate = Date()
    
    // MARK: - UI Components
    
    /// 标题栏容器
    private lazy var titleBarView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 左箭头按钮
    private lazy var prevMonthButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "cal_left_arrow"), for: .normal)
        btn.addTarget(self, action: #selector(switchToPreviousMonth), for: .touchUpInside)
        return btn
    }()
    
    /// 右箭头按钮
    private lazy var nextMonthButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "cal_right_arrow"), for: .normal)
        btn.addTarget(self, action: #selector(switchToNextMonth), for: .touchUpInside)
        return btn
    }()
    
    /// 年月标签
    private lazy var monthTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .text1Color
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var lineLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .text1Color.withAlphaComponent(0.1)
        return label
    }()
    
    /// 星期标题容器
    private lazy var weekdayHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 月份滚动视图（支持左右滑动切换月份）
    private lazy var monthScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        scrollView.isScrollEnabled = true
        scrollView.bounces = false
        return scrollView
    }()
    
    /// 月份容器视图数组（前一个月、当前月、下一个月）
    private var monthContainerViews: [UIView] = []
    
    /// 前一个月的日期集合视图
    private var previousMonthCollectionView: UICollectionView?
    
    /// 当前显示的日期集合视图
    private var currentMonthCollectionView: UICollectionView?
    
    /// 下一个月的日期集合视图
    private var nextMonthCollectionView: UICollectionView?
    
    /// 回到今天按钮
    private lazy var todayButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("回到今天", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        btn.backgroundColor = .themeBlueColor
        btn.layer.cornerRadius = 14
        btn.clipsToBounds = true
        btn.isHidden  = true
        btn.addTarget(self, action: #selector(jumpToToday), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Data Models
    
    /// 日期数据模型
    struct CalendarDayItem {
        let date: Date?
        let isCurrentMonth: Bool
        let isToday: Bool
        let isSelected: Bool
    }
    
    /// 当前月的日期数据
    private var currentMonthDays: [CalendarDayItem] = []
    
    /// 前一个月的日期数据
    private var previousMonthDays: [CalendarDayItem] = []
    
    /// 下一个月的日期数据
    private var nextMonthDays: [CalendarDayItem] = []
    
    // MARK: - Constants
    
    /// 星期标题高度
    private let weekdayHeaderHeight: CGFloat = 32
    
    /// 每行日期高度
    private let dayRowHeight: CGFloat = 48
    
    /// 标题栏高度
    private let titleBarHeight: CGFloat = 50
    
    /// 底部按钮高度
    private let todayButtonHeight: CGFloat = 28
    
    /// 底部按钮顶部间距
    private let todayButtonTopSpacing: CGFloat = 16
    
    /// 左右内边距
    private let horizontalPadding: CGFloat = 5
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        generateMonthData()
        updateMonthTitle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        generateMonthData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 确保在首次布局完成后更新月份数据
        if currentMonthDays.isEmpty && monthScrollView.bounds.width > 0 {
            generateMonthData()
        }
        
        // 更新 ScrollView 布局
        if monthScrollView.bounds.width > 0 {
            updateScrollViewLayout()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .lightBlueColor
        self.layer.cornerRadius = 16
        
        addSubview(titleBarView)
        titleBarView.addSubview(prevMonthButton)
        titleBarView.addSubview(nextMonthButton)
        titleBarView.addSubview(monthTitleLabel)
        titleBarView.addSubview(todayButton)
        addSubview(weekdayHeaderView)
        addSubview(lineLabel)
        setupWeekdayHeaders()
        addSubview(monthScrollView)
        setupConstraints()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.refreshMonthDisplay()
            self?.selectedDateAction(Date())
        }
    }
    
    private func setupConstraints() {
        // 标题栏
        titleBarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(titleBarHeight)
        }
        
        prevMonthButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.height.equalTo(22)
            make.centerY.equalTo(titleBarView)
        }
        
        monthTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(prevMonthButton)
            make.width.equalTo(135)
            make.leading.equalTo(prevMonthButton.snp.trailing).offset(20)
        }
        
        nextMonthButton.snp.makeConstraints { make in
            make.centerY.equalTo(prevMonthButton)
            make.leading.equalTo(monthTitleLabel.snp.trailing).offset(20)
            make.width.height.equalTo(22)
        }
        
        // 回到今天按钮
        todayButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(2)
            make.width.equalTo(70)
            make.height.equalTo(todayButtonHeight)
            make.centerY.equalTo(prevMonthButton)
        }
        
        lineLabel.snp.makeConstraints { make in
            make.top.equalTo(titleBarView.snp.bottom).offset(-5)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }

        // 星期标题
        weekdayHeaderView.snp.makeConstraints { make in
            make.top.equalTo(titleBarView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
            make.height.equalTo(weekdayHeaderHeight)
        }
        
        // 月份滚动视图
        monthScrollView.snp.makeConstraints { make in
            make.top.equalTo(weekdayHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
            make.bottom.equalToSuperview().inset(5)
        }
        // 高度约束（动态更新）
        self.snp.makeConstraints { make in
            heightConstraintRef = make.height.greaterThanOrEqualTo(370).constraint
        }
    }
    
    /// 设置星期标题
    private func setupWeekdayHeaders() {
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        let dayWidth = (UIScreen.main.bounds.width - 32 - horizontalPadding * 2) / 7
        
        for (index, day) in weekdays.enumerated() {
            let label = UILabel()
            label.text = day
            label.textColor = .text2Color
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .center
            weekdayHeaderView.addSubview(label)
            
            label.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(CGFloat(index) * dayWidth)
                make.centerY.equalToSuperview()
                make.width.equalTo(dayWidth)
            }
        }
    }
    
    /// 创建日期集合视图
    private func createDayCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
        collectionView.clipsToBounds = true
        return collectionView
    }
    
    // MARK: - Update Month
    
    /// 刷新月份显示
    private func refreshMonthDisplay() {
        updateMonthTitle()
        generateMonthData()
        updateTodayButtonVisibility()
        
        // 更新高度
        if monthScrollView.bounds.width > 0 {
            updateScrollViewHeight()
        }
        
        // 确保集合视图已创建后再重新加载
        if !monthContainerViews.isEmpty {
            reloadAllCollectionViews()
        }
    }
    
    /// 生成所有月份的数据
    private func generateMonthData() {
        // 生成当前月
        currentMonthDays = generateDaysForMonth(displayedMonth)
        
        // 生成前一个月
        if let prevMonth = gregorianCalendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            previousMonthDays = generateDaysForMonth(prevMonth)
        } else {
            previousMonthDays = []
        }
        
        // 生成下一个月
        if let nextMonth = gregorianCalendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            nextMonthDays = generateDaysForMonth(nextMonth)
        } else {
            nextMonthDays = []
        }
    }
    
    /// 生成指定月份的日期数据
    private func generateDaysForMonth(_ month: Date) -> [CalendarDayItem] {
        var result: [CalendarDayItem] = []
        
        // 获取月份的第一天和最后一天
        guard let monthStart = gregorianCalendar.date(from: gregorianCalendar.dateComponents([.year, .month], from: month)),
              let monthEnd = gregorianCalendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return result
        }
        
        // 获取第一天是星期几（1=周日，2=周一...，转换为 0-6 索引）
        let firstWeekday = gregorianCalendar.component(.weekday, from: monthStart) - 1
        
        // 判断是否显示当前月份
        let isCurrentMonth = gregorianCalendar.isDate(month, equalTo: displayedMonth, toGranularity: .month)
        
        // 添加空白日期（月初之前的日期）
        for _ in 0..<firstWeekday {
            result.append(CalendarDayItem(date: nil, isCurrentMonth: false, isToday: false, isSelected: false))
        }
        
        // 添加月份中的所有日期
        var currentDate = monthStart
        while currentDate <= monthEnd {
            let isToday = gregorianCalendar.isDateInToday(currentDate)
            // 判断是否选中：必须年月日完全相同
            let isSelected = gregorianCalendar.isDate(currentDate, equalTo: pickedDate ?? Date(), toGranularity: .day)
            result.append(CalendarDayItem(date: currentDate, isCurrentMonth: isCurrentMonth, isToday: isToday, isSelected: isSelected))
            currentDate = gregorianCalendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // 补齐到完整的行数（至少5行，最多6行）
        let daysInMonth = gregorianCalendar.component(.day, from: monthEnd)
        let totalCells = firstWeekday + daysInMonth
        let rows = (totalCells + 6) / 7 // 向上取整
        let finalRows = max(5, min(6, rows)) // 至少5行，最多6行
        let totalCellsNeeded = finalRows * 7
        
        while result.count < totalCellsNeeded {
            result.append(CalendarDayItem(date: nil, isCurrentMonth: false, isToday: false, isSelected: false))
        }
        
        return result
    }
    
    /// 更新月份标题
    private func updateMonthTitle() {
        monthTitleLabel.text = formatDateToString(displayedMonth, format: "yyyy年M月")
    }
    
    /// 日期格式化辅助方法
    private func formatDateToString(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    /// 更新回到今天按钮的显示状态
    private func updateTodayButtonVisibility() {
        let isCurrentMonth = gregorianCalendar.isDate(displayedMonth, equalTo: todayDate, toGranularity: .month)
        todayButton.isHidden = isCurrentMonth
    }
    
    /// 更新滚动视图布局
    private func updateScrollViewLayout() {
        guard monthScrollView.superview != nil else {
            return
        }
        
        // 如果 bounds 为 0，等待下次布局
        guard monthScrollView.bounds.width > 0 else {
            return
        }
        
        let scrollViewWidth = monthScrollView.bounds.width
        
        // 计算实际需要的高度（根据当前月份的行数）
        let rows = calculateRowsForMonth(displayedMonth)
        let cellWidth = scrollViewWidth / 7
        let cellHeight = cellWidth
        let scrollViewHeight = cellHeight * CGFloat(rows)
        
        monthScrollView.contentSize = CGSize(width: scrollViewWidth * 3, height: scrollViewHeight)
        
        // 如果还没有创建月份视图，则创建
        if monthContainerViews.isEmpty {
            // 创建三个月份的集合视图
            previousMonthCollectionView = createDayCollectionView()
            currentMonthCollectionView = createDayCollectionView()
            nextMonthCollectionView = createDayCollectionView()
            
            // 创建容器视图
            let prevContainer = UIView()
            let currentContainer = UIView()
            let nextContainer = UIView()
            
            prevContainer.backgroundColor = .clear
            currentContainer.backgroundColor = .clear
            nextContainer.backgroundColor = .clear
            
            if let prevCollectionView = previousMonthCollectionView {
                prevContainer.addSubview(prevCollectionView)
            }
            if let currentCollectionView = currentMonthCollectionView {
                currentContainer.addSubview(currentCollectionView)
            }
            if let nextCollectionView = nextMonthCollectionView {
                nextContainer.addSubview(nextCollectionView)
            }
            
            monthContainerViews = [prevContainer, currentContainer, nextContainer]
            
            // 添加到滚动视图
            for monthView in monthContainerViews {
                monthScrollView.addSubview(monthView)
            }
            
            // 首次创建后，立即设置 frame 并加载数据
            for (index, monthView) in monthContainerViews.enumerated() {
                let frame = CGRect(x: CGFloat(index) * scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight)
                monthView.frame = frame
                
                let collectionView = index == 0 ? previousMonthCollectionView : (index == 1 ? currentMonthCollectionView : nextMonthCollectionView)
                if let collectionView = collectionView {
                    collectionView.frame = CGRect(origin: .zero, size: frame.size)
                }
            }
            
            // 在下一个 runloop 中加载数据，确保 frame 已应用
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.reloadAllCollectionViews()
            }
        } else {
            // 更新所有月份视图的frame
            for (index, monthView) in monthContainerViews.enumerated() {
                let frame = CGRect(x: CGFloat(index) * scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight)
                monthView.frame = frame
                
                let collectionView = index == 0 ? previousMonthCollectionView : (index == 1 ? currentMonthCollectionView : nextMonthCollectionView)
                if let collectionView = collectionView {
                    collectionView.frame = CGRect(origin: .zero, size: frame.size)
                }
            }
        }
        
        // 确保滚动到正确位置（仅在首次布局时，且当前不在正确位置，且不在滚动过程中）
        if !isScrolling {
            let centerOffset = scrollViewWidth
            if abs(monthScrollView.contentOffset.x - centerOffset) > 1 {
                monthScrollView.contentOffset = CGPoint(x: centerOffset, y: 0)
            }
        }
    }
    
    /// 更新 ScrollView 高度（根据实际行数）
    private func updateScrollViewHeight() {
        guard monthScrollView.bounds.width > 0 else { return }
        
        let rows = calculateRowsForMonth(displayedMonth)
        let scrollViewWidth = monthScrollView.bounds.width
        let cellWidth = scrollViewWidth / 7
        let cellHeight = cellWidth
        let scrollViewHeight = cellHeight * CGFloat(rows)
        
        // 更新所有月份视图的高度
        for (index, monthView) in monthContainerViews.enumerated() {
            let frame = CGRect(x: CGFloat(index) * scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight)
            monthView.frame = frame
            
            let collectionView = index == 0 ? previousMonthCollectionView : (index == 1 ? currentMonthCollectionView : nextMonthCollectionView)
            if let collectionView = collectionView {
                collectionView.frame = CGRect(origin: .zero, size: frame.size)
            }
        }
        
        monthScrollView.contentSize = CGSize(width: scrollViewWidth * 3, height: scrollViewHeight)
        
        // 计算总高度
        let totalHeight = titleBarHeight + 8 + weekdayHeaderHeight + scrollViewHeight + todayButtonTopSpacing + 16
        
        // 更新高度约束
        heightConstraintRef?.update(offset: totalHeight)
        
        // 通知高度变化
        onHeightChanged?(totalHeight)
    }
    
    /// 根据月份计算实际需要的行数
    private func calculateRowsForMonth(_ month: Date) -> Int {
        // 获取月份的第一天和最后一天
        guard let monthStart = gregorianCalendar.date(from: gregorianCalendar.dateComponents([.year, .month], from: month)),
              let monthEnd = gregorianCalendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return 5
        }
        
        // 获取第一天是星期几（1=周日，2=周一...，转换为 0-6 索引）
        let firstWeekday = gregorianCalendar.component(.weekday, from: monthStart) - 1
        
        // 获取月份的天数
        let daysInMonth = gregorianCalendar.component(.day, from: monthEnd)
        
        // 计算需要的行数
        let totalCells = firstWeekday + daysInMonth
        let rows = (totalCells + 6) / 7 // 向上取整
        // 至少5行，最多6行
        return max(5, min(6, rows))
    }
    
    /// 重新加载所有集合视图
    private func reloadAllCollectionViews() {
        // 确保数据已生成
        if currentMonthDays.isEmpty {
            generateMonthData()
        }
        
        // 重新加载数据
        previousMonthCollectionView?.reloadData()
        currentMonthCollectionView?.reloadData()
        nextMonthCollectionView?.reloadData()
        
        // 强制刷新布局
        previousMonthCollectionView?.collectionViewLayout.invalidateLayout()
        currentMonthCollectionView?.collectionViewLayout.invalidateLayout()
        nextMonthCollectionView?.collectionViewLayout.invalidateLayout()
        
        // 强制布局
        previousMonthCollectionView?.setNeedsLayout()
        currentMonthCollectionView?.setNeedsLayout()
        nextMonthCollectionView?.setNeedsLayout()
        
        previousMonthCollectionView?.layoutIfNeeded()
        currentMonthCollectionView?.layoutIfNeeded()
        nextMonthCollectionView?.layoutIfNeeded()
    }
    
    // MARK: - Actions
    
    @objc private func switchToPreviousMonth() {
        // 触感反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if let prevMonth = gregorianCalendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = prevMonth
            // 滚动到中间位置（当前月）
            let scrollViewWidth = monthScrollView.bounds.width
            monthScrollView.setContentOffset(CGPoint(x: scrollViewWidth, y: 0), animated: true)
        }
    }
    
    @objc private func switchToNextMonth() {
        // 触感反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if let nextMonth = gregorianCalendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = nextMonth
            // 滚动到中间位置（当前月）
            let scrollViewWidth = monthScrollView.bounds.width
            monthScrollView.setContentOffset(CGPoint(x: scrollViewWidth, y: 0), animated: true)
        }
    }
    
    @objc private func jumpToToday() {
        // 触感反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        displayedMonth = todayDate
        pickedDate     = todayDate
        selectedDateAction(todayDate)
        // 滚动到中间位置（当前月）
        let scrollViewWidth = monthScrollView.bounds.width
        monthScrollView.setContentOffset(CGPoint(x: scrollViewWidth, y: 0), animated: false)
    }
    
    /// 处理滚动结束
    private func handleScrollViewDidEndScrolling() {
        let scrollViewWidth = monthScrollView.bounds.width
        guard scrollViewWidth > 0 else { return }
        
        let offsetX = monthScrollView.contentOffset.x
        let centerOffset = scrollViewWidth
        var shouldUpdateMonth = false
        var newMonth: Date?
        
        // 判断滑动方向
        if offsetX < scrollViewWidth * 0.5 {
            // 滑动到前一个月（向左滑动超过阈值）
            newMonth = gregorianCalendar.date(byAdding: .month, value: -1, to: displayedMonth)
            shouldUpdateMonth = true
        } else if offsetX > scrollViewWidth * 1.5 {
            // 滑动到下一个月（向右滑动超过阈值）
            newMonth = gregorianCalendar.date(byAdding: .month, value: 1, to: displayedMonth)
            shouldUpdateMonth = true
        } else {
            // 滑动距离不够，回到中间位置（使用动画，更平滑）
            monthScrollView.setContentOffset(CGPoint(x: centerOffset, y: 0), animated: true)
        }
        
        // 如果需要更新月份，先设置滚动位置，再更新月份数据
        if shouldUpdateMonth, let newMonth = newMonth {
            // 标记正在滚动，避免 didSet 触发布局更新
            isScrolling = true
            
            // 先重置滚动位置
            monthScrollView.setContentOffset(CGPoint(x: centerOffset, y: 0), animated: false)
            
            // 更新月份
            displayedMonth = newMonth
            
            // 手动刷新显示（因为 didSet 被 isScrolling 阻止了）
            refreshMonthDisplay()
            
            // 重置滚动标志
            DispatchQueue.main.async { [weak self] in
                self?.isScrolling = false
            }
        }
    }
    
    private func selectedDateAction(_ date: Date) {
        // 触发回调
        onDateSelected?(date)
    }
}

// MARK: - UIScrollViewDelegate

extension CalenderView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollViewDidEndScrolling()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // 不需要处理
    }
}

// MARK: - UICollectionViewDataSource

extension CalenderView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 确保数据已生成
        if currentMonthDays.isEmpty {
            generateMonthData()
        }
        
        // 根据不同的集合视图返回对应的数据
        if collectionView == previousMonthCollectionView {
            return previousMonthDays.count
        } else if collectionView == nextMonthCollectionView {
            return nextMonthDays.count
        } else if collectionView == currentMonthCollectionView {
            return currentMonthDays.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
        
        // 先重置 cell，避免复用问题
        cell.resetCell()
        
        // 根据不同的集合视图获取对应的数据
        let item: CalendarDayItem
        if collectionView == previousMonthCollectionView {
            guard indexPath.item < previousMonthDays.count else {
                return cell
            }
            item = previousMonthDays[indexPath.item]
        } else if collectionView == nextMonthCollectionView {
            guard indexPath.item < nextMonthDays.count else {
                return cell
            }
            item = nextMonthDays[indexPath.item]
        } else if collectionView == currentMonthCollectionView {
            guard indexPath.item < currentMonthDays.count else {
                return cell
            }
            item = currentMonthDays[indexPath.item]
        } else {
            return cell
        }
        
        if let date = item.date {
            cell.configure(
                with: date,
                isCurrentMonth: item.isCurrentMonth,
                isToday: item.isToday,
                isSelected: item.isSelected
            )
        } else {
            cell.resetCell()
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CalenderView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 根据不同的集合视图获取对应的数据
        let item: CalendarDayItem
        if collectionView == previousMonthCollectionView {
            item = previousMonthDays[indexPath.item]
        } else if collectionView == nextMonthCollectionView {
            item = nextMonthDays[indexPath.item]
        } else if collectionView == currentMonthCollectionView {
            item = currentMonthDays[indexPath.item]
        } else {
            return
        }
        
        guard let date = item.date else { return }
        if pickedDate == date {
            return
        }
        pickedDate = date
        selectedDateAction(date)
        refreshMonthDisplay()
        
        // 触感反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CalenderView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 优先使用集合视图的 bounds 宽度
        var width = collectionView.bounds.width / 7
        
        // 如果宽度为 0，尝试从父视图获取
        if width <= 0 {
            if let superview = collectionView.superview, superview.bounds.width > 0 {
                width = superview.bounds.width / 7
            } else {
                // 使用 ScrollView 的宽度
                let scrollViewWidth = monthScrollView.bounds.width
                if scrollViewWidth > 0 {
                    width = scrollViewWidth / 7
                } else {
                    // 最后的备用值
                    width = (UIScreen.main.bounds.width - 32 - horizontalPadding * 2) / 7
                }
            }
        }
        
        let cellHeight = width
        // 确保返回有效的尺寸
        let finalWidth = max(width, 30)
        let finalHeight = max(cellHeight, 30)
        
        return CGSize(width: finalWidth, height: finalHeight)
    }
}

// MARK: - CalendarDayCell

/// 日期单元格
private class CalendarDayCell: UICollectionViewCell {
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        return stackView
    }()
    
    private lazy var styleBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(styleBackgroundView)
        contentView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(dayLabel)
        
        styleBackgroundView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.trailing.equalToSuperview().inset(2)
        }
        
        containerStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(1)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        contentView.clipsToBounds = true
    }
    
    func resetCell() {
        dayLabel.text = ""
        contentView.backgroundColor = .clear
        styleBackgroundView.backgroundColor = .clear
    }
    
    func configure(with date: Date, isCurrentMonth: Bool, isToday: Bool, isSelected: Bool) {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        dayLabel.text = "\(day)"
        
        // 设置文字颜色
        if !isCurrentMonth {
            // 非本月日期显示灰色
            dayLabel.textColor = .text1Color
        } else {
            dayLabel.textColor = .text1Color
        }
        
        // 设置背景
        if isToday {
            dayLabel.textColor = .text1Color
            styleBackgroundView.backgroundColor = UIColor(red: 51/255.0, green: 171/255.0, blue: 250/255.0, alpha: 1.0)
        } else if isSelected {
            if isCurrentMonth {
                styleBackgroundView.backgroundColor = UIColor(red: 51/255.0, green: 171/255.0, blue: 250/255.0, alpha: 0.3)
            } else {
                styleBackgroundView.backgroundColor = .clear
            }
        } else {
            styleBackgroundView.backgroundColor = .clear
        }
    }
}
