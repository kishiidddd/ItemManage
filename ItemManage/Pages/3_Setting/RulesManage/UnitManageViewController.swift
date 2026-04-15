//
//  UnitManageViewController.swift
//  ItemManage
//

import UIKit
import SnapKit
import Combine

final class UnitManageViewController: UIViewController {

    private let viewModel = ItemRulesViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .lightGrayBgColor
        tv.separatorStyle = .singleLine
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGrayBgColor
        title = "单位设置"

        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bind()
        viewModel.load()
    }

    private func bind() {
        viewModel.$units
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self, let message = message, !message.isEmpty else { return }
                self.showCustomAlert(title: "保存失败", subtitle: message, cancelTitle: nil, confirmTitle: "确定")
                self.viewModel.clearError()
            }
            .store(in: &cancellables)
    }

    private func promptAddUnit() {
        showCustomTextFieldAlert(
            title: "添加单位",
            placeholder: "单位名称（如：个、件、瓶）",
            cancelTitle: "取消",
            confirmTitle: "添加"
        ) { [weak self] name in
            self?.viewModel.addUnit(name: name)
        }
    }

    private func confirmDeleteUnit(at index: Int) {
        guard viewModel.units.indices.contains(index) else { return }
        let unit = viewModel.units[index]
        showCustomAlert(
            title: "删除单位",
            subtitle: "确定要删除单位“\(unit.name)”吗？",
            cancelTitle: "取消",
            confirmTitle: "删除",
            onCancel: nil,
            onConfirm: { [weak self] in
            self?.viewModel.deleteUnit(at: index)
        })
    }
}

extension UnitManageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.units.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none

        if indexPath.row < viewModel.units.count {
            let unit = viewModel.units[indexPath.row]
            cell.textLabel?.text = unit.name

            let deleteButton = UIButton(type: .custom)
            deleteButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            deleteButton.setImage(UIImage(named: "loca_icon_delete")?.withRenderingMode(.alwaysOriginal), for: .normal)
            deleteButton.contentMode = .scaleAspectFit
            deleteButton.imageView?.contentMode = .scaleAspectFit
            deleteButton.tag = indexPath.row
            deleteButton.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
            cell.accessoryView = deleteButton
        } else {
            cell.textLabel?.text = "添加新单位"
            cell.textLabel?.textColor = .systemBlue
            cell.accessoryView = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == viewModel.units.count {
            promptAddUnit()
        }
    }

    @objc private func deleteTapped(_ sender: UIButton) {
        confirmDeleteUnit(at: sender.tag)
    }
}

