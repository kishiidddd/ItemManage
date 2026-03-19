//
//  Date+.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation

extension Date{
    
    func formatToString(_ format: String = "yyyy-MM-dd") -> String {
        if format.isEmpty {
            return ""
        }
        let ff = DateFormatter()
        ff.dateFormat = format
        ff.locale = Locale(identifier: "zh_CN")
        let text = ff.string(from: self)
        return text
    }
}
