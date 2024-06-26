//
//  UIColor+Extension.swift
//  FLO-RX
//
//  Created by 이상준 on 3/16/24.
//

import UIKit

extension UIColor {
    
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    class var mainTheme: UIColor {
        return UIColor(hex: 0x3D3AF5)
    }
}
