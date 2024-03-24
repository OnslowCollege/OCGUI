// OCGUI.
//
// Created by Matua Doc.
// Created on 2024-03-01.
// Updated on 2024-03-25.

import Foundation
import PythonKit    // @pvieito == 0.3.1

let Remi = Python.import("remi")
let GUI = Python.import("remi.gui")

// MARK: - Convenience

/// The size of widgets.
///
/// Each of the members use the OCSizeUnit enum in order to represent pixel sizes or percentage sizes, depending on which is used.
public struct OCSize {
    /// The width. Use `.pixels(x)` or `.percent(x)` in the initializer for this struct, replacing `x` with the desired integer size.
    let width: OCSizeUnit
    
    /// The height. Use `.pixels(x)` or `.percent(x)` in the initializer for this struct, replacing `x` with the desired integer size.
    let height: OCSizeUnit
}

/// A unit of measurement for the OCSize struct.
///
/// A size unit can be **either** in pixels or a percentage, but not both.
public enum OCSizeUnit : CustomStringConvertible {
    /// The size in pixels.
    case pixels(Int)
    
    /// The size as a percentage.
    case percent(Int)

    /// A CSS-compatible string for the specified size.
    public var description: String {
        switch self {
            case .pixels(let size): return "\(size)px"
            case .percent(let size): return "\(size)%"
        }
    }

    /// Create a size unit from a string such as `"100px"` or `"100%"`
    /// This will fail to initialize if the string format is invalid.
    ///
    /// - Parameters:
    ///   - string: A CSS string formatted either `"#px"` or `"#%"`.
    public init?(fromString string: String) {
        guard string.hasSuffix("px") || string.hasSuffix("%") else { return nil }
        
        let inPixels = string.hasSuffix("px")
        let numberString = string.lowercased().trimmingCharacters(in: [" ", "%", "p", "x"])
        guard let number = Int(numberString) else { return nil }
        self = if inPixels { .pixels(number) } else { .percent(number) }
    }
}



// MARK: - OCControl

/// A protocol for controls that can be updated with a click.
public protocol OCControlClickable {
    func onClick(_ function: @escaping (any OCControlClickable) -> (Void))
}
extension OCControlClickable where Self: OCControl {
    public func onClick(_ function: @escaping (any OCControlClickable) -> (Void)) {
        let pythonFunction: ([PythonObject]) -> (PythonObject) = { args in
            function(self)
            return Python.None
        }
        self._pythonObject.onclick.do(PythonInstanceMethod(pythonFunction))
    }
}

/// A protocol for controls that emit an event when changed, such as drop-down menus or lists.
public protocol OCControlChangeable {
    associatedtype NewValue
    func onChange(_ function: @escaping (_ control: any OCControlChangeable, _ newValue: NewValue) -> (Void))
}

/// A Swift stand-in for a Remi Widget.
public class OCControl : PythonConvertible {

    /// The Python-native widget.
    public let _pythonObject: PythonObject
    
    init(_pythonObject: PythonObject) {
        self._pythonObject = _pythonObject
    }

    public var pythonObject: PythonObject {
        return self._pythonObject
    }

    /// The state of the control. If it is false, the user cannot interact with it.
    public var enabled: Bool {
        get {
            let keys = Array(self._pythonObject.attributes.keys())
            return !keys.contains("disabled")
        } set {
            self._pythonObject.set_enabled(newValue)
        }
    }
    
    /// The visibility of the control. If it is false, the user will not be able to see it.
    public var visible: Bool {
        get {
            let keys = Array(self._pythonObject.style.keys())
            // Return true by default because all controls are visible by default.
            guard let displayKey = keys.first(where: { $0 == "display" }) else { return true }
            return displayKey != "none"
        }
        set {
            self._pythonObject.set_style("display: \(newValue ? "block" : "none")")
        }
    }
    
