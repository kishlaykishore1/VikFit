//
//  UIColor.swift
//

import UIKit

extension UIColor {
    
    static let primaryColor = #colorLiteral(red: 0.0862745098, green: 0.1176470588, blue: 0.4196078431, alpha: 1)
}

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
}

extension UIColor {
    static func createGradientLayer(firstColor: UIColor, secondColor: UIColor)->  CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        
        //gradientLayer.frame = .view.bounds
        
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        
        return gradientLayer
    }
}




