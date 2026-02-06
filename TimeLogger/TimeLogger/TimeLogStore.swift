import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct TimeEntry: Identifiable, Codable {
    let id: UUID
    let name: String
    let seconds: Int

    init(id: UUID = UUID(), name: String, seconds: Int) {
        self.id = id
        self.name = name
        self.seconds = seconds
    }

    var formattedTime: String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%dh %02dm %02ds", h, m, s)
        } else if m > 0 {
            return String(format: "%dm %02ds", m, s)
        } else {
            return String(format: "%ds", s)
        }
    }

    var decimalMinutes: Double {
        Double(seconds) / 60.0
    }
}

class TimeLogStore: ObservableObject {
    @Published var entries: [TimeEntry] = []
    @Published var currentActivity: String = ""
    @Published var isRunning: Bool = false
    @Published var elapsedSeconds: Int = 0

    private var timer: Timer?
    private var startDate: Date?

    func start() {
        guard !currentActivity.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isRunning = true
        elapsedSeconds = 0
        startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            DispatchQueue.main.async {
                self.elapsedSeconds = Int(Date().timeIntervalSince(start))
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false

        let name = currentActivity.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, elapsedSeconds > 0 else { return }

        let entry = TimeEntry(name: name, seconds: elapsedSeconds)
        entries.insert(entry, at: 0)
        currentActivity = ""
        elapsedSeconds = 0
        startDate = nil
    }

    func deleteEntry(id: UUID) {
        entries.removeAll { $0.id == id }
    }

    func clear() {
        entries.removeAll()
    }

    func exportJSON() {
        let exportData = entries.map { entry -> [String: Any] in
            [
                "name": entry.name,
                "minutes": round(entry.decimalMinutes * 100) / 100,
                "formatted": entry.formattedTime
            ]
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted) else { return }

        let panel = NSSavePanel()
        panel.title = "Export Time Log"
        panel.nameFieldStringValue = "timelog-\(Self.dateString()).json"
        panel.allowedContentTypes = [UTType.json]

        if panel.runModal() == .OK, let url = panel.url {
            try? jsonData.write(to: url)
        }
    }

    private static func dateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    var totalSeconds: Int {
        entries.reduce(0) { $0 + $1.seconds }
    }

    var formattedTotal: String {
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        if h > 0 {
            return String(format: "%dh %02dm", h, m)
        } else {
            return String(format: "%dm", m)
        }
    }
}
