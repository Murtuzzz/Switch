//
//  R.swift
//  MindBeats
//
//  Created by Мурат Кудухов on 17.06.2023.
//

import UIKit

enum R {
    enum Colors {
        static let purple = UIColor(hexString: "#5f27cd")
        static let green = UIColor(hexString: "#1dd1a1")
        static let blue = UIColor(hexString: "#54a0ff")
        static let pink = UIColor(hexString: "#f368e0")
        static let orange = UIColor(hexString: "#ff9f43")
        static let red = UIColor(hexString: "#ee5253")
        static let light = UIColor(hexString: "#c8d6e5")
        
        static let purpleBg = UIColor(hexString: "#341f97")
        static let whiteBg = UIColor(hexString: "#f1f2f6")
        static let darkBg = UIColor(hexString: "#2f3542")
        static let breezeBg = UIColor(hexString: "#dff9fb")
        static let iceBg = UIColor(hexString: "#c7ecee")
        
    }
    enum Images {
        static let moon = UIImage(named: "moon")
        static let music = UIImage(named: "music")
        static let profile = UIImage(named: "profile")
        static let allButton = UIImage(named: "dots")
        static let ambient = UIImage(named: "ambient")
        static let kids = UIImage(named: "kids")
        static let lock = UIImage(named: "lock")
        static let star = UIImage(named: "star")
        
    }
    
    enum Fonts {
        static func Italic(with size: CGFloat) -> UIFont {
            UIFont(name: "GillSans-SemiBoldItalic", size: size) ?? UIFont()
            
            
        }
        static func nonItalic(with size: CGFloat) -> UIFont {
            UIFont(name: "GillSans-SemiBold", size: size) ?? UIFont()
        }
        
        static func avenir(with size: CGFloat) -> UIFont {
            UIFont(name: "AvenirNext-Medium", size: size) ?? UIFont()
        }
        
        static func avenirItalic(with size: CGFloat) -> UIFont {
            UIFont(name: "AvenirNext-MediumItalic", size: size) ?? UIFont()
        }
        
        static func avenirBook(with size: CGFloat) -> UIFont {
            UIFont(name: "Avenir-Book", size: size) ?? UIFont()
        }
    }
}
