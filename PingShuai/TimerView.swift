import SwiftUI

struct TimerView: View {
    @EnvironmentObject var engine: SwingEngine
    @EnvironmentObject var store: HistoryStore
    @State private var minutes = 10
    private let names = ["一", "二", "三", "四", "五"]

    var body: some View {
        VStack(spacing: 24) {
            Text(store.practicedToday ? "✅ 今日已打卡" : "今天還沒練功")
                .font(.headline)
                .foregroundColor(store.practicedToday ? .green : .secondary)

            Spacer()

            ZStack {
                Circle()
                    .fill(engine.currentCount == 5 ? Color.orange : Color.accentColor.opacity(0.15))
                    .frame(width: 220, height: 220)
                    .animation(.easeOut(duration: 0.15), value: engine.currentCount)
                Text(centerText)
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(engine.currentCount == 5 ? .white : .primary)
            }
            Text(engine.currentCount == 5 ? "下蹲" : " ")
                .font(.title2.bold()).foregroundColor(.orange)

            if engine.running {
                Text(format(engine.remaining))
                    .font(.system(size: 44, design: .monospaced))
            } else {
                Picker("時間", selection: $minutes) {
                    Text("10 分鐘").tag(10)
                    Text("30 分鐘").tag(30)
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading) {
                    Text(String(format: "節奏：每拍 %.2f 秒（約 %.0f 拍/分）",
                                engine.beatInterval, 60 / engine.beatInterval))
                        .font(.footnote).foregroundColor(.secondary)
                    Slider(value: $engine.beatInterval, in: 0.6...1.6, step: 0.05)
                }
            }

            Spacer()

            Button {
                engine.running ? engine.stop() : engine.start(minutes: minutes)
            } label: {
                Text(engine.running ? "停止" : "開始")
                    .font(.title2.bold()).frame(maxWidth: .infinity).padding()
                    .background(engine.running ? Color.red : Color.accentColor)
                    .foregroundColor(.white).cornerRadius(14)
            }
        }
        .padding()
    }

    private var centerText: String {
        if !engine.running { return "\(minutes)分" }
        return engine.currentCount == 0 ? "…" : names[engine.currentCount - 1]
    }

    private func format(_ s: Int) -> String { String(format: "%02d:%02d", s / 60, s % 60) }
}
