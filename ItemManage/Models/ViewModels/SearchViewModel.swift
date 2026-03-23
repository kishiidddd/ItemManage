////
////  HomeViewModel.swift
////  ItemManage
////
////  Created by a on 2026/3/19.
////
//
//import Foundation
//import Combine
//
//class SearchViewModel {
//    
//    // 原始数据（全部物品）
//    @Published var allItems: [ItemModel] = []
//    
//    // 搜索后的数据
//    @Published var filteredItems: [ItemModel] = []
//    
//    // 搜索关键词
//    @Published var searchText: String = ""
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        setupSearch()
//        loadItems()
//    }
//    
//    private func setupSearch() {
//        // 监听搜索输入
//        $searchText
//            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
//            .removeDuplicates()
//            .sink { [weak self] text in
//                self?.filterItems(text: text)
//            }
//            .store(in: &cancellables)
//    }
//    
//    private func filterItems(text: String) {
//        if text.isEmpty {
//            filteredItems = [] 
//        } else {
//            filteredItems = allItems.filter {
//                $0.name.contains(text)
//            }
//        }
//    }
//    
//    private func loadItems() {
//        // 模拟数据（你可以换成数据库/API）
//        allItems = [
//            ItemModel.example(),
//            {
//                let item = ItemModel()
//                item.name = "香蕉"
//                return item
//            }(),
//            {
//                let item = ItemModel()
//                item.name = "牛奶"
//                return item
//            }()
//        ]
//        
//        filteredItems = allItems
//    }
//}


import Foundation
import Combine
// MARK: - SearchViewModel（如果需要，也改为使用 ItemRepository）
class SearchViewModel {
    
    // MARK: - Published 属性
    @Published var searchText: String = ""
    @Published var filteredItems: [ItemModel] = []
    @Published var isSearching: Bool = false
    
    // MARK: - 私有属性
    private let itemRepository: ItemRepository
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    init(itemRepository: ItemRepository = .shared) {
        self.itemRepository = itemRepository
        setupSearch()
    }
    
    // MARK: - 设置搜索监听
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.isSearching = !text.isEmpty
                self?.performSearch(text: text)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 执行搜索
    private func performSearch(text: String) {
        filteredItems = itemRepository.searchItems(keyword: text)
    }
    
    // MARK: - 清除搜索
    func clearSearch() {
        searchText = ""
        filteredItems = []
        isSearching = false
    }
}
