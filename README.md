# TimeZones

A lightweight macOS menu bar app for keeping an eye on time around the world — no Dock icon, no clutter, just a small globe in your menu bar.

<p align="center">
  <em>Hover the icon for a quick glance. Click it to manage your cities.</em>
</p>

## Features

- **Hover to check the time** — hovering the menu bar icon shows an instant card (no OS tooltip delay) listing every city you're tracking, with its live time and UTC offset.
- **Click to manage** — opens a panel with live, second-accurate clocks for each city, plus its country and whether it's "Today," "Tomorrow," or "Yesterday" relative to your local time.
- **Search over 34,000 real cities** — not just the ~440 IANA reference zones. Search "Cardiff," "Wales," or "United Kingdom" and it resolves correctly to `Europe/London`; search any city or country worldwide.
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
  main.swift              App entry point
  AppDelegate.swift        Sets the app as a menu bar accessory (no Dock icon)
  MenuBarController.swift  NSStatusItem, instant hover card, click popover
  HoverCardView.swift      SwiftUI content for the instant hover card
  TimeZoneStore.swift      City catalog (loaded from Cities.tsv) + persisted selection
  CountryNames.swift       Generated ISO 3166 country code → name lookup
  CountryAliases.swift     Hand-maintained colloquial name aliases (e.g. Wales → Britain (UK))
  PopoverView.swift        Main panel UI (SwiftUI)
  AddTimeZoneView.swift    Search/add city UI (SwiftUI)
  LaunchAtLogin.swift      Launch-at-login toggle (ServiceManagement)
Resources/
  Info.plist               App bundle metadata (LSUIElement = true)
  Cities.tsv                ~34,000 cities (name, country, timezone, population)
build.sh                   Builds and packages the .app bundle
```

`Cities.tsv` is derived from the [GeoNames](https://www.geonames.org) `cities15000` dataset (CC BY 4.0) — every city worldwide with population > 15,000, each mapped to its real IANA timezone. `CountryNames.swift` is generated from the `iso3166.tab` file shipped with macOS's tz database, so country labels are consistent with the system's own timezone data.

## License

[MIT](LICENSE) — free to use, modify, and distribute. Note that `Cities.tsv` is derived from GeoNames data, licensed [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); attribution: geonames.org.
