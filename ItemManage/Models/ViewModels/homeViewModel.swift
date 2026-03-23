//
//  HomeViewModel.swift
//  ItemManage
//

import Foundation
import Combine

// MARK: - 分类项模型
struct CategoryItem {
    let id: String?
    let name: String
    let index: Int
    
    static let all = CategoryItem(id: nil, name: "全部", index: 0)
    static let recent = CategoryItem(id: "recent", name: "最近添加", index: 1)
}

// MARK: - 首页ViewModel
class HomeViewModel {
    
    // MARK: - 子ViewModels
    let searchViewModel = SearchViewModel()
    
    // MARK: - Published 属性
    @Published var categories: [CategoryItem] = []
    @Published var currentItems: [ItemModel] = []
    @Published var selectedCategoryIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - 私有属性
    private let itemRepository: ItemRepository
    private var allCategories: [CategoryModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    init(itemRepository: ItemRepository = .shared) {
        self.itemRepository = itemRepository
        setupBindings()
        setupCategories()
        loadData()
    }
    
    // MARK: - 设置绑定
    private func setupBindings() {
        // 监听仓库中所有物品的变化
        itemRepository.$allItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterItemsBySelectedCategory()
            }
            .store(in: &cancellables)
        
        // 监听分类选择变化
        $selectedCategoryIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterItemsBySelectedCategory()
            }
            .store(in: &cancellables)
        
        // 监听搜索状态（如果需要）
        // 如果 SearchViewModel 也需要使用仓库，可以在这里添加绑定
    }
    
    // MARK: - 设置分类
    private func setupCategories() {
        // 从 ItemRepository 获取真实分类
        allCategories = itemRepository.categories
        
        // 构建分类列表
        categories = [CategoryItem.all, CategoryItem.recent]
        categories.append(contentsOf: allCategories.enumerated().map { index, category in
            CategoryItem(id: category.id, name: category.name, index: index + 2)
        })
    }
    
    // MARK: - 加载数据
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        // 模拟网络请求（或者直接使用仓库中的数据）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // 刷新分类（如果仓库中的分类有更新）
            self.allCategories = self.itemRepository.categories
            self.setupCategories()
            
            // 根据当前选中的分类筛选数据
            self.filterItemsBySelectedCategory()
            
            self.isLoading = false
        }
    }
    
    // MARK: - 分类筛选
    private func filterItemsBySelectedCategory() {
        let selectedCategory = categories[selectedCategoryIndex]
        
        if selectedCategory.id == nil { // 全部
            currentItems = itemRepository.allItems
        } else if selectedCategory.id == "recent" { // 最近添加
            currentItems = itemRepository.getRecentItems()
        } else { // 具体分类
            if let categoryId = selectedCategory.id {
                currentItems = itemRepository.getItems(byCategoryId: categoryId)
            } else {
                currentItems = []
            }
        }
    }
    
    // MARK: - 公开方法
    func selectCategory(at index: Int) {
        guard index >= 0 && index < categories.count else { return }
        selectedCategoryIndex = index
    }
    
    func refreshData() {
        // 可以选择重新从数据源加载，或者直接使用仓库中的最新数据
        loadData()
    }
    
    func addItem(_ item: ItemModel) {
        // 通过仓库添加物品，会自动触发更新
        itemRepository.addItem(item)
        // filterItemsBySelectedCategory() 会通过监听自动调用
    }
    
    func removeItem(withId id: String) {
        // 通过仓库删除物品，会自动触发更新
        itemRepository.deleteItem(id: id)
        // filterItemsBySelectedCategory() 会通过监听自动调用
    }
    
    func updateItem(_ item: ItemModel) {
        // 通过仓库更新物品，会自动触发更新
        itemRepository.updateItem(item)
    }
    
    func getItem(at index: Int) -> ItemModel? {
        guard index >= 0 && index < currentItems.count else { return nil }
        return currentItems[index]
    }
}
