import SwiftUI

struct HoverCardView: View {
    @ObservedObject var store: TimeZoneStore
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if store.selected.isEmpty {
                Text("Click to add a city")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.selected) { zone in
                    HStack(spacing: 8) {
                        Text(zone.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)
                        Spacer(minLength: 8)
                        Text(timeString(for: zone))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                        Text(TimeFormatting.offsetString(for: zone.timeZone, at: now))
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .frame(width: 46, alignment: .trailing)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .onReceive(timer) { now = $0 }
    }

    private func timeString(for zone: WorldTimeZone) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.timeZone = zone.timeZone
        return f.string(from: now)
    }
}
