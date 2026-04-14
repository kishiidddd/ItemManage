import Foundation
import HandyJSON

// MARK: - 主物品模型
class ItemModel: HandyJSON {
    var id: String = ""
    var name: String = ""
    var categoryId: String = ""
    var quantity: Int = 1
    var unitId: String?
    var photos: [PhotoModel] = []
    
    // 位置相关字段
    var primaryLocationId: String?      // 一级位置ID
    var secondaryLocationId: String?    // 二级位置ID
    
    // 日期相关字段
    var productionDate: Date?           // 生产日期
    var expiryDate: Date?               // 过期日期
    var shelfLife: Int?                 // 保质期（天数）
    
    var reminder: ReminderSettingModel = ReminderSettingModel()
    var remarks: String?
    var status: String = "normal"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // 关联对象（用于UI展示）
    var category: CategoryModel?
    var unit: UnitModel?
    var primaryLocation: PrimaryLocationModel?      // 一级位置对象
    var secondaryLocation: SecondaryLocationModel?  // 二级位置对象
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.id <-- "_id"
        
        // 处理位置映射
        mapper <<< self.primaryLocationId <-- "primaryLocationId"
        mapper <<< self.secondaryLocationId <-- "secondaryLocationId"
        
        // 日期：服务端为 ISO8601 字符串（含 .sssZ）或毫秒时间戳；HandyJSON 默认无法解析 ISO 字符串
        mapper <<< self.productionDate <-- BackendDateTransform()
        mapper <<< self.expiryDate <-- BackendDateTransform()
        mapper <<< self.createdAt <-- BackendRequiredDateTransform()
        mapper <<< self.updatedAt <-- BackendRequiredDateTransform()
    }
    
    // MARK: - 计算属性
    
    // 价格字段已移除（totalPrice）
    
    // 计算属性：是否过期
    var isExpired: Bool {
        guard let expiryDate = expiryDate else { return false }
        return expiryDate < Date()
    }
    
    // 计算属性：剩余天数（负数表示已过期）
    var daysUntilExpiry: Int? {
        guard let expiryDate = expiryDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expiryDate)
        return components.day
    }
    
    // 计算属性：是否即将过期（3天内）
    var isExpiringSoon: Bool {
        guard let days = daysUntilExpiry else { return false }
        return days >= 0 && days <= 3
    }
    
    // 计算属性：过期状态描述
    var expiryStatusDescription: String {
        guard let days = daysUntilExpiry else {
            return "无过期时间"
        }
        
        if days < 0 {
            return "已过期\(-days)天"
        } else if days == 0 {
            return "今天过期"
        } else if days <= 3 {
            return "\(days)天后过期（即将过期）"
        } else {
            return "\(days)天后过期"
        }
    }
    
    // 计算属性：过期状态颜色
    var expiryStatusColor: String {
        guard let days = daysUntilExpiry else {
            return "#999999"  // 灰色
        }
        
        if days < 0 {
            return "#FF6B6B"  // 红色
        } else if days <= 3 {
            return "#FFB347"  // 橙色
        } else {
            return "#4CAF50"  // 绿色
        }
    }
    
    // displayPrice 已移除
    
    // 计算属性：显示单位
    var displayUnit: String {
        if let unit = unit {
            return unit.name
        }
        return "个"
    }
    
    // 计算属性：显示位置
    var displayLocation: String {
        if let primaryLocation = primaryLocation {
            if let secondaryLocation = secondaryLocation {
                return "\(primaryLocation.name) > \(secondaryLocation.name)"
            }
            return primaryLocation.name
        }
        return "未设置位置"
    }
    
    // 计算属性：是否有位置信息
    var hasLocation: Bool {
        return primaryLocationId != nil && !(primaryLocationId?.isEmpty ?? true)
    }
    
    // MARK: - 日期处理方法
    
    /// 根据生产日期和保质期计算过期日期
    func calculateExpiryDate() {
        guard let productionDate = productionDate,
              let shelfLife = shelfLife,
              shelfLife > 0 else {
            return
        }
        expiryDate = Calendar.current.date(byAdding: .day, value: shelfLife, to: productionDate)
    }
    
    /// 更新保质期时自动重新计算过期日期
    func updateShelfLife(_ days: Int) {
        shelfLife = days
        calculateExpiryDate()
    }
    
    /// 更新生产日期时自动重新计算过期日期
    func updateProductionDate(_ date: Date) {
        productionDate = date
        calculateExpiryDate()
    }
    
    /// 更新过期日期（如果用户直接修改了过期日期）
    func updateExpiryDate(_ date: Date) {
        expiryDate = date
        // 注意：如果用户直接修改了过期日期，生产日期和保质期的关联会被打破
        // 我们可以选择不清空它们，但需要标记这是一个直接设置的过期日期
    }
    
    /// 检查日期信息完整性
    func validateDates() -> DateValidationResult {
        if let expiryDate = expiryDate {
            // 用户直接填了过期日期
            return .hasExpiryDate(expiryDate)
        } else if let productionDate = productionDate, let shelfLife = shelfLife {
            // 用户填了生产日期和保质期，自动计算
            let calculatedExpiry = Calendar.current.date(byAdding: .day, value: shelfLife, to: productionDate)
            return .calculated(productionDate: productionDate, shelfLife: shelfLife, expiryDate: calculatedExpiry)
        } else if productionDate != nil || shelfLife != nil {
            // 只填了其中一个，数据不完整
            return .incomplete
        } else {
            // 都没有填写，无过期信息
            return .noExpiryInfo
        }
    }
    
    /// 智能更新日期信息
    func updateDateInfo(productionDate: Date? = nil, shelfLife: Int? = nil, expiryDate: Date? = nil) {
        // 优先使用直接填写的过期日期
        if let expiryDate = expiryDate {
            self.expiryDate = expiryDate
            // 如果用户同时提供了生产日期和保质期，也保存它们
            if let productionDate = productionDate {
                self.productionDate = productionDate
            }
            if let shelfLife = shelfLife {
                self.shelfLife = shelfLife
            }
        }
        // 如果没有过期日期，但有生产日期和保质期，则自动计算
        else if let productionDate = productionDate, let shelfLife = shelfLife {
            self.productionDate = productionDate
            self.shelfLife = shelfLife
            calculateExpiryDate()
        }
        // 只有生产日期或只有保质期，则保存但无法计算过期日期
        else {
            if let productionDate = productionDate {
                self.productionDate = productionDate
            }
            if let shelfLife = shelfLife {
                self.shelfLife = shelfLife
            }
        }
    }
    
    /// 获取格式化的生产日期字符串
    func formattedProductionDate(format: String = "yyyy-MM-dd") -> String {
        guard let productionDate = productionDate else { return "未设置" }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: productionDate)
    }
    
    /// 获取格式化的过期日期字符串
    func formattedExpiryDate(format: String = "yyyy-MM-dd") -> String {
        guard let expiryDate = expiryDate else { return "未设置" }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: expiryDate)
    }
    
    /// 获取保质期描述
    var shelfLifeDescription: String {
        guard let shelfLife = shelfLife else { return "未设置" }
        return "\(shelfLife)天"
    }
    
    /// 获取完整的日期信息描述
    var dateInfoDescription: String {
        let validation = validateDates()
        switch validation {
        case .hasExpiryDate(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "过期日期: \(formatter.string(from: date))"
        case .calculated(let productionDate, let shelfLife, let expiryDate):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            var description = "生产日期: \(formatter.string(from: productionDate)), 保质期: \(shelfLife)天"
            if let expiryDate = expiryDate {
                description += ", 过期日期: \(formatter.string(from: expiryDate))"
            }
            return description
        case .incomplete:
            return "日期信息不完整"
        case .noExpiryInfo:
            return "无过期信息"
        }
    }
    
    // MARK: - 位置处理方法
    
    /// 设置位置
    func setLocation(primaryLocationId: String? = nil, secondaryLocationId: String? = nil) {
        self.primaryLocationId = primaryLocationId
        self.secondaryLocationId = secondaryLocationId
    }
    
    /// 清除位置信息
    func clearLocation() {
        self.primaryLocationId = nil
        self.secondaryLocationId = nil
        self.primaryLocation = nil
        self.secondaryLocation = nil
    }
    
    /// 检查位置是否有效（二级位置属于一级位置）
    func isValidLocation(primaryLocationId: String, secondaryLocationId: String?, primaryLocations: [PrimaryLocationModel]) -> Bool {
        guard let primary = primaryLocations.first(where: { $0.id == primaryLocationId }) else {
            return false
        }
        
        if let secondaryId = secondaryLocationId {
            return primary.secondaryLocations?.contains(where: { $0.id == secondaryId }) ?? false
        }
        
        return true
    }
}