    /// The boldness of the control. If it is false, the user will not be able to see it.
    public var isBold: Bool {
        get {
            let keys = Array(self._pythonObject.style.keys())
            // Return false by default because no controls start bold.
            guard let weightKey = keys.first(where: { $0 == "font-weight" }) else { return false }
            return weightKey != "none"
        }
        set {
            self._pythonObject.set_style("font-weight: \(newValue ? "bold" : "normal")")
        }
    }

    /// The size of the control. If no size is defined (which is true of most controls by default), this returns nil.
    public var size: OCSize? {
        get {
            let keys = Array(self._pythonObject.style.keys())
            guard keys.contains("width"), keys.contains("height") else { return nil }
            let width = OCSizeUnit(fromString: String(self._pythonObject.style["width"])!)!
            let height = OCSizeUnit(fromString: String(self._pythonObject.style["height"])!)!
            return OCSize(width: width, height: height)
        } set {
            if let newValue = newValue {
                self._pythonObject.set_size(width: newValue.width.description, height: newValue.height.description)
                self._pythonObject.redraw()
            }
        }
    }

    /// Add a new item as a child to this control. If the key is not overridden, it is an empty string.
    public func append(item: String, key: String? = nil) {
        self._pythonObject.append(value: item, key: key ?? "")
    }
}



// MARK: - Mixins

public protocol OCTextConvertible {
    /// The text presented in the button.
    var text: String { get set }
}

extension OCTextConvertible where Self: OCControl {
    public var text: String {
        get { String(self._pythonObject.get_text())! }
        set { self._pythonObject.set_text(newValue); self._pythonObject.redraw() }
    }
}


// MARK: - Controls



/// A regular Button that can be clicked.
public class OCButton : OCControl, OCTextConvertible, OCControlClickable {
    
    /// Create a Button with the specified text.
    public init(text: String) {
        super.init(_pythonObject: GUI.Button(text: text))
    }
    
    override init(_pythonObject: PythonObject) {
        super.init(_pythonObject: _pythonObject)
    }

}



/// A label to present text.
public class OCLabel : OCControl, OCTextConvertible {
    
    /// Create a label with the specified text.
    public init(text: String) {
        super.init(_pythonObject: GUI.Label(text: text))
    }

}



/// A view that shows a PNG image.
public class OCImageView : OCControl {

    /// Create an image view.
    ///
    /// The filename parameter is a relative directory path.
    /// For example, ``image.png`` or ``subfolder/image.png``.
    public init(filename: String) {
        super.init(_pythonObject: GUI.Image(filename: filename))
    }

    /// The filename of the image.
    public var filename: String {
        get { return String(self._pythonObject.attributes["src"])! }
        set { self._pythonObject.set_image(filename: newValue) }
    }

}



/// A single-line field for the user to enter text.
public class OCTextField : OCControl, OCTextConvertible, OCControlChangeable {
    public func onChange(_ function: @escaping (any OCControlChangeable, String) -> (Void)) {
        let pythonFunction: ([PythonObject]) -> (PythonObject) = { args in
            function(self, self.text)
            return Python.None
        }
        self._pythonObject.onchange.do(PythonInstanceMethod(pythonFunction))
    }
    
    public typealias NewValue = String
    
    
    /// Create a text field. If the hint parameter has an argument, that text is shown in light grey
    /// until the user starts typing in the field.
    public init(hint: String? = nil) {
        super.init(_pythonObject: GUI.TextInput(single_line: true, hint: hint ?? ""))
    }

    /// The text present in the text field.
    public var text: String {
        get { return String(self._pythonObject.get_value())! }
        set { self._pythonObject.set_value(newValue); self._pythonObject.redraw() }
    }
}



/// A large, multi-line area to display text and/or have the user enter text.
/// A label to present text.
public class OCTextArea : OCControl, OCTextConvertible, OCControlChangeable {
    public func onChange(_ function: @escaping (any OCControlChangeable, String) -> (Void)) {
        let pythonFunction: ([PythonObject]) -> (PythonObject) = { args in
            function(self, self.text)
            return Python.None
        }
        self._pythonObject.onchange.do(PythonInstanceMethod(pythonFunction))
    }
    
