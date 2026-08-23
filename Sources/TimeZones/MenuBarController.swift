import AppKit
import SwiftUI

final class MenuBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var tooltipTimer: Timer?
    private let store = TimeZoneStore.shared

    override init() {
        super.init()
        setup()
    }

    private func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            let image = NSImage(systemSymbolName: "globe", accessibilityDescription: "TimeZones")?
                .withSymbolConfiguration(config)
            image?.isTemplate = true
            button.image = image
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 440)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: PopoverView().environmentObject(store))

        updateTooltip()
        let timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            self?.updateTooltip()
        }
        RunLoop.main.add(timer, forMode: .common)
        tooltipTimer = timer
    }

    private func updateTooltip() {
        guard let button = statusItem.button else { return }
        if store.selected.isEmpty {
            button.toolTip = "TimeZones — click to add a city"
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let now = Date()
        let lines = store.selected.map { zone -> String in
            formatter.timeZone = zone.timeZone
            let time = formatter.string(from: now)
            let offset = TimeFormatting.offsetString(for: zone.timeZone, at: now)
            return "\(zone.displayName)   \(time)   \(offset)"
        }
        button.toolTip = lines.joined(separator: "\n")
    }

    @objc private func togglePopover(_ sender: AnyObject) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            updateTooltip()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