// MARK: - 日期验证结果枚举
enum DateValidationResult {
    case hasExpiryDate(Date)           // 直接有过期日期
    case calculated(productionDate: Date, shelfLife: Int, expiryDate: Date?) // 自动计算
    case incomplete                    // 数据不完整（只有生产日期或只有保质期）
    case noExpiryInfo                  // 无过期信息
}

// MARK: - 日期信息模型
class DateInfoModel: HandyJSON {
    var productionDate: Date?
    var expiryDate: Date?
    var shelfLife: Int?
    var hasExpiryInfo: Bool = false
    var isCalculated: Bool = false      // 是否是自动计算的
    
    required init() {}
    
    convenience init(productionDate: Date? = nil, expiryDate: Date? = nil, shelfLife: Int? = nil) {
        self.init()
        self.productionDate = productionDate
        self.expiryDate = expiryDate
        self.shelfLife = shelfLife
        self.hasExpiryInfo = expiryDate != nil || shelfLife != nil
    }
    
    // 验证日期信息是否完整
    func isValid() -> Bool {
        if expiryDate != nil {
            return true
        }
        if productionDate != nil && shelfLife != nil {
            return true
        }
        return false
    }
    
    // 获取显示文本
    func getDisplayText() -> String {
        if let expiryDate = expiryDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "过期: \(formatter.string(from: expiryDate))"
        }
        
        if let productionDate = productionDate, let shelfLife = shelfLife {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "生产: \(formatter.string(from: productionDate)), 保质: \(shelfLife)天"
        }
        
        if let productionDate = productionDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "生产: \(formatter.string(from: productionDate))"
        }
        
        if let shelfLife = shelfLife {
            return "保质: \(shelfLife)天"
        }
        
        return "无过期信息"
    }
}
