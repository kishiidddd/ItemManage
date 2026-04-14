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
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .singleLine
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
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
                let alert = UIAlertController(title: "保存失败", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                self.present(alert, animated: true)
                self.viewModel.clearError()
            }
            .store(in: &cancellables)
    }

    private func promptAddUnit() {
        let alert = UIAlertController(title: "添加单位", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "单位名称（如：个、件、瓶）"
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            let name = alert.textFields?.first?.text ?? ""
            self?.viewModel.addUnit(name: name)
        })
        present(alert, animated: true)
    }

    private func confirmDeleteUnit(at index: Int) {
        guard viewModel.units.indices.contains(index) else { return }
        let unit = viewModel.units[index]
        let alert = UIAlertController(title: "删除单位", message: "确定要删除单位“\(unit.name)”吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteUnit(at: index)
        })
        present(alert, animated: true)
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

            let deleteButton = UIButton(type: .system)
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
            deleteButton.tintColor = .systemRed
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

