// OCGUI.
//
// Created by Matua Doc.
// Created on 2024-03-01.

import Foundation
import PythonKit    // @pvieito == 0.3.1

let Remi = Python.import("remi")
let GUI = Python.import("remi.gui")

// MARK: - Convenience

/// The size of widgets.
///
/// Each of the members use the OCSizeUnit enum in order to represent pixel sizes or percentage sizes, depending on which is used.
public struct OCSize {
    let width: OCSizeUnit
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

    public var description: String {
        switch self {
            case .pixels(let size): return "\(size)px"
            case .percent(let size): return "\(size)%"
        }
    }

    /// Create a size unit from a string such as `"100px"` or `"100%"`. This will fail to initialize if the string format is invalid.
    public init?(fromString string: String) {
        guard string.hasSuffix("px") || string.hasSuffix("%") else { return nil }
        
        let inPixels = string.hasSuffix("px")
        let numberString = string.lowercased().trimmingCharacters(in: [" ", "%", "p", "x"])
        guard let number = Int(numberString) else { return nil }
        self = if inPixels { .pixels(number) } else { .percent(number) }
    }
}

/// A content justification style, conforming to `justify-content` in CSS.
public enum OCContentJustification : String {
    case flexStart = "flex-start !important"
    case flexEnd = "flex-end !important"
    case center = "center !important"
    case spaceBetween = "space-between !important"
    case spaceAround = "space-around !important"
    case spaceEvenly = "space-evenly !important"
}



// MARK: - OCControl

/// A protocol for controls that can be updated with a click.
public protocol OCControlClickable { func onClick(_ function: @escaping ([PythonObject]) -> (PythonObject)) }
extension OCControlClickable where Self: OCControl {
    public func onClick(_ function: @escaping ([PythonObject]) -> (PythonObject)) {
        self._pythonObject.onclick.do(PythonInstanceMethod(function))
    }
}

/// A protocol for controls that emit an event when changed, such as drop-down menus or lists.
public protocol OCControlChangeable { func onChange(_ function: @escaping ([PythonObject]) -> (PythonObject)) }
extension OCControlChangeable where Self: OCControl {
    public func onChange(_ function: @escaping ([PythonObject]) -> (PythonObject)) {
        self._pythonObject.onchange.do(PythonInstanceMethod(function))
    }
}

/// A Swift stand-in for a Remi Widget.
public class OCControl : PythonConvertible {

    /// The Python-native widget.
    let _pythonObject: PythonObject
    
