
// MARK: - LocationCell
class LocationCell: UITableViewCell {
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    private let selectionIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 2
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        // 先添加所有子视图
        contentView.addSubview(selectionIndicator)
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(itemCountLabel)
        contentView.addSubview(textStack)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.addArrangedSubview(editButton)
        buttonStack.addArrangedSubview(deleteButton)
        contentView.addSubview(buttonStack)
        
        // 设置约束
        selectionIndicator.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(4)
        }
        
        textStack.snp.makeConstraints { make in
            make.left.equalTo(selectionIndicator.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(buttonStack.snp.left).offset(-12)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(36)
        }
    }
    
    func configure(with location: PrimaryLocationModel, isSelected: Bool) {
        nameLabel.text = location.name
        itemCountLabel.text = "\(ItemRepository.shared.getItems(byPrimaryLocationId: location.id).count) 个物品"
        
        let color = UIColor(hex: location.color)
        selectionIndicator.backgroundColor = color
        
        
        selectionIndicator.isHidden = !isSelected
    }
    
    func configure(with location: SecondaryLocationModel) {
        nameLabel.text = location.name
        itemCountLabel.text = "\(ItemRepository.shared.getItems(bySecondaryLocationId: location.id).count) 个物品"
    }
    
    private func getIconName(from icon: String) -> String? {
        // 如果是 emoji，返回默认图标
        if icon.containsEmoji() {
            return "location.fill"
        }
        return icon
    }
}

// MARK: - String Extension
extension String {
    func containsEmoji() -> Bool {
        for scalar in unicodeScalars {
            if scalar.properties.isEmoji {
                return true
            }
        }
        return false
    }
}
//

//
//  LocationManagementViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/18.
//

import UIKit
import SnapKit

class LocationManagementViewController: UIViewController {
    
    // MARK: - Properties
    private var primaryLocations: [PrimaryLocationModel] = []
    private var secondaryLocations: [SecondaryLocationModel] = []
    private var selectedPrimaryLocationId: String?
    
