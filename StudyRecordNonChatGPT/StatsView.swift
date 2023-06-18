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
        case oneWeek = "1週間"
        case oneMonth = "1ヶ月"
        case oneYear = "1年"
        case all = "全期間"
        
        var id: String { self.rawValue }
    }
    
    // 期間を計算
    func calculateDateRange(for range: DateRange, endDate: Date) -> (startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        var startDate: Date
        
        switch range {
        case .oneWeek:
            startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        case .oneMonth:
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate)!
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        case .oneYear:
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        case .all:
            // すべての期間をカバーするため、非常に過去の日付を使用します。
            startDate = calendar.date(byAdding: .year, value: -100, to: endDate)!
        }
        
        return (startDate, endDate)
    }
    
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP") // ロケールを日本に設定
        formatter.dateFormat = "yyyy/MM/dd(E)" // 形式を設定
        return formatter.string(from: date)
    }
    @State private var selectedDateRange = DateRange.oneWeek
    @State private var customStartDate: Date = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: Date())!
    @State private var customEndDate: Date = Calendar.current.date(byAdding: .hour, value: 9, to: Date())!
    
    
    var body: some View {
        GeometryReader{ geo in
            NavigationView{
                VStack{
                    HStack{
                        DatePicker("〜\(formatDate(date: customEndDate))の期間", selection: $customEndDate, displayedComponents: .date)
                            .padding()
                    }
                    // 日付範囲を選択するPickerを配置
                    Picker("Date Range", selection: $selectedDateRange) {
                        ForEach(DateRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedDateRange) { newValue in
                        // 新しい日付範囲が選択された時に customStartDate と customEndDate を更新する
                        let dateRange = calculateDateRange(for: newValue, endDate: customEndDate)
                        customStartDate = dateRange.startDate
                        customEndDate = dateRange.endDate
                    }
                    .onChange(of: customEndDate) { newValue in
                        // 新しい日付範囲が選択された時に customStartDate と customEndDate を更新する
                        let dateRange = calculateDateRange(for: selectedDateRange, endDate: newValue)
                        customStartDate = dateRange.startDate
                        customEndDate = dateRange.endDate
                    }
                    // 選択した日付範囲に基づいてstartDateとendDateを計算
                    let dateRange = calculateDateRange(for: selectedDateRange, endDate: customEndDate)
                    
                    Text("\(formatDate(date: dateRange.startDate))〜\(formatDate(date: dateRange.endDate))")
                    
                    List{
                        Section{
                            VStack{
                                HStack{
                                    Text("円グラフ")
                                        .bold()
                                        .font(.system(size: geo.size.width/15))
                                        .foregroundColor(Color(UIColor(named:"Border")!))
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
                            VStack{
                                HStack{
                                    Text("積み上げ棒グラフ")
                                        .bold()
                                        .font(.system(size: geo.size.width/15))
                                        .foregroundColor(Color(UIColor(named:"Border")!))
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
                                StackedBarChartView(startDate: $customStartDate, endDate: $customEndDate,chartOn:false)
                                    .frame(height:geo.size.height*0.5)
                            }
                        }
                    }
                    .navigationTitle("統計")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}



