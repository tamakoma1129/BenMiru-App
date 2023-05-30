//
//  FigureModel.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/28.
//

import Foundation
import SwiftUI

//他から引っ張って来やすくするために、汎用性の高そうなものをここに置く

//色を指定すれば斜線ブロックを引いてくれる
struct EasyBlockModel: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let step = rect.width / 7.0
        
        for i in 0..<15 {
            let x = rect.width * CGFloat(i-1) / 7
            path.move(to: CGPoint(x: x + 10, y: -10))
            path.addLine(to: CGPoint(x: -10, y: x + 10))
        }
        
        return path
    }
}
