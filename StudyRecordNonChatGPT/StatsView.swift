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

/*
struct ChartTest: View {
    @State var selectedDate: Date?   //ユーザーのタップしたところを保存する変数selectedDateをStateで宣言
    
    var body: some View {
        VStack{
            //チャート使う時はChartで囲う
            Chart {
                            ForEach(studyTimeByDateAndGenre.keys.sorted(), id: \.self) { date in
                                ForEach(studyTimeByDateAndGenre[date]!.keys.sorted(), id: \.self) { genre in
                                    let studyTime = studyTimeByDateAndGenre[date]![genre]!
                                    BarMark(x: .value("Date", date),
                                            y: .value("Study Time", studyTime),
                                            color: .color(getColorForGenre(genre)))
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
            
        }
        .frame(height: 200)  // グラフの高さ
        .padding()
        // 選択された日付の各食事のカロリー摂取量を表示するビュー
        if let selectedDate = selectedDate {
            VStack(alignment: .leading) {
                Text("Date: \(selectedDate, format: .dateTime.year().month().day())")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text("Breakfast: \(findCalories(for: selectedDate, in: intakeBreakfast), format: .number) calories")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text("Lunch: \(findCalories(for: selectedDate, in: intakeLunch), format: .number) calories")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text("Dinner: \(findCalories(for: selectedDate, in: intakeDinner), format: .number) calories")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text("Snack: \(findCalories(for: selectedDate, in: intakeSnack), format: .number) calories")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
            }
            .padding()
        }
    }
    
    func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var closestDate: Date? = nil
            for dataIndex in intakeBreakfast.indices {
                let nthDataDistance = intakeBreakfast[dataIndex].date.distance(to: date)
                if abs(nthDataDistance) < minDistance {
                    minDistance = abs(nthDataDistance)
                    closestDate = intakeBreakfast[dataIndex].date
                }
            }
            selectedDate = closestDate
        }
    }
    
    func findCalories(for date: Date, in intake: [MealIntake]) -> Int {
        return intake.first(where: { $0.date == date })?.calories ?? 0
    }
}
*/
