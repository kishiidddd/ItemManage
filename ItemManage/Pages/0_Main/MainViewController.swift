//
//  MainViewController.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import UIKit
import SnapKit
import Kingfisher
import Foundation
import Combine


class MainViewController: UIViewController {
    let viewModel = SearchViewModel()
    
    private var isSearching = false
    private var cancellables = Set<AnyCancellable>()

    private lazy var homeTopView: HomeTopView = {
        let view = HomeTopView()
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var grayBg : UIView = {
        let bg = UIView()
        bg.backgroundColor = .lightGrayBgColor
        bg.layer.cornerRadius = 20
        bg.layer.masksToBounds = true
        return bg
    }()

    private lazy var messageScrollView = HomeMessageScrollView()
    
    // ✅ 普通模式下的搜索框
    private lazy var normalSearchView = HomeSearchView()
    
    // ✅ 搜索模式下的搜索框（在顶部容器中）
    private lazy var searchView = HomeSearchView()
    
    private lazy var itemsView = HomeItemsView()

    // 顶部搜索容器（用于吸顶）
    private lazy var searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGrayBgColor
        view.isHidden = true
        return view
    }()

    // 搜索结果列表
    private lazy var searchTableView: UITableView = {
        let tv = UITableView()
        tv.register(HomeItemCell.self, forCellReuseIdentifier: HomeItemCell.identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.isHidden = true
        tv.backgroundColor = .lightGrayBgColor
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        messageScrollView.presentingHost = self
        messageScrollView.onGuideSpotlightTapped = { [weak self] in
            self?.openStorageGuideTab()
        }
        setupUI()
        setupConstraints()
        setupTapBack()
        setupBinding()
        setupSearchAction()
        setupTableViewBackground()
        setupNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshHomeGuideSpotlightFromServer()
        messageScrollView.updateFromHome(allItems: ItemRepository.shared.allItems)
    }

    /// 拉取指南列表并刷新首页主推卡片文案（失败时仍用本地兜底 `displayItems`）
    private func refreshHomeGuideSpotlightFromServer() {
        StorageGuideAPI.fetchTips { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let items) = result {
                    StorageGuideRuntimeData.applyServerItems(items)
                }
                self?.messageScrollView.updateFromHome(allItems: ItemRepository.shared.allItems)
            }
        }
    }

    /// 切换到含 `StorageGuideViewController` 的 Tab（若未嵌入 TabBar 则无效果）
    private func openStorageGuideTab() {
        guard let tab = tabBarController,
              let vcs = tab.viewControllers,
              let idx = vcs.firstIndex(where: { vc in
                  if let nav = vc as? UINavigationController {
                      return nav.viewControllers.contains { $0 is StorageGuideViewController }
                  }
                  return vc is StorageGuideViewController
              }) else { return }
        tab.selectedIndex = idx
        if let nav = vcs[idx] as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
    }
    
    private func setupNotifications(){
        NotificationCenter.default.addObserver(self,selector: #selector(showItemDetail), name: NSNotification.Name("DidSelectItem"), object: nil)
    }
    
    @objc func showItemDetail(_ notification:Notification){
        guard let item = notification.object as? ItemModel else { return }
        
        let popup = ItemDetailPopupViewController(item: item)
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: true)
    }

    
    private func setupBinding() {
        // 两个搜索框共用同一个回调
        let textChangeHandler: (String) -> Void = { [weak self] text in
            self?.viewModel.searchText = text
        }
        
        normalSearchView.onTextChange = textChangeHandler
        searchView.onTextChange = textChangeHandler
        
        // ViewModel → UI（刷新列表）
        viewModel.$filteredItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                print("搜索结果：\(items.map { $0.name })")
                self?.searchTableView.reloadData()
            }
            .store(in: &cancellables)

        ItemRepository.shared.$allItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.messageScrollView.updateFromHome(allItems: items)
            }
            .store(in: &cancellables)
    }
    
    private func setupTapBack(){
        homeTopView.onAddTapped = {
            let vc = AddItemViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigateToViewController(vc)
        }
    }

    private func setupUI(){
        view.backgroundColor = .lightGrayBgColor
        view.addSubview(homeTopView)
        view.addSubview(grayBg)
        view.addSubview(messageScrollView)
        
        // ✅ 添加普通模式的搜索框
        view.addSubview(normalSearchView)
        
        view.addSubview(itemsView)
        
        // 搜索模式相关的视图
        view.addSubview(searchContainer)
        view.addSubview(searchTableView)
        
        // 把搜索模式的 searchView 添加到 container 中
        searchContainer.addSubview(searchView)
    }

    private func setupConstraints(){
        homeTopView.snp.makeConstraints{ make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(320)
        }

        grayBg.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(180)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(100)
        }

        messageScrollView.snp.makeConstraints { make in
            make.top.equalTo(grayBg.snp.top).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(104)
        }

        // ✅ 普通搜索框的约束
        normalSearchView.snp.makeConstraints { make in
            make.top.equalTo(messageScrollView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }

        itemsView.snp.makeConstraints { make in
            make.top.equalTo(normalSearchView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }

        // 搜索容器的约束
        searchContainer.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(108)
        }

        // ✅ 搜索模式下的搜索框约束
        searchView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(48)
        }

        // 搜索结果列表的约束
        searchTableView.snp.makeConstraints { make in
            make.top.equalTo(searchContainer.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupSearchAction() {
        normalSearchView.onBeginEditing = { [weak self] in
            self?.enterSearchMode()
        }
    }

    private func setupTableViewBackground() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(exitSearchMode))
        backgroundView.addGestureRecognizer(tap)
        
        searchTableView.backgroundView = backgroundView
    }
    
    private func enterSearchMode() {
        guard !isSearching else { return }
        isSearching = true
        
        self.tabBarController?.tabBar.isHidden = true
        
        //清空
        searchView.text = ""
        viewModel.searchText = ""
        
        // ✅ 显示搜索模式相关视图
        searchContainer.isHidden = false
        searchTableView.isHidden = false
        
        // ✅ 让搜索模式的搜索框成为第一响应者
        DispatchQueue.main.async { [weak self] in
            let success = self?.searchView.becomeFirstResponder() ?? false
            print("searchView.becomeFirstResponder() 结果: \(success)")
        }

    }

    @objc private func exitSearchMode() {
        guard isSearching else { return }
        isSearching = false
        
        self.tabBarController?.tabBar.isHidden = false
        
        view.endEditing(true)
        
        // ✅ 隐藏搜索模式相关视图
        searchContainer.isHidden = true
        searchTableView.isHidden = true
        
        // ✅ 显示普通搜索框
        normalSearchView.isHidden = false
        
        //清空
        searchView.text = ""
        viewModel.searchText = ""
        
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: HomeItemCell.identifier,
            for: indexPath
        ) as! HomeItemCell
        
        let item = viewModel.filteredItems[indexPath.row]
        cell.configure(with: item)
        
        return cell
    }
    
    // 添加这个方法处理搜索结果点击
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = viewModel.filteredItems[indexPath.row]
        
        // 弹出详情卡片（覆盖整个屏幕，包括搜索模式）
        let popup = ItemDetailPopupViewController(item: item)
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: true)
    }
}
