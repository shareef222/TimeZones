import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var store: TimeZoneStore
    @State private var showAddSheet = false
    @State private var launchAtLogin = LaunchAtLogin.isEnabled

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if store.selected.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(store.selected) { zone in
                        TimeZoneRow(zone: zone)
                            .listRowInsets(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14))
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { store.remove(zone) } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                    }
                    .onMove(perform: store.move)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            Divider()
            footer
        }
        .frame(width: 320, height: 440)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showAddSheet) {
            AddTimeZoneView().environmentObject(store)
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 15))
                .foregroundStyle(.blue)
            Text("TimeZones")
                .font(.system(size: 14, weight: .semibold))
            Spacer()
            Button { showAddSheet = true } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.blue)
            .help("Add a city")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("No timezones added")
                .font(.system(size: 13, weight: .medium))
            Button("Add a City") { showAddSheet = true }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Toggle("Launch at Login", isOn: $launchAtLogin)
                .toggleStyle(.switch)
                .controlSize(.mini)
                .font(.system(size: 11))
                .onChange(of: launchAtLogin) { newValue in
                    LaunchAtLogin.isEnabled = newValue
                }

            HStack {
                Text("Hover the menu bar icon for a quick glance")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
                    .buttonStyle(.plain)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

struct TimeZoneRow: View {
    let zone: WorldTimeZone
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(zone.displayName)
                    .font(.system(size: 13, weight: .medium))
                Text(dayDifference)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(timeString)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                Text(TimeFormatting.offsetString(for: zone.timeZone, at: now))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .onReceive(timer) { now = $0 }
    }

    private var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm:ss a"
        f.timeZone = zone.timeZone
        return f.string(from: now)
    }

    private var dayDifference: String {
        let localComponents = Calendar.current.dateComponents([.year, .month, .day], from: now)
        var remoteCalendar = Calendar.current
        remoteCalendar.timeZone = zone.timeZone
        let remoteComponents = remoteCalendar.dateComponents([.year, .month, .day], from: now)

        guard let localDate = Calendar.current.date(from: localComponents),
              let remoteDate = Calendar.current.date(from: remoteComponents) else { return "" }

        let days = Calendar.current.dateComponents([.day], from: localDate, to: remoteDate).day ?? 0
        switch days {
        case 0: return "Today"
        case 1: return "Tomorrow"
        case -1: return "Yesterday"
        default: return days > 0 ? "+\(days)d" : "\(days)d"
        }
    }
}
