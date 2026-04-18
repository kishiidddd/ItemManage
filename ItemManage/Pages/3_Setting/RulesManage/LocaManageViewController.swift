//
//  LocationManagementViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/18.
//

import UIKit
import SnapKit
import Combine

class LocationManagementViewController: UIViewController {

    private let viewModel = LocationManagementViewModel()
    private var cancellables = Set<AnyCancellable>()

    private lazy var splitContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGrayBgColor
        return view
    }()

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

    // 底部大按钮已移除，改为标题右侧的 icon 按钮

    private lazy var addPrimaryIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "loca_icon_add")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = .clear
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.addTarget(self, action: #selector(addPrimaryLocationTapped), for: .touchUpInside)
        return button
    }()

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

    // 底部大按钮已移除，改为标题右侧的 icon 按钮

    private lazy var addSecondaryIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "loca_icon_add")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = .clear
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.load()
    }

    private func setupUI() {
        view.backgroundColor = .lightGrayBgColor
        title = "位置管理"

        view.addSubview(splitContainer)
        splitContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        splitContainer.addSubview(leftContainer)
        leftContainer.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
        }

        splitContainer.addSubview(rightContainer)
        rightContainer.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
        }

        let dividerLine = UIView()
        dividerLine.backgroundColor = UIColor.separator
        splitContainer.addSubview(dividerLine)
        dividerLine.snp.makeConstraints { make in
            make.left.equalTo(leftContainer.snp.right)
            make.top.equalTo(leftContainer.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
            make.width.equalTo(0.5)
        }

        setupLeftView()
        setupRightView()
    }

    private func setupLeftView() {
        let leftHeaderRow = UIStackView(arrangedSubviews: [leftTitleLabel, UIView(), addPrimaryIconButton])
        leftHeaderRow.axis = .horizontal
        leftHeaderRow.alignment = .center
        leftHeaderRow.spacing = 8
        leftContainer.addSubview(leftHeaderRow)
        leftHeaderRow.snp.makeConstraints { make in
            make.top.equalTo(leftContainer.safeAreaLayoutGuide.snp.top).offset(12)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview()
        }
        addPrimaryIconButton.snp.makeConstraints { make in
            make.width.height.equalTo(42)
        }

        leftContainer.addSubview(leftTableView)
        leftTableView.snp.makeConstraints { make in
            make.top.equalTo(leftHeaderRow.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(leftContainer.safeAreaLayoutGuide.snp.bottom).offset(-12)
        }
    }

    private func setupRightView() {
        let rightHeaderRow = UIStackView(arrangedSubviews: [rightTitleLabel, UIView(), addSecondaryIconButton])
        rightHeaderRow.axis = .horizontal
        rightHeaderRow.alignment = .center
        rightHeaderRow.spacing = 8
        rightContainer.addSubview(rightHeaderRow)
        rightHeaderRow.snp.makeConstraints { make in
            make.top.equalTo(rightContainer.safeAreaLayoutGuide.snp.top).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }
        addSecondaryIconButton.snp.makeConstraints { make in
            make.width.height.equalTo(42)
        }

        rightContainer.addSubview(rightTableView)
        rightTableView.snp.makeConstraints { make in
            make.top.equalTo(rightHeaderRow.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(rightContainer.safeAreaLayoutGuide.snp.bottom).offset(-12)
        }

        rightContainer.addSubview(emptyStateLabel)
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalTo(rightTableView)
        }
    }

    private func bindViewModel() {
        Publishers.CombineLatest3(
            viewModel.$primaryLocations,
            viewModel.$secondaryLocations,
            viewModel.$selectedPrimaryLocationId
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _, _, _ in
            guard let self = self else { return }
            self.leftTableView.reloadData()
            self.rightTableView.reloadData()
            self.updateEmptyState()
        }
        .store(in: &cancellables)

        viewModel.$infoMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self, let message = message, !message.isEmpty else { return }
                self.showAlert(message: message)
                self.viewModel.clearInfoMessage()
            }
            .store(in: &cancellables)
    }

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !viewModel.shouldShowEmptyLabel
        rightTableView.isHidden = viewModel.shouldHideRightTable
    }

    @objc private func addPrimaryLocationTapped() {
        showCustomTextFieldAlert(
            title: "添加一级位置",
            placeholder: "请输入位置名称",
            cancelTitle: "取消",
            confirmTitle: "添加"
        ) { [weak self] name in
            self?.viewModel.addPrimaryLocation(name: name)
        }
    }

    @objc private func addSecondaryLocationTapped() {
        guard let primaryId = viewModel.selectedPrimaryLocationId,
              let primaryLocation = viewModel.primaryLocations.first(where: { $0.id == primaryId }) else {
            showAlert(message: "请先选择一级位置")
            return
        }

        showCustomTextFieldAlert(
            title: "添加二级位置",
            // subtitle: "位置：\(primaryLocation.name)",
            placeholder: "请输入位置名称",
            cancelTitle: "取消",
            confirmTitle: "添加"
        ) { [weak self] name in
            self?.viewModel.addSecondaryLocation(name: name)
        }
    }

    @objc private func editPrimaryLocation(_ sender: UIButton) {
        let index = sender.tag
        guard index < viewModel.primaryLocations.count else { return }
        let location = viewModel.primaryLocations[index]

        showCustomTextFieldAlert(
            title: "编辑一级位置",
            placeholder: "位置名称",
            initialText: location.name,
            cancelTitle: "取消",
            confirmTitle: "保存"
        ) { [weak self] newName in
            self?.viewModel.editPrimaryLocation(at: index, name: newName)
        }
    }

    @objc private func editSecondaryLocation(_ sender: UIButton) {
        let index = sender.tag
        guard index < viewModel.secondaryLocations.count else { return }
        let location = viewModel.secondaryLocations[index]

        showCustomTextFieldAlert(
            title: "编辑二级位置",
            placeholder: "位置名称",
            initialText: location.name,
            cancelTitle: "取消",
            confirmTitle: "保存"
        ) { [weak self] newName in
            self?.viewModel.editSecondaryLocation(at: index, name: newName)
        }
    }

    @objc private func deletePrimaryLocation(_ sender: UIButton) {
        let index = sender.tag
        guard index < viewModel.primaryLocations.count else { return }
        let location = viewModel.primaryLocations[index]

        if let reason = viewModel.deletePrimaryBlockedReason(at: index) {
            showAlert(message: reason)
            return
        }

        showCustomAlert(
            title: "删除一级位置",
            subtitle: "确定要删除位置“\(location.name)”吗？\n该位置下的所有二级位置也将被删除。",
            cancelTitle: "取消",
            confirmTitle: "删除",
            onCancel: nil,
            onConfirm: { [weak self] in
            self?.viewModel.deletePrimary(at: index)
        })
    }

    @objc private func deleteSecondaryLocation(_ sender: UIButton) {
        let index = sender.tag
        guard index < viewModel.secondaryLocations.count else { return }
        let location = viewModel.secondaryLocations[index]

        if let reason = viewModel.deleteSecondaryBlockedReason(at: index) {
            showAlert(message: reason)
            return
        }

        showCustomAlert(
            title: "删除二级位置",
            subtitle: "确定要删除位置“\(location.name)”吗？",
            cancelTitle: "取消",
            confirmTitle: "删除",
            onCancel: nil,
            onConfirm: { [weak self] in
            self?.viewModel.deleteSecondary(at: index)
        })
    }

    private func showAlert(message: String) {
        showCustomAlert(
            title: "提示",
            subtitle: message,
            cancelTitle: nil,
            confirmTitle: "确定"
        )
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension LocationManagementViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == leftTableView {
            return viewModel.primaryLocations.count
        } else {
            return viewModel.secondaryLocations.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == leftTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrimaryLocationCell", for: indexPath) as! LocationCell
            let location = viewModel.primaryLocations[indexPath.row]
            cell.configure(with: location, isSelected: location.id == viewModel.selectedPrimaryLocationId)

            cell.editButton.tag = indexPath.row
            cell.editButton.addTarget(self, action: #selector(editPrimaryLocation(_:)), for: .touchUpInside)
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(deletePrimaryLocation(_:)), for: .touchUpInside)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SecondaryLocationCell", for: indexPath) as! LocationCell
            let location = viewModel.secondaryLocations[indexPath.row]
            cell.configure(with: location)

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
            viewModel.selectPrimary(at: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