    public typealias NewValue = String
    
    
    /// Create a text area. If the hint parameter has an argument, that text is shown in light grey
    /// until the user starts typing in the area.
    public init(hint: String = "") {
        super.init(_pythonObject: GUI.TextInput(single_line: false, hint: hint))
        self.size = OCSize(width: OCSizeUnit.percent(100), height: OCSizeUnit.pixels(200))
    }

    /// The text present in the text area.
    public var text: String {
        get { return String(self._pythonObject.get_value())! }
        set { self._pythonObject.set_value(text: newValue); self._pythonObject.redraw() }
    }

}



/// A check box. It can be checked (true) or unchecked (false).
public class OCCheckBox : OCControl, OCControlChangeable {
    public func onChange(_ function: @escaping (any OCControlChangeable, Bool) -> (Void)) {
        let pythonFunction: ([PythonObject]) -> (PythonObject) = { args in
            function(self, self.checked)
            return Python.None
        }
        self._pythonObject.onchange.do(PythonInstanceMethod(pythonFunction))
    }
    
    public typealias NewValue = Bool
    

    /// Create a check box. If the default value is not overriden, the check box starts unchecked.
    public init(defaultValue: Bool? = false) {
        super.init(_pythonObject: GUI.CheckBox(checked: defaultValue ?? false))
    }

    /// The state of the checkbox. If this value is true, the checkbox has been checked.
    public var checked: Bool {
        get { return Bool(self._pythonObject.get_value())! }
        set { self._pythonObject.set_value(checked: newValue); self._pythonObject.redraw() }
    }

}



/// A color picker.
public class OCColorPicker : OCControl, OCControlChangeable {
    public func onChange(_ function: @escaping (any OCControlChangeable, String) -> (Void)) {
        let pythonFunction: ([PythonObject]) -> (PythonObject) = { args in
            function(self, self.color)
            return Python.None
        }
        self._pythonObject.onchange.do(PythonInstanceMethod(pythonFunction))
    }
    
    public typealias NewValue = String
    

    /// Create a color picker.
    ///
    /// When the user clicks on this, the browser's built-in color picker is shown.
    /// This is consistent across most browsers but uses the macOS/iOS native color picker on Safari.
    public init(defaultColor: String? = nil) {
        super.init(_pythonObject: GUI.ColorPicker(default_value: defaultColor ?? "#995500"))
    }

    /// The currently-selected color.
    public var color: String {
        get { return String(self._pythonObject.get_value())! }
        set { self._pythonObject.set_value(newValue); self._pythonObject.redraw() }
    }

}



/// A date picker.
public class OCDatePicker : OCControl, OCControlChangeable {
    public func onChange(_ function: @escaping (any OCControlChangeable, Date) -> (Void)) {
        let pythonFunction: ([PythonObject]) -> (PythonObject) = { args in
            function(self, self.date)
            return Python.None
        }
        self._pythonObject.onchange.do(PythonInstanceMethod(pythonFunction))
    }
    
    public typealias NewValue = Date
    

    /// Create a date picker. When the user clicks on this, the browser's built-in date picker is shown.
    /// If the default date is not overridden, the local date at the time the page was rendered is used.
    public init(defaultDate: Date? = nil) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        super.init(_pythonObject: GUI.Date(default_value: formatter.string(from: defaultDate ?? Date())))
    }

    /// The currently-selected date. You must provide and will received a native Foundation Date.
    /// For a string, use dateString instead.
    public var date: Date {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: String(self._pythonObject.get_value())!)!
        }
        set {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self._pythonObject.set_value(formatter.string(from: newValue))
            self._pythonObject.redraw()
        }
    }

    /// The currently-selected date as a "yyyy-MM-dd"-formatted string.
    ///
    /// **⚠️ WARNING!** This method will crash the program if an invalid string is provided when **setting** the date value.
    public var dateString: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: self.date)
        } set {
            self._pythonObject.set_value(newValue)
            self._pythonObject.redraw()
        }
    }

}



