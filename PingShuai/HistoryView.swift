import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: HistoryStore
    private let cal = Calendar.current

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        stat("連續打卡", "\(store.streak) 天")
                        stat("練功天數", "\(store.practicedDays.count) 天")
                        stat("累計", "\(store.totalMinutes) 分")
                    }
                }
                Section("最近 28 天") { heatmap }
                Section("紀錄") {
                    ForEach(store.records) { r in
                        HStack {
                            Text(r.date, format: .dateTime.year().month().day().hour().minute())
                            Spacer()
                            Text("\(r.seconds / 60) 分 \(r.seconds % 60) 秒（\(r.preset) 分鐘組）")
                                .font(.footnote).foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: store.delete)
                }
            }
            .navigationTitle("練功日誌")
        }
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack {
            Text(value).font(.title3.bold())
            Text(title).font(.caption).foregroundColor(.secondary)
        }.frame(maxWidth: .infinity)
    }

    private var heatmap: some View {
        let today = cal.startOfDay(for: Date())
        let days = (0..<28).reversed().map { cal.date(byAdding: .day, value: -$0, to: today)! }
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
            ForEach(days, id: \.self) { d in
                let done = store.practicedDays.contains(d)
                RoundedRectangle(cornerRadius: 6)
                    .fill(done ? Color.green : Color.gray.opacity(0.2))
                    .frame(height: 28)
                    .overlay(Text("\(cal.component(.day, from: d))")
                        .font(.caption2)
                        .foregroundColor(done ? .white : .secondary))
            }
        }.padding(.vertical, 4)
    }
}
