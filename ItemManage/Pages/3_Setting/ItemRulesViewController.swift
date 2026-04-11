////
////  ItemRulesViewController.swift
////  ItemManage
////
////  Created by a on 2026/3/18.
////
//
//import UIKit
//import SnapKit
//
//class ItemRulesViewController: UIViewController {
//    
//    // MARK: - Properties
//    private var categories: [CategoryModel] = []
//    private var units: [UnitModel] = []
//    
//    // MARK: - UI Elements
//    private lazy var tableView: UITableView = {
//        let tv = UITableView(frame: .zero, style: .insetGrouped)
//        tv.backgroundColor = .systemGroupedBackground
//        tv.delegate = self
//        tv.dataSource = self
//        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        return tv
//    }()
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadData()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = .systemGroupedBackground
//        title = "物品规则设置"
//        
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//    }
//    
//    private func loadData() {
//        // 加载单位（放在前面）
//        ItemDataService.shared.getUnits { [weak self] units in
//            self?.units = units
//            self?.tableView.reloadData()
//        }
//        
//        // 加载分类
//        ItemDataService.shared.getCategories { [weak self] categories in
//            self?.categories = categories
//            self?.tableView.reloadData()
//        }
//    }
//    
//    @objc private func addUnitTapped() {
//        let alert = UIAlertController(title: "添加单位", message: nil, preferredStyle: .alert)
//        alert.addTextField { textField in
//            textField.placeholder = "单位名称（如：个、件、瓶）"
//        }
//        
//        let addAction = UIAlertAction(title: "添加", style: .default) { [weak self] _ in
//            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
//            
//            let newUnit = UnitModel()
//            newUnit.id = UUID().uuidString
//            newUnit.name = name
//            newUnit.abbreviation = name
//            
//            // 这里应该调用数据服务保存
//            // ItemDataService.shared.addUnit(newUnit)
//            
//            self?.units.append(newUnit)
//            self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
//        }
//        
//        alert.addAction(addAction)
//        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
//        
//        present(alert, animated: true)
//    }
//    
//    @objc private func addCategoryTapped() {
//        let alert = UIAlertController(title: "添加分类", message: nil, preferredStyle: .alert)
//        alert.addTextField { textField in
//            textField.placeholder = "分类名称"
//        }
//        
//        let addAction = UIAlertAction(title: "添加", style: .default) { [weak self] _ in
//            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
//            
//            let newCategory = CategoryModel()
//            newCategory.id = UUID().uuidString
//            newCategory.name = name
//            
//            // 这里应该调用数据服务保存
//            // ItemDataService.shared.addCategory(newCategory)
//            
//            self?.categories.append(newCategory)
//            self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
//        }
//        
//        alert.addAction(addAction)
//        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
//        
//        present(alert, animated: true)
//    }
//    
//    @objc private func deleteUnit(_ sender: UIButton) {
//        let index = sender.tag
//        guard index < units.count else { return }
//        
//        let alert = UIAlertController(
//            title: "删除单位",
//            message: "确定要删除单位“\(units[index].name)”吗？",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
//        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
//            // 这里应该调用数据服务删除
//            // ItemDataService.shared.deleteUnit(self?.units[index].id ?? "")
//            
//            self?.units.remove(at: index)
//            self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
//        })
//        
//        present(alert, animated: true)
//    }
//    
//    @objc private func deleteCategory(_ sender: UIButton) {
//        let index = sender.tag
//        guard index < categories.count else { return }
//        
//        let alert = UIAlertController(
//            title: "删除分类",
//            message: "确定要删除分类“\(categories[index].name)”吗？",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
//        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
//            // 这里应该调用数据服务删除
//            // ItemDataService.shared.deleteCategory(self?.categories[index].id ?? "")
//            
//            self?.categories.remove(at: index)
//            self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
//        })
//        
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - UITableViewDelegate & UITableViewDataSource
//extension ItemRulesViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2 // 单位管理、分类管理
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0: // 单位管理（放在前面）
//            return units.count + 1 // 单位列表 + 添加按钮
//        case 1: // 分类管理
//            return categories.count + 1 // 分类列表 + 添加按钮
//        default:
//            return 0
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return "单位管理"
//        case 1:
//            return "分类管理"
//        default:
//            return nil
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
//        cell.selectionStyle = .none
//        
//        switch indexPath.section {
//        case 0: // 单位管理（放在前面）
//            if indexPath.row < units.count {
//                let unit = units[indexPath.row]
//                cell.textLabel?.text = unit.name
//                cell.imageView?.image = UIImage(systemName: "ruler")
//                cell.imageView?.tintColor = .systemBlue
//                
//                // 添加删除按钮
//                let deleteButton = UIButton(type: .system)
//                deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
//                deleteButton.tintColor = .red
//                deleteButton.tag = indexPath.row
//                deleteButton.addTarget(self, action: #selector(deleteUnit(_:)), for: .touchUpInside)
//                
//                cell.accessoryView = deleteButton
//            } else {
//                cell.textLabel?.text = "添加新单位"
//                cell.textLabel?.textColor = .systemBlue
//                cell.imageView?.image = UIImage(systemName: "plus.circle")
//                cell.imageView?.tintColor = .systemBlue
//                cell.accessoryView = nil
//                
//                // 添加点击手势
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addUnitTapped))
//                cell.addGestureRecognizer(tapGesture)
//            }
//            
//        case 1: // 分类管理
//            if indexPath.row < categories.count {
//                let category = categories[indexPath.row]
//                cell.textLabel?.text = category.name
//                cell.imageView?.image = UIImage(systemName: "folder")
//                cell.imageView?.tintColor = .systemBlue
//                
//                // 添加删除按钮
//                let deleteButton = UIButton(type: .system)
//                deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
//                deleteButton.tintColor = .red
//                deleteButton.tag = indexPath.row
//                deleteButton.addTarget(self, action: #selector(deleteCategory(_:)), for: .touchUpInside)
//                
//                cell.accessoryView = deleteButton
//            } else {
//                cell.textLabel?.text = "添加新分类"
//                cell.textLabel?.textColor = .systemBlue
//                cell.imageView?.image = UIImage(systemName: "plus.circle")
//                cell.imageView?.tintColor = .systemBlue
//                cell.accessoryView = nil
//                
//                // 添加点击手势
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addCategoryTapped))
//                cell.addGestureRecognizer(tapGesture)
//            }
//            
//        default:
//            break
//        }
//        
//        return cell
//    }
//}

