//
//  Extensions.swift
//  ItemManage
//
//  Created by xiny on 2025/12/13.
//
import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIView{
    func applyCardStyle(){
        backgroundColor = AppStyle.Color.card
        layer.cornerRadius = AppStyle.Size.cornerCard
        layer.masksToBounds = true
    }//?直接做成components
}

extension UILabel{
    func applyStyle(_ style:UIFont,color:UIColor = AppStyle.Color.textRegular){
        self.font = style
        self.textColor = color
    }
}