/// A drop-down item used in Drop Down controls.
public class OCDropDownItem : OCControl {

    /// Create a drop-down item with the specified text and optional key.
    public init(text: String, key: String? = nil) {
        super.init(_pythonObject: GUI.DropDownItem(text: text, key: key ?? ""))
    }

    fileprivate init(pythonObject: PythonObject) {
        super.init(_pythonObject: pythonObject)
    }

    /// The text shown in the drop-down item.
    public var text: String {
        get { return String(self._pythonObject.get_text())! }
        set { self._pythonObject.set_text(newValue); self._pythonObject.redraw() }
    }

    /// The key for this drop-down item. If one was not provided at construction, this returns nil.
    public var key: String? {
        get {
            let pythonKey = self._pythonObject.get_key()
            if pythonKey != "" && pythonKey != Python.None {
                return String(pythonKey)!
            } else {
                return nil
            }
        }
    }

}



/// A drop-down menu with multiple text options.
public class OCDropDown : OCControl, OCControlChangeable {
    public func onChange(_ function: @escaping (any OCControlChangeable, OCDropDownItem) -> (Void)) {
        let pythonFunction: ([PythonObject]) -> (PythonObject) = { args in
            function(self, self.selectedItem!)
            return Python.None
        }
        self._pythonObject.onchange.do(PythonInstanceMethod(pythonFunction))
    }
    
    public typealias NewValue = OCDropDownItem
    
    
    /// Create a drop-down menu. The provided strings are converted to drop-down items, with their index as the key.
    public init(fromArray items: [String]) {
        super.init(_pythonObject: GUI.DropDown())
        for (offset, item) in items.enumerated() {
            self.append(item: item, key: "\(offset + 1)")
        }
        self.select(byText: items[0])
    }

    /// Removes all drop-down items.
    public func empty() {
        self._pythonObject.empty()
    }

    /// Select a drop-down item using its key.
    public func select(byKey key: String) {
        self._pythonObject.select_by_key(key: key)
    }

    /// Select a drop-down item using its text.
    public func select(byText text: String) {
        self._pythonObject.select_by_value(value: text)
    }

    /// Select a specified drop-down item.
    public func select(item: OCDropDownItem) {
        self._pythonObject.select_by_value(item.text)
    }

    /// The currently-selected item. You can then get its text and key using .text and .key.
    public var selectedItem: OCDropDownItem? {
        let pythonItem = self._pythonObject.get_item()
        if pythonItem != Python.None {
            return OCDropDownItem(pythonObject: pythonItem)
        } else {
            return nil
        }
    }

}



/// A dialog window.
public class OCDialog : OCControl {
    
    /// The confirm button.
    fileprivate var confirmButton: OCButton {
        return OCButton(_pythonObject: self._pythonObject.conf)
    }
    
    /// The cancel button.
    fileprivate var cancelButton: OCButton {
        return OCButton(_pythonObject: self._pythonObject.cancel)
    }

    /// Create a dialog window with the specified title and message.
    public init(title: String, message: String) {
        super.init(_pythonObject: GUI.GenericDialog(title: title, message: message))
    }

    /// Add an OCControl with the specified key.
    public func addField(key: String, field: OCControl) {
        self._pythonObject.add_field(key: key, field: field)
    }

    /// Add an OCControl and label with the specified key.
    public func addField(key: String, label: String, field: OCControl) {
        self._pythonObject.add_field_with_label(key: key, label_description: label, field: field)
    }

    /// Get a field with a specified key. Returns nil if not such item exists.
    public func getField(forKey key: String) -> OCControl? {
        let pythonObject = self._pythonObject.get_field(key: key)
        if pythonObject != Python.None {
            return OCControl(_pythonObject: pythonObject)
        } else {
            return nil
        }
    }

    /// Show the dialog.
    public func show(in app: OCAppDelegate) {
        self._pythonObject.show(app)
    }

    /// Hide the dialog.
    ///
    /// **⚠️ WARNING!** If the dialog hasn't been shown at least once, this method will crash the program.
    public func hide() {
        self._pythonObject.hide()
    }

