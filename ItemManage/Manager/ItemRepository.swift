
//
//  ItemRepository.swift
//  ItemManage
//

import Foundation
import Combine

// MARK: - 全局数据仓库
class ItemRepository: ObservableObject {
    static let shared = ItemRepository()
    private init() {
        loadData()
    }
    
    // 原始数据 - 全局唯一
    @Published private(set) var allItems: [ItemModel] = []
    @Published private(set) var categories: [CategoryModel] = []
    @Published private(set) var units: [UnitModel] = []
    
    // 缓存和索引
    private var itemsById: [String: ItemModel] = [:]
    private var itemsByCategory: [String: [ItemModel]] = [:]
    
    // MARK: - 数据加载
    func loadData() {
        // 从 MockDataService 或 API 加载
        allItems = MockDataService.shared.getItems()
        categories = MockDataService.shared.getCategories()
        units = MockDataService.shared.getUnits() ?? []
        
        buildIndexes()
    }
    
    private func buildIndexes() {
        itemsById = Dictionary(uniqueKeysWithValues: allItems.map { ($0.id, $0) })
        itemsByCategory = Dictionary(grouping: allItems) { $0.categoryId }
    }
    
    // MARK: - 查询方法（全局统一的查询逻辑）
    func getItem(byId id: String) -> ItemModel? {
        return itemsById[id]
    }
    
    func getItems(byCategoryId categoryId: String) -> [ItemModel] {
        return itemsByCategory[categoryId] ?? []
    }
    
    func getRecentItems(days: Int = 7) -> [ItemModel] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return allItems.filter { $0.createdAt >= cutoffDate }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func searchItems(keyword: String) -> [ItemModel] {
        guard !keyword.isEmpty else { return [] }
        return allItems.filter {
            $0.name.localizedCaseInsensitiveContains(keyword) ||
            $0.remarks?.localizedCaseInsensitiveContains(keyword) == true
        }
    }
    
    // MARK: - 写操作（会触发全局更新）
    func addItem(_ item: ItemModel) {
        allItems.append(item)
        itemsById[item.id] = item
        itemsByCategory[item.categoryId, default: []].append(item)
    }
    
    func updateItem(_ item: ItemModel) {
        guard let index = allItems.firstIndex(where: { $0.id == item.id }) else { return }
        allItems[index] = item
        itemsById[item.id] = item
        
        // 更新分类索引（如果分类变了）
        if allItems[index].categoryId != item.categoryId {
            itemsByCategory[allItems[index].categoryId]?.removeAll { $0.id == item.id }
            itemsByCategory[item.categoryId, default: []].append(item)
        }
    }
    
    func deleteItem(id: String) {
        guard let item = itemsById[id] else { return }
        allItems.removeAll { $0.id == id }
        itemsById.removeValue(forKey: id)
        itemsByCategory[item.categoryId]?.removeAll { $0.id == id }
    }
}
