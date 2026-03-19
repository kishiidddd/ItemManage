//
//  HomeViewModel.swift
//  ItemManage
//
//  Created by a on 2026/3/19.
//

import Foundation
import Combine

class SearchViewModel {
    
    // 原始数据（全部物品）
    @Published var allItems: [ItemModel] = []
    
    // 搜索后的数据
    @Published var filteredItems: [ItemModel] = []
    
    // 搜索关键词
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearch()
        loadItems()
    }
    
    private func setupSearch() {
        // 监听搜索输入
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.filterItems(text: text)
            }
            .store(in: &cancellables)
    }
    
    private func filterItems(text: String) {
        if text.isEmpty {
//            filteredItems = allItems
            filteredItems = [] 
        } else {
            filteredItems = allItems.filter {
                $0.name.contains(text)
            }
        }
    }
    
    private func loadItems() {
        // 模拟数据（你可以换成数据库/API）
        allItems = [
            ItemModel.example(),
            {
                let item = ItemModel()
                item.name = "香蕉"
                return item
            }(),
            {
                let item = ItemModel()
                item.name = "牛奶"
                return item
            }()
        ]
        
        filteredItems = allItems
    }
}
