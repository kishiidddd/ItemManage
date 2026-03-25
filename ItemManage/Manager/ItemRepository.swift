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
    @Published private(set) var primaryLocations: [PrimaryLocationModel] = []
    @Published private(set) var secondaryLocations: [SecondaryLocationModel] = []
    
    // 缓存和索引
    private var itemsById: [String: ItemModel] = [:]
    private var itemsByCategory: [String: [ItemModel]] = [:]
    private var itemsByPrimaryLocation: [String: [ItemModel]] = [:]
    private var itemsBySecondaryLocation: [String: [ItemModel]] = [:]
    private var secondaryLocationsByPrimary: [String: [SecondaryLocationModel]] = [:]
    
    // MARK: - 数据加载
    func loadData() {
        // 从 MockDataService 或 API 加载
        allItems = MockDataService.shared.getItems()
        categories = MockDataService.shared.getCategories()
        units = MockDataService.shared.getUnits() ?? []
        primaryLocations = MockDataService.shared.getPrimaryLocations()
        secondaryLocations = MockDataService.shared.getSecondaryLocations()
        
        buildIndexes()
    }
    
    private func buildIndexes() {
        itemsById = Dictionary(uniqueKeysWithValues: allItems.map { ($0.id, $0) })
        itemsByCategory = Dictionary(grouping: allItems) { $0.categoryId }
        
        // 位置相关索引
        itemsByPrimaryLocation = Dictionary(grouping: allItems) { $0.primaryLocationId ?? "" }
        itemsBySecondaryLocation = Dictionary(grouping: allItems) { $0.secondaryLocationId ?? "" }
        
        // 构建二级位置和一级位置的对应关系
        secondaryLocationsByPrimary = Dictionary(grouping: secondaryLocations) { $0.primaryLocationId }
        
        // 建立位置对象的关联
        for item in allItems {
            if let primaryId = item.primaryLocationId {
                item.primaryLocation = primaryLocations.first(where: { $0.id == primaryId })
            }
            if let secondaryId = item.secondaryLocationId {
                item.secondaryLocation = secondaryLocations.first(where: { $0.id == secondaryId })
            }
        }
        
        // 为一级位置建立二级位置关联
        for primaryLocation in primaryLocations {
            primaryLocation.secondaryLocations = secondaryLocationsByPrimary[primaryLocation.id]
        }
    }
    
    // MARK: - 物品查询方法
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
    
    // MARK: - 位置查询方法
    func getPrimaryLocations() -> [PrimaryLocationModel] {
        return primaryLocations
    }
    
    func getSecondaryLocations() -> [SecondaryLocationModel] {
        return secondaryLocations
    }
    
    func getSecondaryLocations(for primaryLocationId: String) -> [SecondaryLocationModel] {
        return secondaryLocationsByPrimary[primaryLocationId] ?? []
    }
    
    func getItems(byPrimaryLocationId locationId: String) -> [ItemModel] {
        return itemsByPrimaryLocation[locationId] ?? []
    }
    
    func getItems(bySecondaryLocationId locationId: String) -> [ItemModel] {
        return itemsBySecondaryLocation[locationId] ?? []
    }
    
    func getPrimaryLocation(byId id: String) -> PrimaryLocationModel? {
        return primaryLocations.first { $0.id == id }
    }
    
    func getSecondaryLocation(byId id: String) -> SecondaryLocationModel? {
        return secondaryLocations.first { $0.id == id }
    }
    
    // MARK: - 一级位置写操作
    func addPrimaryLocation(_ location: PrimaryLocationModel) {
        // 添加到本地
        primaryLocations.append(location)
        secondaryLocationsByPrimary[location.id] = []
        
        // 异步调用 API 保存
        ItemDataService.shared.createPrimaryLocation(location) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedLocation):
                    print("✅ API保存一级位置成功: \(savedLocation.name)")
                case .failure(let error):
                    print("❌ API保存一级位置失败: \(error)")
                    // API失败，回滚本地数据
                    self.primaryLocations.removeAll { $0.id == location.id }
                    self.secondaryLocationsByPrimary.removeValue(forKey: location.id)
                }
            }
        }
    }
    
    func updatePrimaryLocation(_ location: PrimaryLocationModel) {
        guard let index = primaryLocations.firstIndex(where: { $0.id == location.id }) else { return }
        primaryLocations[index] = location
        
        // 异步调用 API 更新
        ItemDataService.shared.updatePrimaryLocation(location) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ API更新一级位置成功: \(location.name)")
                case .failure(let error):
                    print("❌ API更新一级位置失败: \(error)")
                    // API失败，重新加载数据回滚
                    self.loadData()
                }
            }
        }
    }
    
    func deletePrimaryLocation(id: String) {
        guard let location = getPrimaryLocation(byId: id) else { return }
        
        // 检查是否有物品使用这个位置
        let itemsInLocation = getItems(byPrimaryLocationId: id)
        if !itemsInLocation.isEmpty {
            print("⚠️ 无法删除位置，有 \(itemsInLocation.count) 个物品使用此位置")
            return
        }
        
        // 删除该位置下的所有二级位置
        let secondaryLocationsToDelete = getSecondaryLocations(for: id)
        for secondary in secondaryLocationsToDelete {
            deleteSecondaryLocation(id: secondary.id, skipApi: true)
        }
        
        // 从本地删除
        primaryLocations.removeAll { $0.id == id }
        secondaryLocationsByPrimary.removeValue(forKey: id)
        
        // 异步调用 API 删除
        ItemDataService.shared.deletePrimaryLocation(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ API删除一级位置成功: \(id)")
                case .failure(let error):
                    print("❌ API删除一级位置失败: \(error)")
                    // API失败，重新加载数据回滚
                    self.loadData()
                }
            }
        }
    }
    
    // MARK: - 二级位置写操作
    func addSecondaryLocation(_ location: SecondaryLocationModel) {
        // 检查一级位置是否存在
        guard primaryLocations.contains(where: { $0.id == location.primaryLocationId }) else {
            print("❌ 一级位置不存在")
            return
        }
        
        // 添加到本地
        secondaryLocations.append(location)
        secondaryLocationsByPrimary[location.primaryLocationId, default: []].append(location)
        
        // 异步调用 API 保存
        ItemDataService.shared.createSecondaryLocation(location) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedLocation):
                    print("✅ API保存二级位置成功: \(savedLocation.name)")
                case .failure(let error):
                    print("❌ API保存二级位置失败: \(error)")
                    // API失败，回滚本地数据
                    self.secondaryLocations.removeAll { $0.id == location.id }
                    self.secondaryLocationsByPrimary[location.primaryLocationId]?.removeAll { $0.id == location.id }
                }
            }
        }
    }
    
    func updateSecondaryLocation(_ location: SecondaryLocationModel) {
        guard let index = secondaryLocations.firstIndex(where: { $0.id == location.id }) else { return }
        
        let oldLocation = secondaryLocations[index]
        secondaryLocations[index] = location
        
        // 如果一级位置发生变化，更新索引
        if oldLocation.primaryLocationId != location.primaryLocationId {
            secondaryLocationsByPrimary[oldLocation.primaryLocationId]?.removeAll { $0.id == location.id }
            secondaryLocationsByPrimary[location.primaryLocationId, default: []].append(location)
        }
        
        // 异步调用 API 更新
        ItemDataService.shared.updateSecondaryLocation(location) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ API更新二级位置成功: \(location.name)")
                case .failure(let error):
                    print("❌ API更新二级位置失败: \(error)")
                    // API失败，重新加载数据回滚
                    self.loadData()
                }
            }
        }
    }
    
    func deleteSecondaryLocation(id: String, skipApi: Bool = false) {
        guard let location = getSecondaryLocation(byId: id) else { return }
        
        // 检查是否有物品使用这个二级位置
        let itemsInLocation = getItems(bySecondaryLocationId: id)
        if !itemsInLocation.isEmpty {
            print("⚠️ 无法删除位置，有 \(itemsInLocation.count) 个物品使用此位置")
            return
        }
        
        // 从本地删除
        secondaryLocations.removeAll { $0.id == id }
        secondaryLocationsByPrimary[location.primaryLocationId]?.removeAll { $0.id == id }
        
        if !skipApi {
            // 异步调用 API 删除
            ItemDataService.shared.deleteSecondaryLocation(id: id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("✅ API删除二级位置成功: \(id)")
                    case .failure(let error):
                        print("❌ API删除二级位置失败: \(error)")
                        // API失败，重新加载数据回滚
                        self.loadData()
                    }
                }
            }
        }
    }
    
    // MARK: - 物品写操作
    func addItem(_ item: ItemModel) {
        // 1. 立即添加到本地（乐观更新）
        allItems.append(item)
        itemsById[item.id] = item
        itemsByCategory[item.categoryId, default: []].append(item)
        
        // 处理位置索引
        if let primaryId = item.primaryLocationId, !primaryId.isEmpty {
            itemsByPrimaryLocation[primaryId, default: []].append(item)
        }
        if let secondaryId = item.secondaryLocationId, !secondaryId.isEmpty {
            itemsBySecondaryLocation[secondaryId, default: []].append(item)
        }
        
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
                    
                    if let primaryId = item.primaryLocationId {
                        self?.itemsByPrimaryLocation[primaryId]?.removeAll { $0.id == item.id }
                    }
                    if let secondaryId = item.secondaryLocationId {
                        self?.itemsBySecondaryLocation[secondaryId]?.removeAll { $0.id == item.id }
                    }
                }
            }
        }
    }

    func updateItem(_ item: ItemModel) {
        // 1. 立即更新本地数据
        guard let index = allItems.firstIndex(where: { $0.id == item.id }) else { return }
        let oldItem = allItems[index]
        
        allItems[index] = item
        itemsById[item.id] = item
        
        // 更新分类索引
        if oldItem.categoryId != item.categoryId {
            itemsByCategory[oldItem.categoryId]?.removeAll { $0.id == item.id }
            itemsByCategory[item.categoryId, default: []].append(item)
        }
        
        // 更新一级位置索引
        if oldItem.primaryLocationId != item.primaryLocationId {
            if let oldPrimaryId = oldItem.primaryLocationId {
                itemsByPrimaryLocation[oldPrimaryId]?.removeAll { $0.id == item.id }
            }
            if let newPrimaryId = item.primaryLocationId {
                itemsByPrimaryLocation[newPrimaryId, default: []].append(item)
            }
        }
        
        // 更新二级位置索引
        if oldItem.secondaryLocationId != item.secondaryLocationId {
            if let oldSecondaryId = oldItem.secondaryLocationId {
                itemsBySecondaryLocation[oldSecondaryId]?.removeAll { $0.id == item.id }
            }
            if let newSecondaryId = item.secondaryLocationId {
                itemsBySecondaryLocation[newSecondaryId, default: []].append(item)
            }
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
        
        // 从位置索引中移除
        if let primaryId = item.primaryLocationId {
            itemsByPrimaryLocation[primaryId]?.removeAll { $0.id == id }
        }
        if let secondaryId = item.secondaryLocationId {
            itemsBySecondaryLocation[secondaryId]?.removeAll { $0.id == id }
        }
        
        // 2. 异步调用 API 删除
        ItemDataService.shared.deleteItem(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ API删除成功: \(id)")
                case .failure(let error):
                    print("❌ API删除失败: \(error)")
                    // 如果 API 删除失败，需要回滚本地数据
                    self.loadData()
                }
            }
        }
    }
    
    // MARK: - 统计方法
    func getLocationStatistics() -> [(location: PrimaryLocationModel, count: Int)] {
        var stats: [String: Int] = [:]
        
        for item in allItems {
            if let locationId = item.primaryLocationId {
                stats[locationId, default: 0] += 1
            }
        }
        
        return primaryLocations.compactMap { location in
            let count = stats[location.id] ?? 0
            return (location, count)
        }.filter { $0.count > 0 }
    }
}
