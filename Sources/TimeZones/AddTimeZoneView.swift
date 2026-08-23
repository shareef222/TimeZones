import SwiftUI

struct AddTimeZoneView: View {
    @EnvironmentObject var store: TimeZoneStore
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var filtered: [WorldTimeZone] {
        let notSelected = store.all.filter { !store.selected.contains($0) }
        guard !query.isEmpty else { return notSelected }
        return notSelected.filter {
            $0.displayName.localizedCaseInsensitiveContains(query) ||
            $0.country.localizedCaseInsensitiveContains(query) ||
            $0.id.localizedCaseInsensitiveContains(query)
        }
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
                TextField("Search by city or country", text: $query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
            }
            .padding(8)
            .background(Color.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 14)
            .padding(.bottom, 8)

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
        .frame(width: 340, height: 420)
    }
}
