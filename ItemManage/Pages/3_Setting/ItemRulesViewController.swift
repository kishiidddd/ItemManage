//
//  ItemRulesViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/18.
//

import UIKit
import SnapKit
import Combine

class ItemRulesViewController: UIViewController {

    private let viewModel = ItemRulesViewModel()
    private var cancellables = Set<AnyCancellable>()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .systemGroupedBackground
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.load()
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "物品规则设置"

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func bindViewModel() {
        viewModel.$categories
            .combineLatest(viewModel.$units)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self, let message = message, !message.isEmpty else { return }
                self.showRulesError(message)
                self.viewModel.clearError()
            }
            .store(in: &cancellables)
    }

    private func showRulesError(_ message: String) {
        let alert = UIAlertController(title: "保存失败", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    @objc private func addUnitTapped() {
        let alert = UIAlertController(title: "添加单位", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "单位名称（如：个、件、瓶）"
        }

        let addAction = UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text else { return }
            self?.viewModel.addUnit(name: name)
        }

        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))

        present(alert, animated: true)
    }

    @objc private func addCategoryTapped() {
        let alert = UIAlertController(title: "添加分类", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "分类名称"
        }

        let addAction = UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text else { return }
            self?.viewModel.addCategory(name: name)
        }

        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))

        present(alert, animated: true)
    }

    @objc private func deleteUnit(_ sender: UIButton) {
        let index = sender.tag
        guard index < viewModel.units.count else { return }

        let alert = UIAlertController(
            title: "删除单位",
            message: "确定要删除单位“\(viewModel.units[index].name)”吗？",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteUnit(at: index)
        })

        present(alert, animated: true)
    }

    @objc private func deleteCategory(_ sender: UIButton) {
        let index = sender.tag
        guard index < viewModel.categories.count else { return }

        let alert = UIAlertController(
            title: "删除分类",
            message: "确定要删除分类“\(viewModel.categories[index].name)”吗？",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: index)
        })

        present(alert, animated: true)
    }

    @objc private func locationManagementTapped() {
        let locationVC = LocationManagementViewController()
        navigationController?.pushViewController(locationVC, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ItemRulesViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return viewModel.units.count + 1
        case 2:
            return viewModel.categories.count + 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "位置管理"
        case 1: return "单位管理"
        case 2: return "分类管理"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "位置设置"
            cell.imageView?.image = UIImage(systemName: "location.fill")
            cell.imageView?.tintColor = .systemBlue
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(locationManagementTapped))
            cell.addGestureRecognizer(tapGesture)

        case 1:
            if indexPath.row < viewModel.units.count {
                let unit = viewModel.units[indexPath.row]
                cell.textLabel?.text = unit.name
                cell.imageView?.image = UIImage(systemName: "ruler")
                cell.imageView?.tintColor = .systemBlue

                let deleteButton = UIButton(type: .system)
                deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
                deleteButton.tintColor = .red
                deleteButton.tag = indexPath.row
                deleteButton.addTarget(self, action: #selector(deleteUnit(_:)), for: .touchUpInside)
                cell.accessoryView = deleteButton
            } else {
                cell.textLabel?.text = "添加新单位"
                cell.textLabel?.textColor = .systemBlue
                cell.imageView?.image = UIImage(systemName: "plus.circle")
                cell.imageView?.tintColor = .systemBlue
                cell.accessoryView = nil
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addUnitTapped))
                cell.addGestureRecognizer(tapGesture)
            }

        case 2:
            if indexPath.row < viewModel.categories.count {
                let category = viewModel.categories[indexPath.row]
                cell.textLabel?.text = category.name
                cell.imageView?.image = UIImage(systemName: "folder")
                cell.imageView?.tintColor = .systemBlue

                let deleteButton = UIButton(type: .system)
                deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
                deleteButton.tintColor = .red
                deleteButton.tag = indexPath.row
                deleteButton.addTarget(self, action: #selector(deleteCategory(_:)), for: .touchUpInside)
                cell.accessoryView = deleteButton
            } else {
                cell.textLabel?.text = "添加新分类"
                cell.textLabel?.textColor = .systemBlue
                cell.imageView?.image = UIImage(systemName: "plus.circle")
                cell.imageView?.tintColor = .systemBlue
                cell.accessoryView = nil
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addCategoryTapped))
                cell.addGestureRecognizer(tapGesture)
            }

        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            locationManagementTapped()
        }
    }
}