    fileprivate init(_pythonObject: PythonObject) {
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



// MARK: - Controls



/// A regular Button that can be clicked.
public class OCButton : OCControl, OCControlClickable {
    
    /// Create a Button with the specified text.
    public init(text: String) {
        super.init(_pythonObject: GUI.Button(text: text))
    }
}



/// A label to present text.
public class OCLabel : OCControl {
    
    /// Create a label with the specified text.
    public init(text: String) {
        super.init(_pythonObject: GUI.Label(text: text))
    }

    /// The text presented in the label.
    public var text: String {
        get { return String(self._pythonObject.get_text())! }
        set { self._pythonObject.set_text(text: newValue); self._pythonObject.redraw() }
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
public class OCTextField : OCControl, OCControlChangeable {
    
    /// Create a text field. If the hint parameter has an argument, that text is shown in light grey
    /// until the user starts typing in the field.
    public init(hint: String? = nil) {
        super.init(_pythonObject: GUI.TextInput(single_line: true, hint: hint ?? ""))
    }

    /// The text present in the text field. This cannot be overridden programatically.
    public var text: String {
        return String(self._pythonObject.get_value())!
    }
}



/// A large, multi-line area to display text and/or have the user enter text.
/// A label to present text.
public class OCTextArea : OCControl, OCControlChangeable {
    
    /// Create a text area. If the hint parameter has an argument, that text is shown in light grey
    /// until the user starts typing in the area.
    public init(hint: String = "") {
        super.init(_pythonObject: GUI.TextInput(single_line: false, hint: hint))
        self.size = OCSize(width: OCSizeUnit.percent(100), height: OCSizeUnit.pixels(200))
    }

    /// The text present in the text area. This can be overridden programatically.
    public var text: String {
        get { return String(self._pythonObject.get_value())! }
        set { self._pythonObject.set_value(text: newValue); self._pythonObject.redraw() }
    }

}



/// A check box. It can be checked (true) or unchecked (false).
public class OCCheckBox : OCControl, OCControlChangeable {

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
    ///
    /// This can only be called from within PythonInstanceMethods.
    ///
    /// **⚠️ WARNING!** If this is called inside the `main()` function of an OCApp subclass,
    /// you must pass `mainArgs[0]` as an argument to this function.
    public func show(in app: PythonObject) {
        self._pythonObject.show(app)
    }

    /// Hide the dialog.
    ///
    /// **⚠️ WARNING!** If the dialog hasn't been shown at least once, this method will crash the program.
    public func hide() {
        self._pythonObject.hide()
    }

    public func onConfirm(_ function: @escaping ([PythonObject]) -> (PythonObject)) {
        self._pythonObject.confirm_dialog.do(PythonInstanceMethod(function))
    }
    
    public func onCancel(_ function: @escaping ([PythonObject]) -> (PythonObject)) {
        self._pythonObject.cancel_dialog.do(PythonInstanceMethod(function))
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
fileprivate protocol OCLayout {
    var _pythonObject: PythonObject { get }
    var children: [String: PythonObject] { get }
}

extension OCLayout {
    public var children: [String: PythonObject] {
        let pythonChildren = Dictionary<String, PythonObject>(self._pythonObject.children)
        return pythonChildren!
    }
}

/// A layout object that places widgets next to each other from left to right.
public class OCHBox : OCControl, OCLayout {

    public init(controls: [OCControl], justifyContent: OCContentJustification? = nil) {
        super.init(_pythonObject: GUI.HBox(controls.map { $0.pythonObject }, style: PythonObject(["justify-content": justifyContent?.rawValue ?? "space-around"])))
    }
}

public class OCVBox : OCControl, OCLayout {
    public init(controls: [OCControl], justifyContent: OCContentJustification? = nil) {
        super.init(_pythonObject: GUI.VBox(controls.map { $0.pythonObject }, style: PythonObject(["justify-content": justifyContent?.rawValue ?? "space-around"])))
    }
}



public protocol OCAppDelegate {
    func main(_ mainArgs: [PythonObject]) -> PythonObject
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

    public init() {}

    /// Start the program.
    public func start() {
        // Add the Swift `main` method to the Python subclass.
        var members = self.members
        members["main"] = PythonInstanceMethod(self.main).pythonObject

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
        Remi.start(PythonClass("\(type(of: self))", superclasses: [Remi.App], members: convertedMembers))
    }

    fileprivate var members: [String: PythonConvertible] {
        // Based on Ryam Heitner's answer (https://stackoverflow.com/questions/46597624/can-swift-convert-a-class-struct-data-into-dictionary)
        let mirror = Mirror(reflecting: self)

        let dictionary = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map { (label: String?, value: Any) -> (String, PythonConvertible) in
        guard let label = label, let value = value as? PythonConvertible else { return ("_INVALID", Python.None) }
        return (label, value)
        }).filter { $0.key != "_INVALID" && !$0.key.contains("members") }
        return dictionary
    }

    /// Override this method by copying the signature, prefixed with `override`. See the `OCApp` documentation for an example.
    ///
    /// You must use the `.pythonObject` property after the instance that you wish to return for compatibility with Remi.
    /// If this method is not overridden, it will display a Quit button.
    open func main(_ mainArgs: [PythonObject]) -> PythonObject {
        let label = OCLabel(text: "Override the main method to create a GUI. Copy the example code below to get started.")

        let textArea = OCTextArea()
        textArea.text = """
        override public func main(_ mainArgs: [PythonObject]) -> PythonObject {
            // Set up the GUI. You can refer to class constants and variables.
            let vBox: OCVBox = OCVBox(controls: [
                OCTextField(hint: "Type here"),
                OCButton("OK"), OCButton("Cancel")
            ])

            // Return the control.
            return vBox.pythonObject
        }
        """

        let button = OCButton(text: "Quit")
        button.onClick { _ in mainArgs[0].close() }

        let vBox = OCVBox(controls: [label, textArea, button])
        return vBox.pythonObject
    }
}