    // MARK: - UI Elements
    private lazy var splitContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        return view
    }()
    
    // 左侧：一级位置列表
    private lazy var leftContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var leftTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "一级位置"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var leftTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemBackground
        tv.delegate = self
        tv.dataSource = self
        tv.register(LocationCell.self, forCellReuseIdentifier: "PrimaryLocationCell")
        tv.separatorStyle = .singleLine
        return tv
    }()
    
    private lazy var addPrimaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("添加一级位置", for: .normal)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(addPrimaryLocationTapped), for: .touchUpInside)
        return button
    }()
    
    // 右侧：二级位置列表
    private lazy var rightContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var rightTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "二级位置"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var rightTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemBackground
        tv.delegate = self
        tv.dataSource = self
        tv.register(LocationCell.self, forCellReuseIdentifier: "SecondaryLocationCell")
        tv.separatorStyle = .singleLine
        return tv
    }()
    
    private lazy var addSecondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("添加二级位置", for: .normal)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(addSecondaryLocationTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "请先选择一级位置"
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "位置管理"
        
        // 添加分割视图
        view.addSubview(splitContainer)
        splitContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 左侧容器
        splitContainer.addSubview(leftContainer)
        leftContainer.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        // 右侧容器
        splitContainer.addSubview(rightContainer)
        rightContainer.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        // 添加分割线
        let dividerLine = UIView()
        dividerLine.backgroundColor = UIColor.separator
        splitContainer.addSubview(dividerLine)
        dividerLine.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(0.5)
        }
        
        setupLeftView()
        setupRightView()
    }
    
    private func setupLeftView() {
        // 添加标题
        leftContainer.addSubview(leftTitleLabel)
        leftTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(leftContainer.safeAreaLayoutGuide.snp.top).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 添加按钮
        leftContainer.addSubview(addPrimaryButton)
        addPrimaryButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(leftContainer.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.height.equalTo(44)
        }
        
        // 添加表格视图，约束在标题和按钮之间
        leftContainer.addSubview(leftTableView)
        leftTableView.snp.makeConstraints { make in
            make.top.equalTo(leftTitleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(addPrimaryButton.snp.top).offset(-12)
        }
    }
    
    private func setupRightView() {
        // 添加标题
        rightContainer.addSubview(rightTitleLabel)
        rightTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(rightContainer.safeAreaLayoutGuide.snp.top).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 添加按钮
        rightContainer.addSubview(addSecondaryButton)
        addSecondaryButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(rightContainer.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.height.equalTo(44)
        }
        
        // 添加表格视图，约束在标题和按钮之间
        rightContainer.addSubview(rightTableView)
        rightTableView.snp.makeConstraints { make in
            make.top.equalTo(rightTitleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(addSecondaryButton.snp.top).offset(-12)
        }
        
        // 添加空状态标签
        rightContainer.addSubview(emptyStateLabel)
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalTo(rightTableView)
        }
    }
    
    // MARK: - Data Loading
    private func loadData() {
        // 从 Repository 加载数据
        primaryLocations = ItemRepository.shared.getPrimaryLocations()
        leftTableView.reloadData()
        
        // 默认选中第一个一级位置
        if let first = primaryLocations.first {
            selectedPrimaryLocationId = first.id
            loadSecondaryLocations()
        } else {
            selectedPrimaryLocationId = nil
            secondaryLocations = []
            rightTableView.reloadData()
            updateEmptyState()
        }
    }
    
    private func loadSecondaryLocations() {
        guard let primaryId = selectedPrimaryLocationId else {
            secondaryLocations = []
            rightTableView.reloadData()
            updateEmptyState()
            return
        }
        
        secondaryLocations = ItemRepository.shared.getSecondaryLocations(for: primaryId)
        rightTableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = selectedPrimaryLocationId != nil && !secondaryLocations.isEmpty
        rightTableView.isHidden = selectedPrimaryLocationId == nil && secondaryLocations.isEmpty
    }
    
    // MARK: - Actions
    @objc private func addPrimaryLocationTapped() {
        let alert = UIAlertController(title: "添加一级位置", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "位置名称（如：冰箱、衣柜）"
        }
        
        let addAction = UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            
            let newLocation = PrimaryLocationModel()
            newLocation.id = UUID().uuidString
            newLocation.name = name
            newLocation.icon = "📍"
            newLocation.color = "#2196F3"
            newLocation.sortOrder = self?.primaryLocations.count ?? 0
            
            ItemRepository.shared.addPrimaryLocation(newLocation)
            
            self?.primaryLocations = ItemRepository.shared.getPrimaryLocations()
            self?.leftTableView.reloadData()
            
            // 如果这是第一个位置，自动选中
            if self?.selectedPrimaryLocationId == nil {
                self?.selectedPrimaryLocationId = newLocation.id
                self?.loadSecondaryLocations()
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func addSecondaryLocationTapped() {
        guard let primaryId = selectedPrimaryLocationId,
              let primaryLocation = primaryLocations.first(where: { $0.id == primaryId }) else {
            showAlert(message: "请先选择一级位置")
            return
        }
        
        let alert = UIAlertController(title: "添加二级位置", message: "位置：\(primaryLocation.name)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "位置名称（如：冷藏层、挂衣区）"
        }
        
        let addAction = UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            
            let newLocation = SecondaryLocationModel()
            newLocation.id = UUID().uuidString
            newLocation.name = name
            newLocation.primaryLocationId = primaryId
            newLocation.icon = "📦"
            newLocation.color = "#4CAF50"
            newLocation.sortOrder = self?.secondaryLocations.count ?? 0
            
            ItemRepository.shared.addSecondaryLocation(newLocation)
            
            self?.loadSecondaryLocations()
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func editPrimaryLocation(_ sender: UIButton) {
        let index = sender.tag
        guard index < primaryLocations.count else { return }
        let location = primaryLocations[index]
        
        let alert = UIAlertController(title: "编辑一级位置", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = location.name
            textField.placeholder = "位置名称"
        }
        
        let saveAction = UIAlertAction(title: "保存", style: .default) { [weak self] _ in
            guard let newName = alert.textFields?.first?.text, !newName.isEmpty else { return }
            
            location.name = newName
            ItemRepository.shared.updatePrimaryLocation(location)
            
            self?.primaryLocations = ItemRepository.shared.getPrimaryLocations()
            self?.leftTableView.reloadData()
            
            // 如果编辑的是当前选中的位置，刷新右侧
            if self?.selectedPrimaryLocationId == location.id {
                self?.loadSecondaryLocations()
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func editSecondaryLocation(_ sender: UIButton) {
        let index = sender.tag
        guard index < secondaryLocations.count else { return }
        let location = secondaryLocations[index]
        
        let alert = UIAlertController(title: "编辑二级位置", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = location.name
            textField.placeholder = "位置名称"
        }
        
        let saveAction = UIAlertAction(title: "保存", style: .default) { [weak self] _ in
            guard let newName = alert.textFields?.first?.text, !newName.isEmpty else { return }
            
            location.name = newName
            ItemRepository.shared.updateSecondaryLocation(location)
            
            self?.loadSecondaryLocations()
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func deletePrimaryLocation(_ sender: UIButton) {
        let index = sender.tag
        guard index < primaryLocations.count else { return }
        let location = primaryLocations[index]
        
        // 检查是否有物品使用这个位置
        let itemsInLocation = ItemRepository.shared.getItems(byPrimaryLocationId: location.id)
        if !itemsInLocation.isEmpty {
            showAlert(message: "无法删除，有 \(itemsInLocation.count) 个物品使用此位置")
            return
        }
        
        let alert = UIAlertController(
            title: "删除一级位置",
            message: "确定要删除位置“\(location.name)”吗？\n该位置下的所有二级位置也将被删除。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            ItemRepository.shared.deletePrimaryLocation(id: location.id)
            
            self?.primaryLocations = ItemRepository.shared.getPrimaryLocations()
            self?.leftTableView.reloadData()
            
            // 如果删除的是当前选中的位置，清除选中状态
            if self?.selectedPrimaryLocationId == location.id {
                self?.selectedPrimaryLocationId = self?.primaryLocations.first?.id
                self?.loadSecondaryLocations()
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func deleteSecondaryLocation(_ sender: UIButton) {
        let index = sender.tag
        guard index < secondaryLocations.count else { return }
        let location = secondaryLocations[index]
        
        // 检查是否有物品使用这个位置
        let itemsInLocation = ItemRepository.shared.getItems(bySecondaryLocationId: location.id)
        if !itemsInLocation.isEmpty {
            showAlert(message: "无法删除，有 \(itemsInLocation.count) 个物品使用此位置")
            return
        }
        
        let alert = UIAlertController(
            title: "删除二级位置",
            message: "确定要删除位置“\(location.name)”吗？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            ItemRepository.shared.deleteSecondaryLocation(id: location.id)
            self?.loadSecondaryLocations()
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension LocationManagementViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == leftTableView {
            return primaryLocations.count
        } else {
            return secondaryLocations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == leftTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrimaryLocationCell", for: indexPath) as! LocationCell
            let location = primaryLocations[indexPath.row]
            cell.configure(with: location, isSelected: location.id == selectedPrimaryLocationId)
            
            // 设置编辑和删除按钮
            cell.editButton.tag = indexPath.row
            cell.editButton.addTarget(self, action: #selector(editPrimaryLocation(_:)), for: .touchUpInside)
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(deletePrimaryLocation(_:)), for: .touchUpInside)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SecondaryLocationCell", for: indexPath) as! LocationCell
            let location = secondaryLocations[indexPath.row]
            cell.configure(with: location)
            
            // 设置编辑和删除按钮
            cell.editButton.tag = indexPath.row
            cell.editButton.addTarget(self, action: #selector(editSecondaryLocation(_:)), for: .touchUpInside)
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(deleteSecondaryLocation(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == leftTableView {
            let location = primaryLocations[indexPath.row]
            selectedPrimaryLocationId = location.id
            leftTableView.reloadData()
            loadSecondaryLocations()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
