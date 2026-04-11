//
//  ItemRulesViewModel.swift
//  ItemManage
//

import Foundation
import Combine

/// 物品规则设置：分类与单位列表及增删（与 `ItemRepository` / 服务端同步）
final class ItemRulesViewModel: ObservableObject {

    @Published private(set) var categories: [CategoryModel] = []
    @Published private(set) var units: [UnitModel] = []
    @Published private(set) var isLoading = false

    /// 非 nil 时表示操作失败，由 View 弹出后调用 `clearError()`
    @Published var errorMessage: String?

    private let repository = ItemRepository.shared
    private let dataService = ItemDataService.shared

    func clearError() {
        errorMessage = nil
    }

    /// 从接口拉取分类与单位（进入页面时）
    func load() {
        isLoading = true
        let group = DispatchGroup()
        var fetchedUnits: [UnitModel] = []
        var fetchedCategories: [CategoryModel] = []

        group.enter()
        dataService.getUnits { list in
            fetchedUnits = list
            group.leave()
        }

        group.enter()
        dataService.getCategories { list in
            fetchedCategories = list
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.units = fetchedUnits
            self.categories = fetchedCategories
            self.isLoading = false
        }
    }

    func addUnit(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        repository.createUnit(name: trimmed) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.units = self.repository.units
                self.categories = self.repository.categories
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func addCategory(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        repository.createCategory(name: trimmed) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.categories = self.repository.categories
                self.units = self.repository.units
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    /// 仅本地删除（与服务端删除未对接时与原先行为一致）
    func deleteUnit(at index: Int) {
        guard units.indices.contains(index) else { return }
        units.remove(at: index)
    }

    func deleteCategory(at index: Int) {
        guard categories.indices.contains(index) else { return }
        categories.remove(at: index)
    }
}
