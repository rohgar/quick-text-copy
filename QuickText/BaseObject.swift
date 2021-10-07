//
//  QuickTextMenuBaseController.swift
//  Quick Text
//
//  Created by RohGar on 8/5/17.
//  Copyright © 2017 Rovag. All rights reserved.
//

import Cocoa
import Magnet
import Foundation

class MenuItem: NSMenuItem {
    var val: String!
}

class BaseObject: NSObject {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    // user defaults
    let menu = NSMenu()
    let userDefaults = UserDefaults.standard
    let KEY_PROPERTY_FILE = "propertyfile"
    var userSelectedFile : String? = nil
    
    private let SEPARATOR = "separator"
    
    override func awakeFromNib() {
        // set the icon
        let icon = NSImage(named: "StatusBarIcon")
        icon?.isTemplate = true // best for dark mode
        if let button = statusItem.button {
            button.image = icon
            button.title = ""
        }
        // load the user selected file
        userSelectedFile = userDefaults.string(forKey: KEY_PROPERTY_FILE)
        if let file = userSelectedFile {
            initializeMenu(enableItems: true)
            populateMenuFromFile(file)
        } else {
            initializeMenu()
        }
        // shortcut
        if let keyCombo = KeyCombo(key: .c, carbonModifiers: 768) {
            let hotKey = HotKey(identifier: "CommandShiftC", keyCombo: keyCombo) { hotKey in
                // Called when ⌘ + Shift + C is pressed
                self.menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
            }
            hotKey.register()
        }
    }
    
    // MARK: Selector Functions
    
    @objc func getNewFile(sender: MenuItem) {
        let newFile = Utils.selectFile()
        if let file = newFile {
            initializeMenu(enableItems: true)
            populateMenuFromFile(file)
            userSelectedFile = file
            userDefaults.set(userSelectedFile, forKey: KEY_PROPERTY_FILE)
        }
    }
    
    @objc func refreshFile(sender: MenuItem) {
        initializeMenu(enableItems: true)
        if let file = userSelectedFile {
            populateMenuFromFile(file)
        }
    }
    
    @objc func reset(sender: MenuItem) {
        userSelectedFile = nil
        initializeMenu()
    }
    
