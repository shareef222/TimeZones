import Foundation

struct WorldTimeZone: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let displayName: String
    let asciiName: String
    let country: String
    let timeZoneID: String
    let population: Int

    var timeZone: TimeZone { TimeZone(identifier: timeZoneID) ?? .current }

    func matches(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        if displayName.localizedCaseInsensitiveContains(query)
            || asciiName.localizedCaseInsensitiveContains(query)
            || country.localizedCaseInsensitiveContains(query) {
            return true
        }
        return (countryAliases[country] ?? []).contains {
            $0.localizedCaseInsensitiveContains(query)
        }
    }
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
            let defaults: [(String, String)] = [
                ("New York City", "US"), ("Los Angeles", "US"), ("London", "GB"), ("Tokyo", "JP"),
            ]
            self.selected = defaults.compactMap { name, countryCode in
                catalog.first { $0.displayName == name && $0.country == (countryNameByCode[countryCode] ?? countryCode) }
            }
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
        guard let url = Bundle.main.url(forResource: "Cities", withExtension: "tsv"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }

        var result: [WorldTimeZone] = []
        result.reserveCapacity(35000)

        for line in content.split(separator: "\n", omittingEmptySubsequences: true) {
            let parts = line.split(separator: "\t", omittingEmptySubsequences: false)
            guard parts.count == 6 else { continue }
            let geonameID = parts[0]
            let name = String(parts[1])
            let asciiName = String(parts[2])
            let countryCode = String(parts[3])
            let timeZoneID = String(parts[4])
            let population = Int(parts[5]) ?? 0
            let country = countryNameByCode[countryCode] ?? countryCode

            result.append(
                WorldTimeZone(
                    id: String(geonameID),
                    displayName: name,
                    asciiName: asciiName,
                    country: country,
                    timeZoneID: timeZoneID,
                    population: population
                )
            )
        }
        return result
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
