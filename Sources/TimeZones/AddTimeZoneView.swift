import SwiftUI

struct AddTimeZoneView: View {
    @EnvironmentObject var store: TimeZoneStore
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private static let resultLimit = 60

    private static var popularSuggestions: [WorldTimeZone] = []

    private var filtered: [WorldTimeZone] {
        let q = query.trimmingCharacters(in: .whitespaces)
        let pool: [WorldTimeZone]
        if q.isEmpty {
            if Self.popularSuggestions.isEmpty {
                Self.popularSuggestions = Array(store.all.sorted { $0.population > $1.population }.prefix(30))
            }
            pool = Self.popularSuggestions
        } else {
            pool = store.all.filter { $0.matches(q) }
        }

        return pool
            .filter { !store.selected.contains($0) }
            .sorted { lhs, rhs in
                let rankL = relevance(lhs, query: q)
                let rankR = relevance(rhs, query: q)
                if rankL != rankR { return rankL < rankR }
                return lhs.population > rhs.population
            }
            .prefix(Self.resultLimit)
            .map { $0 }
    }

    private func relevance(_ zone: WorldTimeZone, query: String) -> Int {
        guard !query.isEmpty else { return 0 }
        if zone.displayName.caseInsensitiveCompare(query) == .orderedSame { return 0 }
        if zone.displayName.range(of: query, options: [.caseInsensitive, .anchored]) != nil { return 1 }
        if zone.displayName.localizedCaseInsensitiveContains(query) { return 2 }
        return 3
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add a City")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.plain)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.blue)
            }
            .padding(14)

            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))
                TextField("Search any city or country", text: $query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
            }
            .padding(8)
            .background(Color.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 14)
            .padding(.bottom, 4)

            HStack {
                Text(query.isEmpty ? "Popular cities" : "\(filtered.count) result\(filtered.count == 1 ? "" : "s")")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)

            if filtered.isEmpty {
                VStack(spacing: 6) {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                    Text("No cities found")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filtered) { zone in
                    Button {
                        store.add(zone)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(zone.displayName)
                                    .font(.system(size: 13, weight: .medium))
                                Text(zone.country)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(TimeFormatting.offsetString(for: zone.timeZone))
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 340, height: 440)
    }
}
