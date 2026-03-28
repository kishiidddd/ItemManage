//
//  ItemDataService.swift
//  ItemManage
//

import Foundation

/// 从 ItemsManagementServer 拉取的完整快照（写入 `ItemRepository`）
struct RepositorySnapshot {
    let items: [ItemModel]
    let categories: [CategoryModel]
    let units: [UnitModel]
    let primaryLocations: [PrimaryLocationModel]
    let secondaryLocations: [SecondaryLocationModel]
}

class ItemDataService {
    
    static let shared = ItemDataService()
    
    private init() {
        print("✅ ItemDataService initialized (Backend: \(ServerConfiguration.apiBaseURLString))")
    }
    
    // MARK: - 全量加载（供 ItemRepository）
    
    func loadFullSnapshot(completion: @escaping (Result<RepositorySnapshot, Error>) -> Void) {
        let group = DispatchGroup()
        var categories: [CategoryModel] = []
        var units: [UnitModel] = []
        var primaries: [PrimaryLocationModel] = []
        var secondaries: [SecondaryLocationModel] = []
        var items: [ItemModel] = []
        var loadError: Error?
        let lock = NSLock()
        
        func fail(_ e: Error) {
            lock.lock()
            if loadError == nil { loadError = e }
            lock.unlock()
        }
        
        group.enter()
        fetchCategories { result in
            switch result {
            case .success(let c): categories = c
            case .failure(let e): fail(e)
            }
            group.leave()
        }
        
        group.enter()
        fetchUnits { result in
            switch result {
            case .success(let u): units = u
            case .failure(let e): fail(e)
            }
            group.leave()
        }
        
        group.enter()
        fetchPrimaryLocations { result in
            switch result {
            case .success(let p): primaries = p
            case .failure(let e): fail(e)
            }
            group.leave()
        }
        
        group.enter()
        fetchSecondaryLocations { result in
            switch result {
            case .success(let s): secondaries = s
            case .failure(let e): fail(e)
            }
            group.leave()
        }
        
        group.enter()
        fetchAllItemsPages { result in
            switch result {
            case .success(let i): items = i
            case .failure(let e): fail(e)
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let e = loadError {
                completion(.failure(e))
            } else {
                completion(.success(RepositorySnapshot(
                    items: items,
                    categories: categories,
                    units: units,
                    primaryLocations: primaries,
                    secondaryLocations: secondaries
                )))
            }
        }
    }
    
    private func fetchCategories(completion: @escaping (Result<[CategoryModel], Error>) -> Void) {
        ItemAPIClient.shared.perform(path: "categories", method: "GET") { result in
            switch result {
            case .failure(let e): completion(.failure(e))
            case .success(let json):
                guard let dict = json as? [String: Any], let data = dict["data"] else {
                    completion(.failure(ItemAPIError.decodeFailed))
                    return
                }
                completion(.success(ItemJSONMapper.array(CategoryModel.self, from: data)))
            }
        }
    }
    
    private func fetchUnits(completion: @escaping (Result<[UnitModel], Error>) -> Void) {
        ItemAPIClient.shared.perform(path: "units", method: "GET") { result in
            switch result {
            case .failure(let e): completion(.failure(e))
            case .success(let json):
                guard let dict = json as? [String: Any], let data = dict["data"] else {
                    completion(.failure(ItemAPIError.decodeFailed))
                    return
                }
                completion(.success(ItemJSONMapper.array(UnitModel.self, from: data)))
            }
        }
    }
    
    private func fetchPrimaryLocations(completion: @escaping (Result<[PrimaryLocationModel], Error>) -> Void) {
        ItemAPIClient.shared.perform(path: "primary-locations", method: "GET") { result in
            switch result {
            case .failure(let e): completion(.failure(e))
            case .success(let json):
                guard let dict = json as? [String: Any], let data = dict["data"] else {
                    completion(.failure(ItemAPIError.decodeFailed))
                    return
                }
                completion(.success(ItemJSONMapper.array(PrimaryLocationModel.self, from: data)))
            }
        }
    }
    
    private func fetchSecondaryLocations(completion: @escaping (Result<[SecondaryLocationModel], Error>) -> Void) {
        ItemAPIClient.shared.perform(path: "secondary-locations", method: "GET") { result in
            switch result {
            case .failure(let e): completion(.failure(e))
            case .success(let json):
                guard let dict = json as? [String: Any], let data = dict["data"] else {
                    completion(.failure(ItemAPIError.decodeFailed))
                    return
                }
                completion(.success(ItemJSONMapper.array(SecondaryLocationModel.self, from: data)))
            }
        }
    }
    
    private func fetchAllItemsPages(completion: @escaping (Result<[ItemModel], Error>) -> Void) {
        var acc: [ItemModel] = []
        func loadPage(_ page: Int) {
            getItems(page: page, limit: 100, categoryId: nil, primaryLocationId: nil, secondaryLocationId: nil, keyword: nil) { result in
                switch result {
                case .failure(let e):
                    completion(.failure(e))
                case .success(let resp):
                    acc.append(contentsOf: resp.items)
                    let pages = resp.pagination?.pages ?? 1
                    if page < pages {
                        loadPage(page + 1)
                    } else {
                        completion(.success(acc))
                    }
                }
            }
        }
        loadPage(1)
    }
    
    // MARK: - 分类管理
    func getCategories(completion: @escaping ([CategoryModel]) -> Void) {
        fetchCategories { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let c): completion(c)
                case .failure(let e):
                    print("❌ getCategories: \(e.localizedDescription)")
                    completion([])
                }
            }
        }
    }
    
    // MARK: - 单位管理
    func getUnits(completion: @escaping ([UnitModel]) -> Void) {
        fetchUnits { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let u): completion(u)
                case .failure(let e):
                    print("❌ getUnits: \(e.localizedDescription)")
                    completion([])
                }
            }
        }
    }
    
    // MARK: - 位置管理
    func getPrimaryLocations(completion: @escaping ([PrimaryLocationModel]) -> Void) {
        fetchPrimaryLocations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let p): completion(p)
                case .failure(let e):
                    print("❌ getPrimaryLocations: \(e.localizedDescription)")
                    completion([])
                }
            }
        }
    }
    
    func getSecondaryLocations(completion: @escaping ([SecondaryLocationModel]) -> Void) {
        fetchSecondaryLocations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let s): completion(s)
                case .failure(let e):
                    print("❌ getSecondaryLocations: \(e.localizedDescription)")
                    completion([])
                }
            }
        }
    }
    
    func getSecondaryLocations(for primaryLocationId: String, completion: @escaping ([SecondaryLocationModel]) -> Void) {
        let q = [URLQueryItem(name: "primaryLocationId", value: primaryLocationId)]
        ItemAPIClient.shared.perform(path: "secondary-locations", method: "GET", queryItems: q) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e):
                    print("❌ getSecondaryLocations(for:): \(e.localizedDescription)")
                    completion([])
                case .success(let json):
                    guard let dict = json as? [String: Any], let data = dict["data"] else {
                        completion([])
                        return
                    }
                    completion(ItemJSONMapper.array(SecondaryLocationModel.self, from: data))
                }
            }
        }
    }
    
    func createPrimaryLocation(_ location: PrimaryLocationModel, completion: @escaping (Result<PrimaryLocationModel, Error>) -> Void) {
        let body: [String: Any] = [
            "name": location.name,
            "icon": location.icon,
            "color": location.color,
            "sortOrder": location.sortOrder
        ]
        ItemAPIClient.shared.perform(path: "primary-locations", method: "POST", jsonBody: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success(let json):
                    guard let dict = json as? [String: Any], let data = dict["data"],
                          let model = ItemJSONMapper.object(PrimaryLocationModel.self, from: data) else {
                        completion(.failure(ItemAPIError.decodeFailed))
                        return
                    }
                    completion(.success(model))
                }
            }
        }
    }
    
    func updatePrimaryLocation(_ location: PrimaryLocationModel, completion: @escaping (Result<PrimaryLocationModel, Error>) -> Void) {
        let body: [String: Any] = [
            "name": location.name,
            "icon": location.icon,
            "color": location.color,
            "sortOrder": location.sortOrder
        ]
        let path = "primary-locations/\(location.id)"
        ItemAPIClient.shared.perform(path: path, method: "PUT", jsonBody: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success(let json):
                    guard let dict = json as? [String: Any], let data = dict["data"],
                          let model = ItemJSONMapper.object(PrimaryLocationModel.self, from: data) else {
                        completion(.failure(ItemAPIError.decodeFailed))
                        return
                    }
                    completion(.success(model))
                }
            }
        }
    }
    
    func deletePrimaryLocation(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        ItemAPIClient.shared.perform(path: "primary-locations/\(id)", method: "DELETE") { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success:
                    completion(.success(true))
                }
            }
        }
    }
    
    func createSecondaryLocation(_ location: SecondaryLocationModel, completion: @escaping (Result<SecondaryLocationModel, Error>) -> Void) {
        let body: [String: Any] = [
            "name": location.name,
            "primaryLocationId": location.primaryLocationId,
            "icon": location.icon,
            "color": location.color,
            "sortOrder": location.sortOrder
        ]
        ItemAPIClient.shared.perform(path: "secondary-locations", method: "POST", jsonBody: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success(let json):
                    guard let dict = json as? [String: Any], let data = dict["data"],
                          let model = ItemJSONMapper.object(SecondaryLocationModel.self, from: data) else {
                        completion(.failure(ItemAPIError.decodeFailed))
                        return
                    }
                    completion(.success(model))
                }
            }
        }
    }
    
    func updateSecondaryLocation(_ location: SecondaryLocationModel, completion: @escaping (Result<SecondaryLocationModel, Error>) -> Void) {
        var body: [String: Any] = [
            "name": location.name,
            "icon": location.icon,
            "color": location.color,
            "sortOrder": location.sortOrder
        ]
        body["primaryLocationId"] = location.primaryLocationId
        ItemAPIClient.shared.perform(path: "secondary-locations/\(location.id)", method: "PUT", jsonBody: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success(let json):
                    guard let dict = json as? [String: Any], let data = dict["data"],
                          let model = ItemJSONMapper.object(SecondaryLocationModel.self, from: data) else {
                        completion(.failure(ItemAPIError.decodeFailed))
                        return
                    }
                    completion(.success(model))
                }
            }
        }
    }
    
    func deleteSecondaryLocation(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        ItemAPIClient.shared.perform(path: "secondary-locations/\(id)", method: "DELETE") { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success:
                    completion(.success(true))
                }
            }
        }
    }
    
    // MARK: - 物品管理
    func getItems(page: Int = 1,
                  limit: Int = 20,
                  categoryId: String? = nil,
                  primaryLocationId: String? = nil,
                  secondaryLocationId: String? = nil,
                  keyword: String? = nil,
                  completion: @escaping (Result<ItemsListResponse, Error>) -> Void) {
        var q: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(min(100, max(1, limit)))")
        ]
        if let categoryId = categoryId { q.append(URLQueryItem(name: "categoryId", value: categoryId)) }
        if let primaryLocationId = primaryLocationId { q.append(URLQueryItem(name: "primaryLocationId", value: primaryLocationId)) }
        if let secondaryLocationId = secondaryLocationId { q.append(URLQueryItem(name: "secondaryLocationId", value: secondaryLocationId)) }
        if let keyword = keyword, !keyword.isEmpty { q.append(URLQueryItem(name: "keyword", value: keyword)) }
        
        ItemAPIClient.shared.perform(path: "items", method: "GET", queryItems: q) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success(let json):
                    guard let dict = json as? [String: Any],
                          let itemsArr = dict["items"] as? [[String: Any]] else {
                        completion(.failure(ItemAPIError.decodeFailed))
                        return
                    }
                    let items = itemsArr.compactMap { ItemModel.deserialize(from: $0) }
                    let resp = ItemsListResponse()
                    resp.items = items
                    if let p = dict["pagination"] as? [String: Any] {
                        let pag = PaginationModel()
                        pag.page = p["page"] as? Int ?? 1
                        pag.limit = p["limit"] as? Int ?? 20
                        pag.total = p["total"] as? Int ?? 0
                        pag.pages = p["pages"] as? Int ?? 1
                        pag.hasNextPage = p["hasNextPage"] as? Bool ?? false
                        resp.pagination = pag
                    }
                    completion(.success(resp))
                }
            }
        }
    }
    
    func createItem(_ item: CreateItemRequest,
                    completion: @escaping (Result<ItemModel, Error>) -> Void) {
        let validation = item.validateDates()
        if !validation.isValid {
            let error = NSError(domain: "ItemDataService",
                               code: 400,
                               userInfo: [NSLocalizedDescriptionKey: validation.message ?? "日期信息不完整"])
            completion(.failure(error))
            return
        }
        
        let body = item.toDictionary()
        
        ItemAPIClient.shared.perform(path: "items", method: "POST", jsonBody: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success(let json):
                    guard let dict = json as? [String: Any], let data = dict["data"],
                          let model = ItemJSONMapper.object(ItemModel.self, from: data) else {
                        completion(.failure(ItemAPIError.decodeFailed))
                        return
                    }
                    completion(.success(model))
                }
            }
        }
    }
    
    func updateItem(_ item: ItemModel,
                    completion: @escaping (Result<ItemModel, Error>) -> Void) {
        if let productionDate = item.productionDate, let shelfLife = item.shelfLife {
            let calculatedExpiry = Calendar.current.date(byAdding: .day, value: shelfLife, to: productionDate)
            if item.expiryDate != calculatedExpiry {
                item.expiryDate = calculatedExpiry
            }
        }
        
        let req = UpdateItemRequest(from: item)
        let body = req.toDictionary()
        
        ItemAPIClient.shared.perform(path: "items/\(item.id)", method: "PUT", jsonBody: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success(let json):
                    guard let dict = json as? [String: Any], let data = dict["data"],
                          let model = ItemJSONMapper.object(ItemModel.self, from: data) else {
                        completion(.failure(ItemAPIError.decodeFailed))
                        return
                    }
                    completion(.success(model))
                }
            }
        }
    }
    
    func deleteItem(id: String,
                    completion: @escaping (Result<Bool, Error>) -> Void) {
        ItemAPIClient.shared.perform(path: "items/\(id)", method: "DELETE") { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success:
                    completion(.success(true))
                }
            }
        }
    }
    
    func getItem(id: String, completion: @escaping (Result<ItemModel, Error>) -> Void) {
        ItemAPIClient.shared.perform(path: "items/\(id)", method: "GET") { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success(let json):
                    guard let dict = json as? [String: Any], let data = dict["data"],
                          let model = ItemJSONMapper.object(ItemModel.self, from: data) else {
                        completion(.failure(ItemAPIError.decodeFailed))
                        return
                    }
                    completion(.success(model))
                }
            }
        }
    }
}

// MARK: - 按过期日筛选（提醒页）
extension ItemDataService {
    
    /// 返回「选中日期」同一自然日过期的物品（按设备本地时区比较日历日）
    func getExpiredItems(for date: Date,
                         completion: @escaping (Result<[ItemModel], Error>) -> Void) {
        let calendar = Calendar.current
        fetchAllItemsPages { result in
            switch result {
            case .failure(let e): completion(.failure(e))
            case .success(let allItems):
                let items = allItems.filter { item in
                    guard let expiryDate = item.expiryDate else { return false }
                    return calendar.isDate(expiryDate, inSameDayAs: date)
                }
                completion(.success(items))
            }
        }
    }
}
