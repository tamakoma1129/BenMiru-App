//
//  StatsView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/25.
//

import SwiftUI
//StatsViewのストラクト
struct StatsView: View {
    @ObservedObject private var viewModel = ViewModelStudy()
    @EnvironmentObject var genreColorMap: GenreColorMap
    
    enum DateRange: String, CaseIterable, Identifiable {
        case oneDay = "1日"
        case oneWeek = "1週間"
        case oneMonth = "1ヶ月"
        case oneYear = "1年"
        case all = "全期間"

        var id: String { self.rawValue }
    }
    
    @State private var selectedDateRange = DateRange.oneDay
    
    var body: some View {
        VStack {
            // 日付範囲を選択するPickerを配置
            Picker("Date Range", selection: $selectedDateRange) {
                ForEach(DateRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // 選択した日付範囲に基づいてstartDateとendDateを計算
            let dateRange = calculateDateRange(for: selectedDateRange)
            
            // PieChartDataをPieSliceDataに変換
            let pieSliceData = convertToPieSliceData(pieChartData: convertToPieChartData(studyData: viewModel.studyByDayAndGenre,startDate: dateRange.startDate, endDate: dateRange.endDate))

            // PieSliceDataを使って円グラフを描画
            ZStack {
                ForEach(pieSliceData, id: \.genreID) { data in
                    PieSlice(startAngle: data.startAngle, endAngle: data.endAngle)
                        .fill(Color(genreColorMap.colorMap[data.genreID] ?? UIColor(.red))) // ランダムな色を使用。実際にはジャンルに基づいた色を使用することを推奨します。
                }
            }
        }
        .padding()
    }
    
    func calculateDateRange(for range: DateRange) -> (startDate: Date, endDate: Date) {
        let endDate = Date()
        let calendar = Calendar.current
        let startDate: Date

        switch range {
        case .oneDay:
            startDate = calendar.date(byAdding: .day, value: -1, to: endDate)!
        case .oneWeek:
            startDate = calendar.date(byAdding: .weekOfMonth, value: -1, to: endDate)!
        case .oneMonth:
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate)!
        case .oneYear:
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
        case .all:
            // すべての期間をカバーするため、非常に過去の日付を使用します。
            startDate = calendar.date(byAdding: .year, value: -100, to: endDate)!
        }
        
        return (startDate, endDate)
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




