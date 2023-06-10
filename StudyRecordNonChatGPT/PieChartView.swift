//
//  PieChartView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/06/10.
//

import SwiftUI

//円グラフを表示する
//Angleはラジアンで、ラジアンは約57.296度であり、360度は約6.28319ラジアンに相当。度なら.degree

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    // Shapeプロトコルの実装部分です。指定された矩形(rect)内にパスを描画します。
    func path(in rect: CGRect) -> Path {
        // 円グラフの中心点を計算します。
        let center = CGPoint(x: rect.midX, y: rect.midY)
        // 半径は、矩形の幅と高さのうち小さい方の半分とします。
        let radius = min(rect.width, rect.height) / 2
        // 円弧が始まる点（開始角度）を計算します。
        let start = CGPoint(
            x: center.x + radius * cos(CGFloat(startAngle.radians)),
            y: center.y + radius * sin(CGFloat(startAngle.radians))
        )
        
        // Pathオブジェクトを生成します。
        var path = Path()
        // パスを中心点に移動します。
        path.move(to: center)
        // 中心から円弧の開始点まで直線を引きます。
        path.addLine(to: start)
        // 開始角度から終了角度までの円弧を描きます。
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        // 円弧の終了点から中心点へ線を引いてパスを閉じます。
        path.closeSubpath()
        
        // 作成したパスを返します。
        return path
    }
}

struct PieChartView: View {
    @ObservedObject private var viewModel = ViewModelStudy()    //既にstartAngleとendAngleを計算済みの配列を取得。（ForEach内で計算すると原因不明のreportBugになる。）
    @EnvironmentObject var genreColorMap: GenreColorMap //色を反映させるための

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(viewModel.totalStudyTimeByGenre, id: \.genreId) { data in
                    PieSlice(startAngle: data.startAngle, endAngle: data.endAngle)
                        .fill(Color(genreColorMap.colorMap[data.genreId]!))
                }
                .frame(width: geometry.size.width*0.8)
            }
            .padding()
        }
    }
}
