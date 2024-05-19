import XCTest
import PythonKit

@testable import OCGUI

final class OCGUITests: XCTestCase {
    func testBase() throws {
        class TestApp : OCApp {
            static let menu = ["Sandwich": 3.0, "Drink": 1.5, "Fruit": 2.0, "Ice block": 3.5]

            let dayDropdown = OCDropDown(fromArray: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
            let menuListView = OCListView()
            let master = OCVBox(controls: [])
            let detail = OCVBox(controls: [])
            let imageWell = OCImageView(filename: "~/test.png")
            let addButton = OCButton(text: "+")
            let quantityLabel = OCLabel(text: "0")
            let removeButton = OCButton(text: "-")
            let addRemoveBox = OCVBox(controls: [], justifyContent: .spaceBetween)

            override func main(app: any OCAppDelegate) -> OCControl {
                for itemName in TestApp.menu.keys {
                    self.menuListView.append(item: itemName)
                }

                self.dayDropdown.enabled = false
                self.master.append(control: dayDropdown)
                self.master.append(control: menuListView)

                self.menuListView.onChange { listView, selectedItem in
                    // self.imageWell.filename = "\(selectedItem.text).png"
                }

                self.addButton.width = OCSize.percent(100)
                self.removeButton.width = OCSize.percent(100)
                self.addRemoveBox.append(control: self.quantityLabel)
                self.addRemoveBox.append(control: self.addButton)
                self.addRemoveBox.append(control: self.removeButton)
                self.detail.append(control: imageWell)
                self.detail.append(control: addRemoveBox)
                
                let userInterface = OCHBox(controls: [
                    master, detail
                ])

                return userInterface
            }
        }

        TestApp().start()
    }
}
