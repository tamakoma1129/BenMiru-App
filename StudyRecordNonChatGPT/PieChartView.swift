//
//  PieChartView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/06/10.
//

import SwiftUI

//円グラフを表示する
//Angleはラジアンで、ラジアンは約57.296度であり、360度は約6.28319ラジアンに相当。度なら.degree

struct PieSliceVariable:View{
    @ObservedObject private var viewModel = ViewModelStudy()
    @EnvironmentObject var genreColorMap: GenreColorMap
    
    @Binding var startDate: Date
    @Binding var endDate: Date

    var body: some View {
        VStack {
           // PieChartDataをPieSliceDataに変換
            let pieSliceData = convertToPieSliceData(pieChartData: convertToPieChartData(studyData: viewModel.studyByDayAndGenre,startDate: startDate, endDate: endDate))
            if pieSliceData.isEmpty{
                Text("この期間のデータはありません><")
            }
            else{
                // PieSliceDataを使って円グラフを描画
                ZStack {
                    ForEach(pieSliceData, id: \.genreID) { data in
                        PieSlice(startAngle: data.startAngle, endAngle: data.endAngle)
                            .fill(Color(genreColorMap.colorMap[data.genreID] ?? UIColor(.red))) // ランダムな色を使用。実際にはジャンルに基づいた色を使用することを推奨します。
                    }
                }
            }
        }
        .padding()
    }
}

struct StudyData {
    var date: Date
    var genreID: String
    var studyTime: Int
}
struct PieChartData {
    var genreID: String
    var studyTime: Int
}
//データを期間に絞ってくれる
func convertToPieChartData(studyData: [Date: [String: Int]], startDate: Date, endDate: Date) -> [PieChartData] {
    var result = [PieChartData]()
    
    // 日付範囲内のデータを取得
    let filteredData = studyData.filter { $0.key >= startDate && $0.key <= endDate }
    
    // 各ジャンルの勉強時間を合計
    var totalStudyTimeByGenre = [String: Int]()
    for (_, studyTimes) in filteredData {
        for (genreID, studyTime) in studyTimes {
            totalStudyTimeByGenre[genreID, default: 0] += studyTime
        }
    }
    
    // 各ジャンルの勉強時間をPieChartDataに変換
    let sortedStudyTimeByGenre = totalStudyTimeByGenre.sorted(by: { $0.key < $1.key }) // genreIDでソート
    for (genreID, studyTime) in sortedStudyTimeByGenre {
        result.append(PieChartData(genreID: genreID, studyTime: studyTime))
    }
    
    return result
}


struct PieSliceData {
    var genreID: String
    var startAngle: Angle
    var endAngle: Angle
}

func convertToPieSliceData(pieChartData: [PieChartData]) -> [PieSliceData] {
    // すべての勉強時間の合計を求めます。
    let totalStudyTime = pieChartData.reduce(0) { $0 + $1.studyTime }
    
    // 各ジャンルの時間が全体の何パーセントに該当するかを計算し、そのパーセントを角度に変換します。
    var startAngle = Angle(degrees: 0)
    var pieSliceData: [PieSliceData] = []
    for data in pieChartData {
        let proportion = Double(data.studyTime) / Double(totalStudyTime)
        let angle = Angle(degrees: 360 * proportion)
        let endAngle = startAngle + angle
        pieSliceData.append(PieSliceData(genreID: data.genreID, startAngle: startAngle, endAngle: endAngle))
        startAngle = endAngle
    }
    
    return pieSliceData
}



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
struct PieChartView: View{
    var body: some View {
        VStack{
            //PieSliceVariable()
            
        }
    }
}
struct PieChartVieww: View {
    @ObservedObject private var viewModel = ViewModelStudy()
    @EnvironmentObject var genreColorMap: GenreColorMap

    private func timeInHoursAndMinutes(_ minutes: Int) -> (hours: Int, minutes: Int) {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return (hours, remainingMinutes)
    }

    var body: some View {
        let totalMinutes = viewModel.totalStudyTimeByGenre.reduce(0, { $0 + $1.studyTime })
        let (totalHours, remainingMinutes) = timeInHoursAndMinutes(totalMinutes)
        VStack {
            // 合計勉強時間を表示
            Text("合計勉強時間 \(totalHours) 時間 \(remainingMinutes) 分")
            
            // グラフを表示
            GeometryReader { geometry in
                ZStack {
                    ForEach(viewModel.totalStudyTimeByGenre.sorted(by: { $0.studyTime > $1.studyTime }), id: \.genreId) { data in
                        PieSlice(startAngle: data.startAngle, endAngle: data.endAngle)
                            .fill(Color(genreColorMap.colorMap[data.genreId]!))
                    }
                    .frame(width: geometry.size.width*0.8)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // 各要素の時間を表示
            ScrollView{
                ForEach(viewModel.totalStudyTimeByGenre.sorted(by: { $0.studyTime > $1.studyTime }), id: \.genreId) { data in
                    let (hours, minutes) = timeInHoursAndMinutes(data.studyTime)
                    GeometryReader { geometry in
                        HStack{
                            Text("\(genreColorMap.nameMap[data.genreId] ?? "エラーです　「記録する」からデータを削除してください。")")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(hours) 時間 \(minutes) 分")
                                .font(Font(UIFont.monospacedDigitSystemFont(ofSize: geometry.size.width/20, weight: .bold)))
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .overlay(
                            HStack{
                                Divider()
                                    .frame(width: geometry.size.width * (CGFloat(data.studyTime) / CGFloat(totalMinutes)), height: 6)
                                    .background(Color(genreColorMap.colorMap[data.genreId] ?? UIColor(.red)))
                                Spacer()
                            }.padding(.horizontal), alignment: .bottom
                        )
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}
