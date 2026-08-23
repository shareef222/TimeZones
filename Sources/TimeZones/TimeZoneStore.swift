import Foundation

struct WorldTimeZone: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let displayName: String

    var timeZone: TimeZone { TimeZone(identifier: id) ?? .current }
}

final class TimeZoneStore: ObservableObject {
    static let shared = TimeZoneStore()

    @Published var selected: [WorldTimeZone] {
        didSet { persist() }
    }

    let all: [WorldTimeZone]

    private let defaultsKey = "com.sharifalnatour.timezones.selectedZones"

    private init() {
        let catalog = Self.buildCatalog()
        self.all = catalog

        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let saved = try? JSONDecoder().decode([WorldTimeZone].self, from: data),
           !saved.isEmpty {
            self.selected = saved
        } else {
            let defaultIDs = ["America/New_York", "America/Los_Angeles", "Europe/London", "Asia/Tokyo"]
            self.selected = defaultIDs.compactMap { id in catalog.first(where: { $0.id == id }) }
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(selected) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    func add(_ zone: WorldTimeZone) {
        guard !selected.contains(zone) else { return }
        selected.append(zone)
    }

    func remove(_ zone: WorldTimeZone) {
        selected.removeAll { $0 == zone }
    }

    func remove(at offsets: IndexSet) {
        selected.remove(atOffsets: offsets)
    }

    func move(from source: IndexSet, to destination: Int) {
        selected.move(fromOffsets: source, toOffset: destination)
    }

    private static func buildCatalog() -> [WorldTimeZone] {
        TimeZone.knownTimeZoneIdentifiers
            .filter { $0.contains("/") && !$0.hasPrefix("Etc/") }
            .map { id -> WorldTimeZone in
                let cityRaw = id.split(separator: "/").last.map(String.init) ?? id
                let city = cityRaw.replacingOccurrences(of: "_", with: " ")
                return WorldTimeZone(id: id, displayName: city)
            }
            .sorted { $0.displayName < $1.displayName }
    }
}

enum TimeFormatting {
    static func offsetString(for tz: TimeZone, at date: Date = Date()) -> String {
        let seconds = tz.secondsFromGMT(for: date)
        let hours = seconds / 3600
        let minutes = abs(seconds / 60 % 60)
        let sign = hours >= 0 ? "+" : ""
        return minutes == 0 ? "UTC\(sign)\(hours)" : "UTC\(sign)\(hours):\(String(format: "%02d", minutes))"
    }
}
