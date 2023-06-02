//
//  StatsView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/25.
//

import SwiftUI
import RealmSwift
import Charts
//StatsViewのストラクト
struct StatsView: View {
    
    var body: some View {
        Text("StatsView")
    }
}


struct ChartTest: View {
    @State var selectedDate: Date?   //ユーザーのタップしたところを保存する変数selectedDateをStateで宣言
    @ObservedObject private var viewModel = ViewModelStudy()    //グラフ用にデータを加工かつ、データを同期する処理をするStructからデータを引っ張ってくる
    @EnvironmentObject var genreColorMap: GenreColorMap //IDと色を同期させた辞書を作っているClass
    var body: some View {
        VStack{
            //グラフ使う時はChartで囲う
            Chart {
                ForEach(viewModel.studyByDayAndGenre.keys.sorted(), id: \.self) { date in
                    ForEach(viewModel.studyByDayAndGenre[date]!.keys.sorted(), id: \.self) { genreId in
                        let minutes = viewModel.studyByDayAndGenre[date]![genreId]!
                        BarMark(x: .value("日", date),
                                y: .value("分", minutes))
                        .foregroundStyle(Color(genreColorMap.colorMap[genreId]!))
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
                    Text("Date: \(selectedDate, format: .dateTime.year().month().day())")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    ScrollView{
                        ForEach(viewModel.studyByDayAndGenre[selectedDate]?.keys.sorted().reversed() ?? [], id: \.self) { genreId in
                            HStack{
                                Text("\(genreColorMap.nameMap[genreId]!)" )
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(viewModel.studyByDayAndGenre[selectedDate]![genreId]!, format: .number) 分")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .overlay(
                                Divider().frame(height: 6).background(Color(genreColorMap.colorMap[genreId]!)), alignment: .bottom
                            )
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
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
}

