import AppKit
import SwiftUI

final class MenuBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var hoverPanel: NSPanel!
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

            let trackingArea = NSTrackingArea(
                rect: button.bounds,
                options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                owner: self,
                userInfo: nil
            )
            button.addTrackingArea(trackingArea)
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 440)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: PopoverView().environmentObject(store))

        let panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.hasShadow = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        panel.contentViewController = NSHostingController(
            rootView: HoverCardView(store: store)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding(6)
        )
        hoverPanel = panel
    }

    @objc(mouseEntered:) func mouseEntered(with event: NSEvent) {
        guard let button = statusItem.button, !popover.isShown else { return }
        guard let buttonWindow = button.window else { return }

        let rowCount = max(store.selected.count, 1)
        let width: CGFloat = 260
        let height: CGFloat = CGFloat(rowCount) * 26 + 24

        let buttonFrameOnScreen = buttonWindow.convertToScreen(button.convert(button.bounds, to: nil))
        let origin = NSPoint(
            x: buttonFrameOnScreen.midX - width / 2,
            y: buttonFrameOnScreen.minY - height - 4
        )
        hoverPanel.setFrame(NSRect(origin: origin, size: NSSize(width: width, height: height)), display: true)
        hoverPanel.orderFrontRegardless()
    }

    @objc(mouseExited:) func mouseExited(with event: NSEvent) {
        hoverPanel.orderOut(nil)
    }

    @objc private func togglePopover(_ sender: AnyObject) {
        hoverPanel.orderOut(nil)
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
