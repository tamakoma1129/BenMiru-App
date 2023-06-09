//
//  StackedBarChart.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/06/09.
//

import SwiftUI
import RealmSwift
import Charts

struct StackedBarChartView: View {
    @State var selectedDate: Date?   //ユーザーのタップしたところを保存する変数selectedDateをStateで宣言
    @ObservedObject private var viewModel = ViewModelStudy()    //グラフ用にデータを加工かつ、データを同期する処理をするStructからデータを引っ張ってくる
    @EnvironmentObject var genreColorMap: GenreColorMap //IDと色を同期させた辞書を作っているClass
    var body: some View {
        VStack{
            //グラフ使う時はChartで囲う
            Chart {
                ForEach(viewModel.studyByDayAndGenre.keys.sorted(), id: \.self) { date in
                    ForEach(viewModel.studyByDayAndGenre[date]!.keys.sorted(), id: \.self) { genreId in
                        let minutes = (viewModel.studyByDayAndGenre[date]![genreId] ?? 0)
                        BarMark(x: .value("日", date),
                                y: .value("分", minutes))
                        .foregroundStyle(Color(genreColorMap.colorMap[genreId] ?? UIColor(.red)))
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    findElement(location: value.location, proxy: proxy, geometry: geo)
                                }
                                .exclusively(
                                    before: DragGesture()
                                        .onChanged { value in
                                            findElement(location: value.location, proxy: proxy, geometry: geo)
                                        }
                                )
                        )
                }
            }
            .frame(height: 200)  // グラフの高さ
            .padding()
            // 選択された日付の各グラフ棒の情報を表示するビュー
            if let selectedDate = selectedDate {
                VStack(alignment: .leading) {
                    let sumDurationTime:Int = viewModel.studyByDayAndGenre[selectedDate]?.values.reduce(0, +) ?? 0   //選んだ日付の合計勉強時間をreduce関数で求める
                    Text("日付: \(dateConv(beforeDate: selectedDate))")
                    Text("合計\(sumDurationTime)分")
                    ScrollView{
                        ForEach(viewModel.studyByDayAndGenre[selectedDate]?.keys.sorted().reversed() ?? [], id: \.self) { genreId in
                            let durationTime:Int =  (viewModel.studyByDayAndGenre[selectedDate]![genreId] ?? 0)
                            GeometryReader { geometry in
                            HStack{
                                Text("\(genreColorMap.nameMap[genreId] ?? "エラーです　「記録する」からデータを削除してください。")" )
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(durationTime, format: .number) 分")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                            }
                            .padding()
                                    .overlay(
                                        HStack{
                                            Divider()
                                                .frame(width: geometry.size.width * (CGFloat(durationTime) / CGFloat(sumDurationTime)), height: 6)
                                                .background(Color(genreColorMap.colorMap[genreId] ?? UIColor(.red)))
                                        Spacer()
                                        }, alignment: .bottom
                                    )
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var closestDate: Date? = nil
            for dateKey in viewModel.studyByDayAndGenre.keys {
                let nthDataDistance = dateKey.distance(to: date)
                if abs(nthDataDistance) < minDistance {
                    minDistance = abs(nthDataDistance)
                    closestDate = dateKey
                }
            }
            selectedDate = closestDate
        }
    }
    
    private func dateConv(beforeDate:Date) -> (String) {
        let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let dateTokyo = formatter.string(from: beforeDate)
        return dateTokyo
    }
}

