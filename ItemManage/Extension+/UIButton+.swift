//
//  String+.swift
//  FebruaryWeather
//
//  Created by a on 2026/2/4.
//

import UIKit
import ObjectiveC
import SnapKit

private var hitTestEdgeInsetsKey: Void?

extension UIButton {
    
    var hitTestEdgeInsets: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &hitTestEdgeInsetsKey) as? UIEdgeInsets
        }
        set {
            objc_setAssociatedObject(self, &hitTestEdgeInsetsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let insets = hitTestEdgeInsets else {
            return super.point(inside: point, with: event)
        }
        
        let hitFrame = bounds.inset(by: insets)
        return hitFrame.contains(point)
    }
}

// button.hitTestEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)

//按钮放大缩小
extension UIButton {

    private static let pulseKey = "cx_pulse_scale"

    func startPulseScale(
        minScale: CGFloat = 0.95,
        maxScale: CGFloat = 1.05,
        duration: CFTimeInterval = 0.8
    ) {
        // 防止重复添加
        if layer.animation(forKey: Self.pulseKey) != nil {
            return
        }

        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = minScale
        animation.toValue = maxScale
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        layer.add(animation, forKey: Self.pulseKey)
    }

    func stopPulseScale() {
        layer.removeAnimation(forKey: Self.pulseKey)
    }
}

//按钮扫光特效
extension UIButton {
    func addShimmer() {
        let shimmer = CXShimmerView(jsonName: "btn_light")
        insertSubview(shimmer, at: 0)
        shimmer.snp.makeConstraints { $0.edges.equalToSuperview() }
        clipsToBounds = true
    }
}
