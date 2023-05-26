//
//  UIColor+Extensions.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/26.
//

import UIKit

//UIColorの機能を増やす
extension UIColor {
    var rgba: (red: Float, green: Float, blue: Float, alpha: Float)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (Float(red), Float(green), Float(blue), Float(alpha))
        } else {
            // RGBAじゃなかったらnil返す
            return nil
        }
    }
}
