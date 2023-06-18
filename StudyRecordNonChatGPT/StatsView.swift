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
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
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
    
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd(E)" // 形式を設定
        return formatter.string(from: date)
    }
    @State private var selectedDateRange = DateRange.oneWeek
    @State private var customStartDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State private var customEndDate: Date = Date()
    var body: some View {
        let hoge = print("始まり:",customStartDate,"終わり:",customEndDate)
        GeometryReader{ geo in
            NavigationView{
                VStack{
                    HStack{
                        DatePicker("〜\(formatDate(date: customEndDate))までの\(selectedDateRange.rawValue)", selection: $customEndDate, displayedComponents: .date)
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
                    List{
                        Section{
                            NavigationLink(destination: PieSliceVariable(startDate: $customStartDate, endDate: $customEndDate,onInfo: true)) {
                                VStack{
                                    HStack{
                                        Text("円グラフ")
                                            .bold()
                                            .font(.system(size: geo.size.width/15))
                                            .foregroundColor(Color(UIColor(named:"Border")!))
                                        Spacer()
                                    }
                                    Divider()
                                    // startDateとendDateをPieSliceVariableに渡す
                                    PieSliceVariable(startDate: $customStartDate, endDate: $customEndDate, onInfo: false)
                                        .frame(height:geo.size.height*0.2)
                                }
                            }
                        }
                        Section{
                            NavigationLink(destination: StackedBarChartView(startDate: $customStartDate, endDate: $customEndDate,chartOn: true)) {
                                VStack{
                                    HStack{
                                        Text("積み上げ棒グラフ")
                                            .bold()
                                            .font(.system(size: geo.size.width/15))
                                            .foregroundColor(Color(UIColor(named:"Border")!))
                                        Spacer()
                                    }
                                    Divider()
                                    // startDateとendDateをPieSliceVariableに渡す
                                    StackedBarChartView(startDate: $customStartDate, endDate: $customEndDate,chartOn:false)
                                        .frame(height:geo.size.height*0.2)
                                }
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

