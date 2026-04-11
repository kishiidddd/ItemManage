//
//  LocationManagementViewModel.swift
//  ItemManage
//

import Foundation
import Combine

/// 位置管理：一级 / 二级位置列表、选中态与增删改（数据来自 `ItemRepository`）
final class LocationManagementViewModel: ObservableObject {

    @Published private(set) var primaryLocations: [PrimaryLocationModel] = []
    @Published private(set) var secondaryLocations: [SecondaryLocationModel] = []
    @Published var selectedPrimaryLocationId: String?

    /// 轻提示文案（由 View 弹出后 `clearInfoMessage()`）
    @Published var infoMessage: String?

    private let repository = ItemRepository.shared

    func clearInfoMessage() {
        infoMessage = nil
    }

    func load() {
        primaryLocations = repository.getPrimaryLocations()
        if let first = primaryLocations.first {
            selectedPrimaryLocationId = first.id
        } else {
            selectedPrimaryLocationId = nil
        }
        reloadSecondaries()
    }

    func selectPrimary(at index: Int) {
        guard primaryLocations.indices.contains(index) else { return }
        selectedPrimaryLocationId = primaryLocations[index].id
        reloadSecondaries()
    }

    func addPrimaryLocation(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let draft = PrimaryLocationModel()
        draft.name = trimmed
        draft.icon = "📍"
        draft.color = "#2196F3"
        draft.sortOrder = primaryLocations.count

        repository.addPrimaryLocation(draft) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let saved):
                self.primaryLocations = self.repository.getPrimaryLocations()
                if self.selectedPrimaryLocationId == nil {
                    self.selectedPrimaryLocationId = saved.id
                }
                self.reloadSecondaries()
            case .failure(let error):
                self.infoMessage = error.localizedDescription
            }
        }
    }

    func addSecondaryLocation(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let primaryId = selectedPrimaryLocationId else {
            infoMessage = "请先选择一级位置"
            return
        }
        guard primaryLocations.contains(where: { $0.id == primaryId }) else {
            infoMessage = "请先选择一级位置"
            return
        }

        let draft = SecondaryLocationModel()
        draft.name = trimmed
        draft.primaryLocationId = primaryId
        draft.icon = "📦"
        draft.color = "#4CAF50"
        draft.sortOrder = secondaryLocations.count

        repository.addSecondaryLocation(draft) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.primaryLocations = self.repository.getPrimaryLocations()
                self.reloadSecondaries()
            case .failure(let error):
                self.infoMessage = error.localizedDescription
            }
        }
    }

    func editPrimaryLocation(at index: Int, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard primaryLocations.indices.contains(index) else { return }

        let location = primaryLocations[index]
        location.name = trimmed
        repository.updatePrimaryLocation(location)
        primaryLocations = repository.getPrimaryLocations()

        if selectedPrimaryLocationId == location.id {
            reloadSecondaries()
        }
    }

    func editSecondaryLocation(at index: Int, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard secondaryLocations.indices.contains(index) else { return }

        let location = secondaryLocations[index]
        location.name = trimmed
        repository.updateSecondaryLocation(location)
        reloadSecondaries()
    }

    func deletePrimaryBlockedReason(at index: Int) -> String? {
        guard primaryLocations.indices.contains(index) else { return nil }
        let location = primaryLocations[index]
        let itemsInLocation = repository.getItems(byPrimaryLocationId: location.id)
        if !itemsInLocation.isEmpty {
            return "无法删除，有 \(itemsInLocation.count) 个物品使用此位置"
        }
        return nil
    }

    func deleteSecondaryBlockedReason(at index: Int) -> String? {
        guard secondaryLocations.indices.contains(index) else { return nil }
        let location = secondaryLocations[index]
        let itemsInLocation = repository.getItems(bySecondaryLocationId: location.id)
        if !itemsInLocation.isEmpty {
            return "无法删除，有 \(itemsInLocation.count) 个物品使用此位置"
        }
        return nil
    }

    func deletePrimary(at index: Int) {
        guard primaryLocations.indices.contains(index) else { return }
        let location = primaryLocations[index]
        repository.deletePrimaryLocation(id: location.id)
        primaryLocations = repository.getPrimaryLocations()

        if selectedPrimaryLocationId == location.id {
            selectedPrimaryLocationId = primaryLocations.first?.id
        }
        reloadSecondaries()
    }

    func deleteSecondary(at index: Int) {
        guard secondaryLocations.indices.contains(index) else { return }
        let location = secondaryLocations[index]
        repository.deleteSecondaryLocation(id: location.id)
        reloadSecondaries()
    }

    var shouldShowEmptyLabel: Bool {
        !(selectedPrimaryLocationId != nil && !secondaryLocations.isEmpty)
    }

    var shouldHideRightTable: Bool {
        selectedPrimaryLocationId == nil && secondaryLocations.isEmpty
    }

    private func reloadSecondaries() {
        guard let id = selectedPrimaryLocationId else {
            secondaryLocations = []
            return
        }
        secondaryLocations = repository.getSecondaryLocations(for: id)
    }
}
