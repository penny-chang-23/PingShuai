import AVFoundation
import UIKit

/// 節奏引擎：每 beatInterval 秒報一個數字，一~五循環，第 5 下下蹲。
final class SwingEngine: ObservableObject {
    @Published private(set) var running = false
    @Published private(set) var currentCount = 0      // 1...5，0 = 尚未開始
    @Published private(set) var remaining = 0          // 剩餘秒數
    @Published var beatInterval: Double {              // 每拍秒數
        didSet { UserDefaults.standard.set(beatInterval, forKey: "beatInterval") }
    }

    var onFinish: ((_ seconds: Int, _ presetMinutes: Int) -> Void)?

    private let synth = AVSpeechSynthesizer()
    private let voice = AVSpeechSynthesisVoice(language: "zh-TW")
    private let words = ["一", "二", "三", "四", "五"]
    private var timer: DispatchSourceTimer?
    private var startDate = Date()
    private var totalSeconds = 0
    private var presetMinutes = 0
    private var beat = 0

    init() {
        let saved = UserDefaults.standard.double(forKey: "beatInterval")
        beatInterval = saved > 0 ? saved : 1.0
    }

    func start(minutes: Int) {
        guard !running else { return }
        presetMinutes = minutes
        totalSeconds = minutes * 60
        remaining = totalSeconds
        beat = 0
        currentCount = 0
        startDate = Date()

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
        UIApplication.shared.isIdleTimerDisabled = true // 防止螢幕休眠

        running = true
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + 1.0, repeating: beatInterval, leeway: .milliseconds(5))
        t.setEventHandler { [weak self] in self?.tick() }
        t.resume()
        timer = t
    }

    func stop(completed: Bool = false) {
        guard running else { return }
        timer?.cancel(); timer = nil
        synth.stopSpeaking(at: .immediate)
        running = false
        currentCount = 0
        UIApplication.shared.isIdleTimerDisabled = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        let elapsed = completed ? totalSeconds : min(totalSeconds, Int(Date().timeIntervalSince(startDate)))
        onFinish?(elapsed, presetMinutes)
    }

    private func tick() {
        let elapsed = Date().timeIntervalSince(startDate)
        remaining = max(0, totalSeconds - Int(elapsed))
        if elapsed >= Double(totalSeconds) {
            speak("完成")
            stop(completed: true)
            return
        }
        let n = beat % 5
        currentCount = n + 1
        speak(words[n])
        UIImpactFeedbackGenerator(style: n == 4 ? .heavy : .light).impactOccurred()
        beat += 1
    }

    private func speak(_ text: String) {
        let u = AVSpeechUtterance(string: text)
        u.voice = voice
        u.rate = AVSpeechUtteranceDefaultSpeechRate
        synth.stopSpeaking(at: .immediate)
        synth.speak(u)
    }
}