    public func onConfirm(_ function: @escaping (any OCControlClickable) -> (Void)) {
        let pythonFunction: ([PythonObject]) -> (PythonObject) = { args in
            let button = self.confirmButton
            function(button)
            return Python.None
        }
        self._pythonObject.confirm_dialog.do(PythonInstanceMethod(pythonFunction))
    }
    
    public func onCancel(_ function: @escaping (any OCControlClickable) -> (Void)) {
        let pythonFunction: ([PythonObject]) -> (PythonObject) = { args in
            let button = self.cancelButton
            function(button)
            return Python.None
        }
        self._pythonObject.cancel_dialog.do(PythonInstanceMethod(pythonFunction))
    }

}



/// An item used in List View controls.
public class OCListItem : OCControl {

    public init(text: String) {
        super.init(_pythonObject: GUI.ListItem(text: text))
    }

    fileprivate init(pythonObject: PythonObject) {
        super.init(_pythonObject: pythonObject)
    }

    public var text: String {
        get {
            return String(self._pythonObject.get_text())!
        }
    }

}

/// A list of items, each presented on its own row.
public class OCListView : OCControl, OCControlChangeable {
    public func onChange(_ function: @escaping (any OCControlChangeable, OCListItem) -> (Void)) {
        let pythonFunction: ([PythonObject]) -> (PythonObject) = { args in
            function(self, self.selectedItem!)
            return Python.None
        }
        self._pythonObject.onselection.do(PythonInstanceMethod(pythonFunction))
    }
    
    public typealias NewValue = OCListItem
    

    public init(selectable: Bool? = nil) {
        super.init(_pythonObject: GUI.ListView(selectable: selectable ?? true))
        self.size = OCSize(width: .percent(100), height: .percent(100))
    }

    public func empty() {
        self._pythonObject.empty()
    }

    public func select(byKey key: String) {
        self._pythonObject.select_by_key(key: key)
    }

    public func select(byText text: String) {
        self._pythonObject.select_by_value(value: text)
    }

    public func select(item: OCListItem) {
        self._pythonObject.select_by_value(item.text)
    }

    public var selectedItem: OCListItem? {
        get {
            let pythonObject = self._pythonObject.get_item()
            if pythonObject != Python.None {
                return OCListItem(pythonObject: pythonObject)
            } else {
                return nil
            }
        }
    }

    public func onChange(_ function: @escaping ([PythonObject]) -> (PythonObject)) {
        self._pythonObject.onselection.do(PythonInstanceMethod(function))
    }

}



/// Private: methods common to OCHBox and OCVBox.
public protocol OCLayout {
    var _pythonObject: PythonObject { get }
    var children: [String: PythonObject] { get }
    func empty()
    func append(control: OCControl)
}

extension OCLayout {
    public var children: [String: PythonObject] {
        let pythonChildren = Dictionary<String, PythonObject>(self._pythonObject.children)
        return pythonChildren!
    }

    public func empty() {
        self._pythonObject.empty
    }
}

/// A layout object that places widgets next to each other from left to right.
public class OCHBox : OCControl, OCLayout {

    public init(controls: [OCControl], justifyContent: OCContentJustification? = nil) {
        super.init(_pythonObject: GUI.HBox(controls.map { $0.pythonObject }, style: PythonObject(["justify-content": justifyContent?.rawValue ?? "space-around"])))
    }

    public func append(control: OCControl) {
        self._pythonObject.append(control.pythonObject)
    }
}

public class OCVBox : OCControl, OCLayout {
    public init(controls: [OCControl], justifyContent: OCContentJustification? = nil) {
        super.init(_pythonObject: GUI.VBox(controls.map { $0.pythonObject }, style: PythonObject(["justify-content": justifyContent?.rawValue ?? "space-around"])))
    }

    public func append(control: OCControl) {
        self._pythonObject.append(control.pythonObject)
    }
}



