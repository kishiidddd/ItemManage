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
