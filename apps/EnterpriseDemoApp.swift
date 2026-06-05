import AppKit
import Foundation

final class EnterpriseDemoApp: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {
    var window: NSWindow!
    var tableView = NSTableView()
    var rows: [[String]] = []
    var memory: [Data] = []
    var level = 1
    var mode = "enterprise"
    var tick = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        level = Int(ProcessInfo.processInfo.environment["DEMO_LEVEL"] ?? "1") ?? 1
        mode = ProcessInfo.processInfo.environment["DEMO_MODE"] ?? "enterprise"
        buildWorkload()
        buildWindow()
        if mode == "metrics" {
            showMetricsConsole()
            startMetricsWorkload()
        } else {
            showLogin()
            scheduleEnterpriseFlow()
        }
    }

    func buildWorkload() {
        let rowCount: Int
        let memoryMB: Int
        switch level {
        case 1:
            rowCount = 10_000
            memoryMB = 96
        case 2:
            rowCount = 40_000
            memoryMB = 256
        case 3:
            rowCount = 100_000
            memoryMB = 640
        case 4:
            rowCount = 150_000
            memoryMB = 1024
        default:
            rowCount = 250_000
            memoryMB = 1536
        }

        for i in 0..<memoryMB {
            memory.append(Data(repeating: UInt8(i % 251), count: 1024 * 1024))
        }

        rows = (0..<rowCount).map { i in
            [
                "USR-\(100000 + i)",
                "Enterprise User \(i)",
                i % 4 == 0 ? "Admin" : "Standard",
                i % 9 == 0 ? "Review" : "Active",
                "Device-\(i % 17000)"
            ]
        }
    }

    func buildWindow() {
        window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 1220, height: 780),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "macappstester Enterprise Demo - \(mode) - level \(level)"
        window.minSize = NSSize(width: 900, height: 620)
        window.makeKeyAndOrderFront(nil)
    }

    func label(_ text: String, _ frame: NSRect, bold: Bool = false, size: CGFloat = 13) -> NSTextField {
        let field = NSTextField(labelWithString: text)
        field.frame = frame
        field.font = bold ? NSFont.boldSystemFont(ofSize: size) : NSFont.systemFont(ofSize: size)
        field.lineBreakMode = .byTruncatingTail
        return field
    }

    func replaceContent(_ root: NSView) {
        window.contentView = root
        window.makeKeyAndOrderFront(nil)
    }

    func showLogin() {
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 1220, height: 780))
        let card = NSBox(frame: NSRect(x: 385, y: 235, width: 450, height: 310))
        card.title = "Enterprise SSO"
        root.addSubview(card)
        card.contentView?.addSubview(label("Contoso Enterprise Admin", NSRect(x: 30, y: 230, width: 360, height: 30), bold: true, size: 22))
        card.contentView?.addSubview(label("Username", NSRect(x: 30, y: 185, width: 120, height: 22)))
        let user = NSTextField(frame: NSRect(x: 30, y: 158, width: 380, height: 28))
        user.stringValue = "admin@example.com"
        card.contentView?.addSubview(user)
        card.contentView?.addSubview(label("Password", NSRect(x: 30, y: 122, width: 120, height: 22)))
        let pass = NSSecureTextField(frame: NSRect(x: 30, y: 95, width: 380, height: 28))
        pass.stringValue = "enterprise-test"
        card.contentView?.addSubview(pass)
        let button = NSButton(title: "Sign in", target: nil, action: nil)
        button.frame = NSRect(x: 300, y: 40, width: 110, height: 32)
        button.bezelStyle = .rounded
        card.contentView?.addSubview(button)
        replaceContent(root)
    }

    func showDashboard() {
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 1220, height: 780))
        let sidebar = buildSidebar(selected: "Dashboard")
        root.addSubview(sidebar)

        root.addSubview(label("Enterprise Security Dashboard", NSRect(x: 260, y: 720, width: 560, height: 32), bold: true, size: 24))
        let search = NSSearchField(frame: NSRect(x: 930, y: 718, width: 230, height: 28))
        search.stringValue = "policy:active"
        root.addSubview(search)

        let cards = [("Users", "\(rows.count)"), ("Devices", "24,391"), ("Policy drift", "2.7%"), ("Open alerts", "183")]
        for (i, c) in cards.enumerated() {
            let box = NSBox(frame: NSRect(x: 260 + CGFloat(i) * 230, y: 610, width: 210, height: 86))
            box.title = c.0
            box.contentView?.addSubview(label(c.1, NSRect(x: 20, y: 24, width: 160, height: 32), bold: true, size: 24))
            root.addSubview(box)
        }

        let progress = NSProgressIndicator(frame: NSRect(x: 260, y: 560, width: 900, height: 18))
        progress.isIndeterminate = false
        progress.minValue = 0
        progress.maxValue = 100
        progress.doubleValue = level >= 4 ? 91 : 67
        root.addSubview(progress)
        root.addSubview(label("Simulated API sync, compliance scan, policy evaluation, and audit ingestion", NSRect(x: 260, y: 528, width: 780, height: 22)))
        replaceContent(root)
    }

    func buildSidebar(selected: String) -> NSBox {
        let sidebar = NSBox(frame: NSRect(x: 18, y: 18, width: 210, height: 734))
        sidebar.title = "Navigation"
        let items = ["Dashboard", "Users", "Devices", "Policies", "Audit", "Reports", "Settings"]
        for (i, item) in items.enumerated() {
            sidebar.contentView?.addSubview(label(item, NSRect(x: 18, y: 650 - CGFloat(i * 42), width: 160, height: 24), bold: item == selected))
        }
        return sidebar
    }

    func showUsersTable() {
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 1220, height: 780))
        root.addSubview(buildSidebar(selected: "Users"))
        root.addSubview(label("Users and Access Review", NSRect(x: 260, y: 720, width: 560, height: 32), bold: true, size: 24))
        root.addSubview(label("Rows loaded: \(rows.count). Native NSTableView with scrolling, selection, and alternating rows.", NSRect(x: 260, y: 688, width: 820, height: 22)))

        let filter = NSSearchField(frame: NSRect(x: 930, y: 718, width: 230, height: 28))
        filter.stringValue = "status:active role:admin"
        root.addSubview(filter)

        root.addSubview(makeTableView(frame: NSRect(x: 260, y: 70, width: 900, height: 600)))
        replaceContent(root)
    }

    func showAuditLog() {
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 1220, height: 780))
        root.addSubview(buildSidebar(selected: "Audit"))
        root.addSubview(label("Audit Log Stream", NSRect(x: 260, y: 720, width: 560, height: 32), bold: true, size: 24))
        let text = NSTextView(frame: NSRect(x: 0, y: 0, width: 880, height: 1700))
        text.isEditable = false
        let count = min(rows.count / 20, 8000)
        text.string = (0..<count).map { i in
            "2026-06-05T12:\(String(format: "%02d", i % 60)):00Z severity=\(i % 7 == 0 ? "WARN" : "INFO") actor=user\(i) action=policy.evaluate resource=device\(i % 333)"
        }.joined(separator: "\n")
        let scroll = NSScrollView(frame: NSRect(x: 260, y: 70, width: 900, height: 630))
        scroll.documentView = text
        scroll.hasVerticalScroller = true
        root.addSubview(scroll)
        replaceContent(root)
    }

    func showMetricsConsole() {
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 1220, height: 780))
        root.addSubview(buildSidebar(selected: "Users"))
        root.addSubview(label("Enterprise Admin Workload Metrics", NSRect(x: 260, y: 720, width: 620, height: 32), bold: true, size: 24))
        root.addSubview(label("Rows: \(rows.count)   Memory allocation: \(memory.count) MB   Workload level: \(level)", NSRect(x: 260, y: 690, width: 820, height: 22)))
        let search = NSSearchField(frame: NSRect(x: 930, y: 718, width: 230, height: 28))
        search.stringValue = "status:active role:admin"
        root.addSubview(search)
        root.addSubview(makeTableView(frame: NSRect(x: 260, y: 70, width: 900, height: 600)))
        let progress = NSProgressIndicator(frame: NSRect(x: 260, y: 35, width: 900, height: 18))
        progress.isIndeterminate = true
        progress.startAnimation(nil)
        root.addSubview(progress)
        replaceContent(root)
    }

    func makeTableView(frame: NSRect) -> NSScrollView {
        let scroll = NSScrollView(frame: frame)
        tableView = NSTableView(frame: scroll.bounds)
        let columns = [("id", "User ID", 140), ("name", "Name", 250), ("role", "Role", 140), ("status", "Status", 140), ("device", "Device", 180)]
        for columnInfo in columns {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(columnInfo.0))
            column.title = columnInfo.1
            column.width = CGFloat(columnInfo.2)
            tableView.addTableColumn(column)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.usesAlternatingRowBackgroundColors = true
        scroll.documentView = tableView
        scroll.hasVerticalScroller = true
        scroll.hasHorizontalScroller = true
        tableView.reloadData()
        return scroll
    }

    func scheduleEnterpriseFlow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { self.showDashboard() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { self.showUsersTable() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 9.0) { self.showAuditLog() }
    }

    func startMetricsWorkload() {
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            self.tick += 1
            if !self.rows.isEmpty {
                let row = (self.tick * 997) % self.rows.count
                self.tableView.scrollRowToVisible(row)
                self.tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            }
            _ = self.rows.prefix(1000 + self.level * 3000).filter { $0[3] == "Active" }.count
            self.window.contentView?.needsDisplay = true
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int { rows.count }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let key = tableColumn?.identifier.rawValue ?? "id"
        let index = ["id": 0, "name": 1, "role": 2, "status": 3, "device": 4][key] ?? 0
        return NSTextField(labelWithString: rows[row][index])
    }
}

let app = NSApplication.shared
let delegate = EnterpriseDemoApp()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
