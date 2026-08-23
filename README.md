# TimeZones

A lightweight macOS menu bar app for keeping an eye on time around the world — no Dock icon, no clutter, just a small globe in your menu bar.

<p align="center">
  <em>Hover the icon for a quick glance. Click it to manage your cities.</em>
</p>

## Features

- **Hover to check the time** — hovering the menu bar icon shows a tooltip listing every city you're tracking, with its current time and UTC offset.
- **Click to manage** — opens a panel with live, second-accurate clocks for each city, plus its country and whether it's "Today," "Tomorrow," or "Yesterday" relative to your local time.
- **Search by city or country** — add any of ~400 IANA timezones (e.g. search "Japan" to find Tokyo, or search "Tokyo" directly).
- **Reorder** your list by dragging rows; remove a city with the minus button that appears on hover.
- **Launch at Login** toggle, built in.
- No Dock icon, no menu bar clutter beyond a single glyph — built to stay out of your way.

## Requirements

- macOS 13 (Ventura) or later

## Building

The app is a Swift Package Manager project — no Xcode project file required, just the Swift toolchain that ships with Xcode Command Line Tools.

```bash
git clone https://github.com/shareef222/TimeZones.git
cd TimeZones
./build.sh
```

This produces `TimeZones.app` in the project root. Run it directly:

```bash
open TimeZones.app
```

Or install it:

```bash
cp -R TimeZones.app /Applications/
open /Applications/TimeZones.app
```

## Project structure

```
Sources/TimeZones/
  main.swift               App entry point
  AppDelegate.swift         Sets the app as a menu bar accessory (no Dock icon)
  MenuBarController.swift   NSStatusItem, hover tooltip, popover
  TimeZoneStore.swift       Timezone catalog + persisted selection (UserDefaults)
  TimeZoneCatalogData.swift Generated timezone → country lookup (IANA tz database)
  PopoverView.swift         Main panel UI (SwiftUI)
  AddTimeZoneView.swift     Search/add city UI (SwiftUI)
  LaunchAtLogin.swift       Launch-at-login toggle (ServiceManagement)
Resources/Info.plist        App bundle metadata (LSUIElement = true)
build.sh                    Builds and packages the .app bundle
```

The city → country mapping in `TimeZoneCatalogData.swift` is generated from the IANA tz database (`zone.tab` / `iso3166.tab`) shipped with macOS, so search results and country labels reflect the real tz database rather than a guess based on the identifier string.

## License

Personal project, no license specified.
