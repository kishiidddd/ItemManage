//
//  AppUtility.swift
//  ItemManage
//
//  Created by a on 2026/3/17.
//

import Foundation
import UIKit


// MARK: - 工具方法
/// 工具方法集合 - 使用 enum 作为命名空间，防止实例化
enum AppUtility {
    
    // MARK: - 触觉反馈
    /// 触发触觉反馈
    /// - Parameter style: 反馈样式，默认 .medium
    /// - Returns: 反馈生成器实例
    @discardableResult
    static func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> UIImpactFeedbackGenerator {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        return generator
    }
    
    
    // MARK: - 延迟执行
    /// 延迟执行代码块
    /// - Parameters:
    ///   - duration: 延迟时间（秒）
    ///   - block: 要执行的代码块
    static func delay(_ duration: TimeInterval, execute block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: block)
    }
    

}
