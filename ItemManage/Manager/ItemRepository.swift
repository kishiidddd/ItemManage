
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
    
    // MARK: - 写操作
    func addItem(_ item: ItemModel) {
        // 1. 立即添加到本地（乐观更新）
        allItems.append(item)
        itemsById[item.id] = item
        itemsByCategory[item.categoryId, default: []].append(item)
        
        // 2. 异步调用 API 保存
        let request = CreateItemRequest(from: item)
        ItemDataService.shared.createItem(request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedItem):
                    print("✅ API保存成功: \(savedItem.id)")
                case .failure(let error):
                    print("❌ API保存失败: \(error)")
                    // API失败，回滚本地数据
                    self?.allItems.removeAll { $0.id == item.id }
                    self?.itemsById.removeValue(forKey: item.id)
                    self?.itemsByCategory[item.categoryId]?.removeAll { $0.id == item.id }
                }
            }
        }
    }

    func updateItem(_ item: ItemModel) {
        // 1. 立即更新本地数据
        guard let index = allItems.firstIndex(where: { $0.id == item.id }) else { return }
        let oldCategoryId = allItems[index].categoryId
        
        allItems[index] = item
        itemsById[item.id] = item
        
        // 更新分类索引
        if oldCategoryId != item.categoryId {
            itemsByCategory[oldCategoryId]?.removeAll { $0.id == item.id }
            itemsByCategory[item.categoryId, default: []].append(item)
        }
        
        // 2. 异步调用 API 更新
        ItemDataService.shared.updateItem(item) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedItem):
                    print("✅ API更新成功: \(updatedItem.id)")
                case .failure(let error):
                    print("❌ API更新失败: \(error)")
                    // API失败，重新加载数据回滚
                    self?.loadData()
                }
            }
        }
    }

    func deleteItem(id: String) {
        // 1. 立即从本地数据中删除（乐观更新）
        guard let item = itemsById[id] else { return }
        
        // 立即更新本地数据
        allItems.removeAll { $0.id == id }
        itemsById.removeValue(forKey: id)
        itemsByCategory[item.categoryId]?.removeAll { $0.id == id }
        
        // 2. 异步调用 API 删除
        ItemDataService.shared.deleteItem(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ API删除成功: \(id)")
                case .failure(let error):
                    print("❌ API删除失败: \(error)")
                    // 如果 API 删除失败，需要回滚本地数据
                    // 这里需要重新添加回数据，但为了简单，可以重新加载数据
                    self.loadData()
                }
            }
        }
    }
}
