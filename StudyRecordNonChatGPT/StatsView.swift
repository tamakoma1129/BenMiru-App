//
//  StatsView.swift
//  StudyRecordNonChatGPT
//
//  Created by 立花達朗 on 2023/05/25.
//

import SwiftUI
//StatsViewのストラクト
struct StatsView: View {
    enum DateRange: String, CaseIterable, Identifiable {
        case oneDay = "1日"
        case oneWeek = "1週間"
        case oneMonth = "1ヶ月"
        case oneYear = "1年"
        case all = "全期間"
        case custom = "カスタム"
        
        var id: String { self.rawValue }
    }
    // 期間を計算
    func calculateDateRange(for range: DateRange) -> (startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        var startDate: Date
        let endDate: Date
        
        switch range {
        case .oneDay:
            startDate = calendar.startOfDay(for: Date())
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        case .oneWeek:
            startDate = calendar.date(byAdding: .weekOfMonth, value: -1, to: Date())!
            endDate = calendar.startOfDay(for: Date())
        case .oneMonth:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date())!
            endDate = calendar.startOfDay(for: Date())
        case .oneYear:
            startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
            endDate = calendar.startOfDay(for: Date())
        case .all:
            // すべての期間をカバーするため、非常に過去の日付を使用します。
            startDate = calendar.date(byAdding: .year, value: -100, to: Date())!
            endDate = calendar.startOfDay(for: Date())
        case .custom:
            // カスタムの場合、選択された日付をそのまま返します
            startDate = customStartDate
            endDate = customEndDate
        }
        
        return (startDate, endDate)
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP") // ロケールを日本に設定
        formatter.dateFormat = "yyyy/MM/dd(E)" // 形式を設定
        return formatter.string(from: date)
    }
    @State private var selectedDateRange = DateRange.oneDay
    @State private var customStartDate: Date = Date()
    @State private var customEndDate: Date = Date()
    
    
    var body: some View {
        GeometryReader{ geo in
            NavigationView{
                VStack{
                    // 日付範囲を選択するPickerを配置
                    Picker("Date Range", selection: $selectedDateRange) {
                        ForEach(DateRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedDateRange) { newValue in
                        // 新しい日付範囲が選択された時に customStartDate と customEndDate を更新する
                        let dateRange = calculateDateRange(for: newValue)
                        customStartDate = dateRange.startDate
                        customEndDate = dateRange.endDate
                    }
                    
                    // 選択した日付範囲に基づいてstartDateとendDateを計算
                    let dateRange = calculateDateRange(for: selectedDateRange)
                    
                    // カスタムの場合はDatePickerを表示
                    if selectedDateRange == .custom {
                        DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
                    }
                    
                    Text("\(formatDate(date: dateRange.startDate))〜\(formatDate(date: dateRange.endDate))")
                    List{
                        Section{
                            VStack{
                                HStack{
                                    Text("円グラフ(学習時間)")
                                        .bold()
                                        .font(.system(size: geo.size.width/15))
                                    Spacer()
                                    Button(action: {
                                        //ボタンアクション
                                    }) {
                                        HStack {
                                            Text("詳細")
                                                .foregroundColor(Color(UIColor(named:"Border")!))
                                        }
                                    }
                                }
                                Divider()
                                // startDateとendDateをPieSliceVariableに渡す
                                PieSliceVariable(startDate: $customStartDate, endDate: $customEndDate)
                                    .frame(height:geo.size.height*0.3)
                            }
                        }
                        Section{
                            Text("積み上げ棒グラフ")
                        }
                    }
                    .navigationTitle("統計")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}



