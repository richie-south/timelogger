import SwiftUI

struct ContentView: View {
    @ObservedObject var store: TimeLogStore
    @State private var showClearConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.indigo)
                Text("Time Logger")
                    .font(.headline)
                Spacer()
                if !store.entries.isEmpty {
                    Text(store.formattedTotal)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            // Input area
            VStack(spacing: 10) {
                if store.isRunning {
                    // Active timer display
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                                .shadow(color: .red.opacity(0.6), radius: 4)
                            Text(store.currentActivity)
                                .font(.system(.body, design: .default, weight: .medium))
                                .lineLimit(1)
                        }

                        Text(formatElapsed(store.elapsedSeconds))
                            .font(.system(.title, design: .monospaced, weight: .semibold))
                            .foregroundStyle(.orange)

                        Button(action: { store.stop() }) {
                            Label("Stop", systemImage: "stop.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .controlSize(.large)
                    }
                    .padding(12)
                    .background(.orange.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
                } else {
                    // Input field + start
                    HStack(spacing: 8) {
                        TextField("What are you working on?", text: $store.currentActivity)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                store.start()
                            }

                        Button(action: { store.start() }) {
                            Image(systemName: "play.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                        .disabled(store.currentActivity.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Entries list
            if !store.entries.isEmpty {
                Divider()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(store.entries) { entry in
                            EntryRow(entry: entry, onDelete: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    store.deleteEntry(id: entry.id)
                                }
                            })
                        }
                    }
                }
                .frame(maxHeight: 200)

                Divider()

                // Bottom actions — inline clear confirmation
                if showClearConfirm {
                    VStack(spacing: 8) {
                        Text("Clear all entries?")
                            .font(.callout.weight(.medium))
                        Text("This will remove all logged time entries. This cannot be undone.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        HStack(spacing: 10) {
                            Button(action: { showClearConfirm = false }) {
                                Text("Cancel")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)

                            Button(role: .destructive, action: {
                                store.clear()
                                showClearConfirm = false
                            }) {
                                Text("Clear All")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .controlSize(.small)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    HStack(spacing: 10) {
                        Button(action: { store.exportJSON() }) {
                            Label("Export JSON", systemImage: "square.and.arrow.up")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Spacer()

                        Button(role: .destructive, action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showClearConfirm = true
                            }
                        }) {
                            Label("Clear All", systemImage: "trash")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }

            Divider()

            // Quit button
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Text("Quit TimeLogger")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 8)
        }
        .padding(.bottom, 4)
    }

    private func formatElapsed(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

struct EntryRow: View {
    let entry: TimeEntry
    var onDelete: (() -> Void)? = nil
    @State private var isHovering = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.system(.body, design: .default, weight: .medium))
                    .lineLimit(1)
            }
            Spacer()
            Text(entry.formattedTime)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
            if isHovering {
                Button(action: { onDelete?() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    ContentView(store: {
        let s = TimeLogStore()
        s.entries = [
            TimeEntry(name: "Code review", seconds: 1830),
            TimeEntry(name: "Feature development", seconds: 5400),
            TimeEntry(name: "Standup meeting", seconds: 900),
        ]
        return s
    }())
    .frame(width: 320)
}
