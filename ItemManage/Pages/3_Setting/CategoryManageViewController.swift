//
//  CategoryManageViewController.swift
//  ItemManage
//

import UIKit
import SnapKit
import Combine

final class CategoryManageViewController: UIViewController {

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
        title = "分类设置"

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
        viewModel.$categories
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

    private func promptAddCategory() {
        let alert = UIAlertController(title: "添加分类", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "分类名称"
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            let name = alert.textFields?.first?.text ?? ""
            self?.viewModel.addCategory(name: name)
        })
        present(alert, animated: true)
    }

    private func confirmDeleteCategory(at index: Int) {
        guard viewModel.categories.indices.contains(index) else { return }
        let category = viewModel.categories[index]
        let alert = UIAlertController(title: "删除分类", message: "确定要删除分类“\(category.name)”吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: index)
        })
        present(alert, animated: true)
    }
}

extension CategoryManageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none

        if indexPath.row < viewModel.categories.count {
            let category = viewModel.categories[indexPath.row]
            cell.textLabel?.text = category.name

            let deleteButton = UIButton(type: .system)
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
            deleteButton.tintColor = .systemRed
            deleteButton.tag = indexPath.row
            deleteButton.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
            cell.accessoryView = deleteButton
        } else {
            cell.textLabel?.text = "添加新分类"
            cell.textLabel?.textColor = .systemBlue
            cell.accessoryView = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == viewModel.categories.count {
            promptAddCategory()
        }
    }

    @objc private func deleteTapped(_ sender: UIButton) {
        confirmDeleteCategory(at: sender.tag)
    }
}