    @objc func clickedItem(sender: MenuItem) {
        // copy the item to clipboard
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.writeObjects([sender.val as NSString])
        // paste by simulating "cmd + v"
        print(0x09)
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let event1 = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true)
        event1?.flags = CGEventFlags.maskCommand;
        event1?.post(tap: .cghidEventTap)
        let event2 = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
        event2?.flags = CGEventFlags.maskCommand;
        event2?.post(tap: .cghidEventTap)
        print("Done")
    }
    
    @objc func aboutApp(sender: MenuItem) -> Bool {
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let alert: NSAlert = NSAlert()
        alert.messageText = "Quick Text Copy"
        if let version = appVersion {
            alert.informativeText = "Version " + version
        }
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    @objc func quitApp(sender: MenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    // MARK: Private Functions

    private func initializeMenu(enableItems: Bool = false) {
        menu.removeAllItems()
        statusItem.menu = menu
        statusItem.menu!.autoenablesItems = enableItems
        // Load File
        let loadMenuItem = MenuItem(title: "Load File ...", action: #selector(getNewFile), keyEquivalent: "l")
        // Refresh File
        let refreshMenuItem = MenuItem(title: "Refresh ...", action: #selector(refreshFile), keyEquivalent: "r")
        refreshMenuItem.isEnabled = false
        // Clear File
        let clearMenuItem = MenuItem(title: "Clear ...", action: #selector(reset), keyEquivalent: "c")
        clearMenuItem.isEnabled = false
        // separator
        statusItem.menu!.addItem(MenuItem.separator())
        // About
        let aboutMenuItem = MenuItem(title: "About", action: #selector(aboutApp), keyEquivalent: "a")
        // Quit
        let quitMenuItem = MenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        
        let items = [loadMenuItem,
                     refreshMenuItem,
                     clearMenuItem,
                     MenuItem.separator(),
                     aboutMenuItem,
                     MenuItem.separator(),
                     quitMenuItem]
        for item in items {
            statusItem.menu!.addItem(item)
        }
        
        for item in statusItem.menu!.items {
            item.target = self
        }
    }
    
    private func populateMenuFromFile(_ chosenFile: String) {
        let splitArray = chosenFile.split(separator: ".")
        let fileExtension = splitArray[splitArray.count - 1]
        switch fileExtension {
        case "properties":
            populateMenuFromPropertiesFile(chosenFile)
        case "json":
            populateMenuFromJSONfile(chosenFile)
        default:
            populateMenuFromPropertiesFile(chosenFile)
        }
    }
    
    // Assumes that the user did select a file
    private func populateMenuFromPropertiesFile(_ chosenFile: String) {
        var isPropertyFile = false;
        if (chosenFile.hasSuffix("properties")) {
            isPropertyFile = true
        }
        // Read the contents of the file into an array of Strings
        do {
            let content = try NSString(contentsOfFile: chosenFile, encoding: String.Encoding.utf8.rawValue)
            // load the file contents
            let lines = content.components(separatedBy: "\n")
            var index = 0
            var shortcutIndex = 0
            // add values from the file
            for _line in lines {
                if (_line.isEmpty) {
                    statusItem.menu!.insertItem(MenuItem.separator(), at: index)
                } else {
                    
                    var shortcut = ""
                    if (shortcutIndex < 10) {
                        shortcut = "\(shortcutIndex)"
                    }
                    var key : String
                    var value : String
                    if (isPropertyFile) {
                        let _keyval = _line.split(separator: "=", maxSplits: 1)
                        let onlyKeyPresent = (_keyval.count == 1)
                        key = String(_keyval[0])
                        value = onlyKeyPresent ? key : String(_keyval[1])
                    } else {
                        key = _line
                        value = key
                    }
                    let item = MenuItem(title: key, action: #selector(clickedItem), keyEquivalent: shortcut)
                    item.val = value
                    item.target = self
                    statusItem.menu!.insertItem(item, at: index)
                    shortcutIndex += 1
                }
                index += 1
            }
            // add separator
            statusItem.menu!.insertItem(NSMenuItem.separator(), at: index)
        }
        catch {
            let nsError = error as NSError
            print(nsError.localizedDescription)
        }
    }
    
    private func populateMenuFromJSONfile(_ chosenFile: String)  {
        let jsonData = JSONUtils.readJSONData(fromFile: chosenFile)
        if let jsonObject = JSONUtils.decode(jsonData: jsonData!) {
        
            let elements = jsonObject.elements
            let submenus = jsonObject.submenus
            
            var shortcutIndex = 0
            for (index, element) in elements.enumerated() {
                if (element.key == SEPARATOR) {
                    statusItem.menu!.insertItem(MenuItem.separator(), at: index)
                } else {
                    let shortcut = (shortcutIndex < 10) ? "" : "\(shortcutIndex)"
                    let item = MenuItem(title: element.key, action: #selector(clickedItem), keyEquivalent: shortcut)
                    item.val = element.value
                    item.target = self
                    statusItem.menu!.insertItem(item, at: index)
                    shortcutIndex += 1
                }
            }
            
            for (index, sm) in submenus.enumerated() {
                let menuDropdown = NSMenuItem(title: sm.name, action: nil, keyEquivalent: "")
                menu.insertItem(menuDropdown, at: elements.count + index)
                let submenu = NSMenu()
                for smelement in sm.elements {
                    if (smelement.key == SEPARATOR) {
                        statusItem.menu!.insertItem(MenuItem.separator(), at: index)
                    } else {
                        let subItem = MenuItem(title: smelement.key, action: #selector(clickedItem), keyEquivalent: "")
                        subItem.val = smelement.value
                        subItem.target = self
                        submenu.addItem(subItem)
                    }
                }
                menu.setSubmenu(submenu, for: menuDropdown)
            }
        } else {
            let alert = NSAlert.init()
            alert.messageText = "JSON Error!"
            alert.informativeText = "There was an error while reading JSON content, please verify that your input JSON file is valid."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        
    }
    
}
