import XCTest
import PythonKit

@testable import OCGUI

final class OCGUITests: XCTestCase {
    func testBase() throws {
        class TestApp : OCApp {
            // 1. Label and text field test.
            let label1 = OCLabel(text: "Label:")
            let textField1 = OCTextField(hint: "Type here.")
            let button1 = OCButton(text: "Test label and text field")
            
            // 2. Text area.
            let label2 = OCLabel(text: "Label 2:")
            let textArea2 = OCTextArea(hint: "Type here.")
            
            // 3. Label (hidden, shown), check box (enabled, disabled), and drop-down.
            let label3 = OCLabel(text: "Label 3:")
            let checkBox3 = OCCheckBox(defaultValue: true)
            let dropDown3 = OCDropDown(fromArray: ["1", "2", "3", "4", "5"])
            
            // 4. Pickers
            let colorLabel4 = OCLabel(text: "Color label 4:")
            let colorPicker4 = OCColorPicker()
            let dateLabel4 = OCLabel(text: "Date label 4:")
            let datePicker4 = OCDatePicker()
            
            // 5. Dialog
            let label5 = OCLabel(text: "Label 5:")
            let button5 = OCButton(text: "Show dialog")
            let dialog5 = OCDialog(title: "Dialog", message: "Click Ok or Cancel.")
            let textField5 = OCTextField()
            let datePicker5 = OCDatePicker()
            
            // 6. List view
            let label6 = OCLabel(text: "Label 6:")
            let listView6 = OCListView()
            
            override func main(_ mainArgs: [PythonObject]) -> PythonObject {
                // 1.
                button1.onClick { _ in self.label1.text = self.textField1.text; return Python.None }
                
                // 2.
                textArea2.onChange { _ in self.label2.text = self.textArea2.text; return Python.None }
                
                // 3.
                checkBox3.onChange { _ in self.dropDown3.enabled = self.checkBox3.checked; return Python.None }
                dropDown3.onChange { _ in self.label3.text = self.dropDown3.selectedItem?.text ?? "No value"; return Python.None }
                
                // 4.
                colorPicker4.onChange { _ in self.colorLabel4.text = self.colorPicker4.color; return Python.None }
                datePicker4.onChange { _ in self.dateLabel4.text = self.datePicker4.dateString; return Python.None }
                
                // 5.
                button5.onClick { _ in self.dialog5.show(in: mainArgs[0]); return Python.None }
                dialog5.addField(key: "name", label: "Name:", field: self.textField5)
                dialog5.addField(key: "dateOfBirth", label: "Date of Birth:", field: self.datePicker5)
                dialog5.onCancel { _ in self.label5.text = "Cancelled"; return Python.None }
                dialog5.onConfirm { _ in
                    self.label5.text = "\(self.textField5.text) \(self.datePicker5.dateString)"
                    return Python.None
                }
                
                // 6.
                for i in 1...5 { listView6.append(item: "\(i)") }
                listView6.onChange { _ in self.label6.text = self.listView6.selectedItem?.text ?? "No value"; return Python.None }
                
                
                // Layout.
                let hBox1 = OCHBox(controls: [self.label1, self.textField1, self.button1])
                let vBox2 = OCVBox(controls: [self.label2, self.textArea2])
                let hBox3 = OCHBox(controls: [self.label3, self.checkBox3, self.dropDown3])
                let hBox4 = OCHBox(controls: [self.colorLabel4, self.colorPicker4, self.dateLabel4, self.datePicker4])
                let hBox5 = OCHBox(controls: [self.label5, self.button5])
                let vBox6 = OCVBox(controls: [self.label6, self.listView6])
                
                // Main horizontal box.
                let vBox = OCVBox(controls: [hBox1, vBox2, hBox3, hBox4, hBox5])
                return OCHBox(controls: [vBox, vBox6]).pythonObject
            }
        }
        
        TestApp().start()
    }
}
