//
//  String+.swift
//  FebruaryWeather
//
//  Created by a on 2026/2/4.
//

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// string四舍五入取整的版本。例如：“26.5”→“27”
    var roundedIntegerPartString: String? {
        guard let doubleValue = Double(self) else {
            return nil
        }
        // rounded()四舍五入后转Int，再转回String
        return String(Int(doubleValue.rounded()))
    }
    
}