//
//  ItemRulesViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/18.
//

import UIKit
import SnapKit

class ItemRulesViewController: UIViewController {
    
    // MARK: - Properties
    private var categories: [CategoryModel] = []
    private var units: [UnitModel] = []
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .systemGroupedBackground
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "物品规则设置"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func showRulesError(_ message: String) {
        let alert = UIAlertController(title: "保存失败", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func loadData() {
        // 加载单位（放在前面）
        ItemDataService.shared.getUnits { [weak self] units in
            self?.units = units
            self?.tableView.reloadData()
        }
        
        // 加载分类
        ItemDataService.shared.getCategories { [weak self] categories in
            self?.categories = categories
            self?.tableView.reloadData()
        }
    }
    
    @objc private func addUnitTapped() {
        let alert = UIAlertController(title: "添加单位", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "单位名称（如：个、件、瓶）"
        }
        
        let addAction = UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
            
            ItemRepository.shared.createUnit(name: name) { result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.units = ItemRepository.shared.units
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                case .failure(let error):
                    self.showRulesError(error.localizedDescription)
                }
            }
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
            guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
            
            ItemRepository.shared.createCategory(name: name) { result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.categories = ItemRepository.shared.categories
                    self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
                case .failure(let error):
                    self.showRulesError(error.localizedDescription)
                }
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func deleteUnit(_ sender: UIButton) {
        let index = sender.tag
        guard index < units.count else { return }
        
        let alert = UIAlertController(
            title: "删除单位",
            message: "确定要删除单位“\(units[index].name)”吗？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            // 这里应该调用数据服务删除
            // ItemDataService.shared.deleteUnit(self?.units[index].id ?? "")
            
            self?.units.remove(at: index)
            self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic) // 单位现在在第1个section
        })
        
        present(alert, animated: true)
    }
    
    @objc private func deleteCategory(_ sender: UIButton) {
        let index = sender.tag
        guard index < categories.count else { return }
        
        let alert = UIAlertController(
            title: "删除分类",
            message: "确定要删除分类“\(categories[index].name)”吗？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            // 这里应该调用数据服务删除
            // ItemDataService.shared.deleteCategory(self?.categories[index].id ?? "")
            
            self?.categories.remove(at: index)
            self?.tableView.reloadSections(IndexSet(integer: 2), with: .automatic) // 分类现在在第2个section
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
        return 3 // 位置管理、单位管理、分类管理
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // 位置管理（新增）
            return 1 // 只是一个入口按钮
        case 1: // 单位管理
            return units.count + 1 // 单位列表 + 添加按钮
        case 2: // 分类管理
            return categories.count + 1 // 分类列表 + 添加按钮
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "位置管理"
        case 1:
            return "单位管理"
        case 2:
            return "分类管理"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0: // 位置管理（新增）
            cell.textLabel?.text = "位置设置"
            cell.imageView?.image = UIImage(systemName: "location.fill")
            cell.imageView?.tintColor = .systemBlue
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
            
            // 添加点击手势
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(locationManagementTapped))
            cell.addGestureRecognizer(tapGesture)
            
        case 1: // 单位管理
            if indexPath.row < units.count {
                let unit = units[indexPath.row]
                cell.textLabel?.text = unit.name
                cell.imageView?.image = UIImage(systemName: "ruler")
                cell.imageView?.tintColor = .systemBlue
                
                // 添加删除按钮
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
                
                // 添加点击手势
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addUnitTapped))
                cell.addGestureRecognizer(tapGesture)
            }
            
        case 2: // 分类管理
            if indexPath.row < categories.count {
                let category = categories[indexPath.row]
                cell.textLabel?.text = category.name
                cell.imageView?.image = UIImage(systemName: "folder")
                cell.imageView?.tintColor = .systemBlue
                
                // 添加删除按钮
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
                
                // 添加点击手势
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
