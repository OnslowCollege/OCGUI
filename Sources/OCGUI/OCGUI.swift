import AppKit
import SwiftUI

public protocol OCAppDelegate {}
public protocol OCControlClickable {}
public protocol OCControlChangeable {}

open class OCControl: ObservableObject, Identifiable {
    public let id = UUID()
    public init() {}
}

public struct OCDropDownItem: Identifiable, Hashable {
    public let id = UUID()
    public let text: String
}

public final class OCLabel: OCControl {
    @Published public var text: String
    public init(text: String) {
        self.text = text
        super.init()
    }
}

public final class OCButton: OCControl, OCControlClickable {
    public let text: String
    private var action: ((any OCControlClickable) -> Void)?

    public init(text: String) {
        self.text = text
        super.init()
    }

    public func onClick(_ action: @escaping (any OCControlClickable) -> Void) {
        self.action = action
    }

    fileprivate func click() {
        action?(self)
    }
}

public final class OCTextField: OCControl {
    public let hint: String
    @Published public var text: String = ""

    public init(hint: String) {
        self.hint = hint
        super.init()
    }
}

public final class OCDropDown: OCControl, OCControlChangeable {
    @Published public var items: [OCDropDownItem]
    @Published public var selectedText: String

    private var action: ((any OCControlChangeable, OCDropDownItem) -> Void)?

    public init(fromArray values: [String]) {
        self.items = values.map { OCDropDownItem(text: $0) }
        self.selectedText = values.first ?? ""
        super.init()
    }

    public func append(item: String) {
        items.append(OCDropDownItem(text: item))
    }

    public func onChange(_ action: @escaping (any OCControlChangeable, OCDropDownItem) -> Void) {
        self.action = action
    }

    fileprivate func changed(to text: String) {
        selectedText = text
        if let item = items.first(where: { $0.text == text }) {
            action?(self, item)
        }
    }
}

public class OCBox: OCControl {
    @Published public var controls: [OCControl]

    public init(controls: [OCControl]) {
        self.controls = controls
        super.init()
    }

    public func append(control: OCControl) {
        controls.append(control)
    }

    public func empty() {
        controls.removeAll()
    }
}

public final class OCVBox: OCBox {}
public final class OCHBox: OCBox {}

open class OCApp {
    public init() {}

    open func main(app: any OCAppDelegate) -> OCControl {
        fatalError("Override main(app:)")
    }

    public func start() {
        let app = NSApplication.shared
        let delegate = BasicDelegate()
        app.delegate = delegate

        let rootControl = main(app: delegate)

        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 1000, height: 1000),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "OCGUI"
        window.contentView = NSHostingView(rootView: OCControlView(control: rootControl))
        window.makeKeyAndOrderFront(nil)

        app.setActivationPolicy(.regular)
        app.activate(ignoringOtherApps: true)
        app.run()
    }
}

private final class BasicDelegate: NSObject, NSApplicationDelegate, OCAppDelegate {}

private struct OCControlView: View {
    @ObservedObject var control: OCControl

    var body: some View {
        render(control)
    }

    @ViewBuilder
    private func render(_ control: OCControl) -> some View {
        if let label = control as? OCLabel {
            OCLabelView(label: label)
        } else if let button = control as? OCButton {
            Button(button.text) {
                button.click()
            }
        } else if let textField = control as? OCTextField {
            OCTextFieldView(textField: textField)
        } else if let dropdown = control as? OCDropDown {
            OCDropDownView(dropdown: dropdown)
        } else if let vbox = control as? OCVBox {
            OCBoxView(box: vbox, axis: .vertical)
        } else if let hbox = control as? OCHBox {
            OCBoxView(box: hbox, axis: .horizontal)
        } else {
            EmptyView()
        }
    }
}

private struct OCLabelView: View {
    @ObservedObject var label: OCLabel

    var body: some View {
        Text(label.text)
    }
}

private struct OCTextFieldView: View {
    @ObservedObject var textField: OCTextField

    var body: some View {
        TextField(textField.hint, text: $textField.text)
            .textFieldStyle(.roundedBorder)
            .frame(minWidth: 180)
    }
}

private struct OCDropDownView: View {
    @ObservedObject var dropdown: OCDropDown

    var body: some View {
        Picker("", selection: Binding(
            get: { dropdown.selectedText },
            set: { dropdown.changed(to: $0) }
        )) {
            ForEach(dropdown.items) { item in
                Text(item.text).tag(item.text)
            }
        }
        .frame(width: 180)
    }
}

private enum OCBoxAxis {
    case vertical
    case horizontal
}

private struct OCBoxView: View {
    @ObservedObject var box: OCBox
    let axis: OCBoxAxis

    var body: some View {
        if axis == .vertical {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(box.controls) { control in
                    OCControlView(control: control)
                }
            }
            .padding()
        } else {
            HStack(alignment: .center, spacing: 10) {
                ForEach(box.controls) { control in
                    OCControlView(control: control)
                }
            }
        }
    }
}