public protocol OCAppDelegate : PythonConvertible {
    func _main(_ mainArgs: [PythonObject]) -> PythonObject
    func main(app: OCAppDelegate) -> OCControl
    func close()
}

/// An application built with Remi.
///
/// You must override the main method and return the main control (usually an OCVBox, OCHBox, or OCGridBox).
///
/// For example:
/// ```swift
/// override public func main(_ mainArgs: [PythonObject]) -> PythonObject {
///     // Set up the GUI. You can refer to class constants and variables.
///     let vBox: OCVBox = OCVBox(controls: [
///         OCTextField(hint: "Type here"),
///         OCButton("OK"), OCButton("Cancel")
///     ])
///
///     // Return the control.
///     return vBox.pythonObject
/// }
/// ```
/// Finally, run `.start()` on an instance of this class to run the program. Usually, this is the last line in your code.
open class OCApp : OCAppDelegate {
    public var pythonObject: PythonObject {
        return self._app
    }

    public init() { }
    
    private var _server: PythonObject = Python.None
    fileprivate var _app: PythonObject = Python.None
    
    /// Start the program.
    public func start() {
        // Add the Swift `main` method to the Python subclass.
        var members = self.members
        members["main"] = PythonInstanceMethod(self._main).pythonObject

        // Import the styles.css file via the Python subclass' `__init__` method.
        let resPath = FileManager.default.currentDirectoryPath + "/res"
        members["__init__"] = PythonInstanceMethod({ args in
            Remi.App.__init__(args[0], args[1], args[2], args[3], static_file_path: ["res": resPath])
            return Python.None
        })

        // Create the subclass and start the app based on it.
        let convertedMembers = members.reduce(into: [String: PythonObject]()) { result, pair in
            result[pair.key] = PythonObject(pair.value)
        }
        
        self._server = Remi.Server(gui_class: PythonClass("\(type(of: self))", superclasses: [Remi.App], members: convertedMembers), start: false, port: 1234)
        
        self._server.start()
        self._server.serve_forever()
    }
    
    public func close() {
        let stopDialog = OCDialog(title: "Program stopped", message: "It is now safe to close this tab.")
        stopDialog.cancelButton.visible = false
        stopDialog.confirmButton.visible = false
        stopDialog.show(in: self)
        print(self._server.stop())
    }

    fileprivate var members: [String: PythonConvertible] {
        // Based on Ryam Heitner's answer (https://stackoverflow.com/questions/46597624/can-swift-convert-a-class-struct-data-into-dictionary)
        let mirror = Mirror(reflecting: self)

        var invalidCount = 0
        let dictionary = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map { (label: String?, value: Any) -> (String, PythonConvertible) in
            guard let label = label, let value = value as? PythonConvertible else { invalidCount += 1; return ("_INVALID_\(invalidCount)", Python.None) }
        return (label, value)
        }).filter { !$0.key.contains("_INVALID_") && !$0.key.contains("members") }
        return dictionary
    }
    
    public func _main(_ mainArgs: [PythonObject]) -> PythonObject {
        self._app = mainArgs[0]
        return self.main(app: self).pythonObject
    }

    /// Override this method by copying the signature, prefixed with `override`. See the `OCApp` documentation for an example.
    ///
    /// If this method is not overridden, it will display a Quit button.
    open func main(app: OCAppDelegate) -> OCControl {
        let label = OCLabel(text: "Override the main method to create a GUI. Copy the example code below to get started.")

        let textArea = OCTextArea()
        textArea.text = """
        override open func main(app: OCAppDelegate) -> OCControl {
            // Set up the GUI. You can refer to class constants and variables.
            let vBox: OCVBox = OCVBox(controls: [
                OCTextField(hint: "Type here"),
                OCButton(text: "OK"), OCButton(text: "Cancel")
            ])

            // Return the control.
            return vBox
        }
        """

        let button = OCButton(text: "Quit")
        button.onClick { _ in app.close() }

        let vBox = OCVBox(controls: [label, textArea, button])
        return vBox
    }
}
