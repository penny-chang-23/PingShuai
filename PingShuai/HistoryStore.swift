import Foundation

struct SessionRecord: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var seconds: Int
    var preset: Int // 計時器設定（分鐘）
}

final class HistoryStore: ObservableObject {
    @Published private(set) var records: [SessionRecord] = []
    private let url = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("history.json")
    private var cal: Calendar { .current }

    init() {
        if let data = try? Data(contentsOf: url),
           let r = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            records = r
        }
    }

    func add(seconds: Int, preset: Int) {
        guard seconds >= 30 else { return } // 少於 30 秒不計
        records.insert(SessionRecord(date: Date(), seconds: seconds, preset: preset), at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        save()
    }

    private func save() {
        try? JSONEncoder().encode(records).write(to: url, options: .atomic)
    }

    // MARK: 打卡統計

    var practicedToday: Bool { records.contains { cal.isDateInToday($0.date) } }

    var practicedDays: Set<Date> { Set(records.map { cal.startOfDay(for: $0.date) }) }

    /// 連續打卡天數（今天尚未練則從昨天起算）
    var streak: Int {
        let days = practicedDays
        var d = cal.startOfDay(for: Date())
        if !days.contains(d) { d = cal.date(byAdding: .day, value: -1, to: d)! }
        var n = 0
        while days.contains(d) {
            n += 1
            d = cal.date(byAdding: .day, value: -1, to: d)!
        }
        return n
    }

    var totalMinutes: Int { records.reduce(0) { $0 + $1.seconds } / 60 }
}
