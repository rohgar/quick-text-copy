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

class QTCMenuItem: NSMenuItem {
    var qtcValue: String!
}

class QTCBaseObject: NSObject {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    // user defaults
    let menu = NSMenu()
    let userDefaults = UserDefaults.standard
    let KEY_PROPERTY_FILE = "propertyfile"
    var userSelectedFile : String? = nil
    
    override func awakeFromNib() {
        // set the icon
        let icon = NSImage(named: "StatusBarIcon")
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.title = nil
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
    
    @objc func getNewFile(sender: QTCMenuItem) {
        let newFile = QTCUtils.selectFile()
        if let file = newFile {
            initializeMenu(enableItems: true)
            populateMenuFromFile(file)
            userSelectedFile = file
            userDefaults.set(userSelectedFile, forKey: KEY_PROPERTY_FILE)
        }
    }
    
    @objc func refreshFile(sender: QTCMenuItem) {
        initializeMenu(enableItems: true)
        if let file = userSelectedFile {
            populateMenuFromFile(file)
        }
    }
    
    @objc func reset(sender: QTCMenuItem) {
        userSelectedFile = nil
        initializeMenu()
    }
    
    @objc func clickedItem(sender: QTCMenuItem) {
        // copy the item to clipboard
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.writeObjects([sender.qtcValue as NSString])
        // paste by simulating "cmd + v"
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let event1 = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true)
        event1?.flags = CGEventFlags.maskCommand;
        event1?.post(tap: .cghidEventTap)
        let event2 = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
        event2?.flags = CGEventFlags.maskCommand;
        event2?.post(tap: .cghidEventTap)
    }
    
    @objc func aboutApp(sender: QTCMenuItem) -> Bool {
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
    
    @objc func quitApp(sender: QTCMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    // MARK: Private Functions

    private func initializeMenu(enableItems: Bool = false) {
        menu.removeAllItems()
        statusItem.menu = menu
        statusItem.menu!.autoenablesItems = enableItems
        // Load File
        let loadMenuItem = QTCMenuItem(title: "Load File ...", action: #selector(getNewFile), keyEquivalent: "l")
        // Refresh File
        let refreshMenuItem = QTCMenuItem(title: "Refresh ...", action: #selector(refreshFile), keyEquivalent: "r")
        refreshMenuItem.isEnabled = false
        // Clear File
        let clearMenuItem = QTCMenuItem(title: "Clear ...", action: #selector(reset), keyEquivalent: "c")
        clearMenuItem.isEnabled = false
        // separator
        statusItem.menu!.addItem(QTCMenuItem.separator())
        // About
        let aboutMenuItem = QTCMenuItem(title: "About", action: #selector(aboutApp), keyEquivalent: "a")
        // Quit
        let quitMenuItem = QTCMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        
        let items = [loadMenuItem,
                     refreshMenuItem,
                     clearMenuItem,
                     QTCMenuItem.separator(),
                     aboutMenuItem,
                     QTCMenuItem.separator(),
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
                    statusItem.menu!.insertItem(QTCMenuItem.separator(), at: index)
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
                    let item = QTCMenuItem(title: key, action: #selector(clickedItem), keyEquivalent: shortcut)
                    item.qtcValue = value
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
        let jsonData = QTCJSONUtils.readJSONData(fromFile: chosenFile)
        let jsonObject = QTCJSONUtils.decode(jsonData: jsonData!)
        let elements = jsonObject!.elements
        let submenus = jsonObject!.submenus
        
        var shortcutIndex = 0
        for (index, element) in elements.enumerated() {
            let shortcut = (shortcutIndex < 10) ? "" : "\(shortcutIndex)"
            let item = QTCMenuItem(title: element.key, action: #selector(clickedItem), keyEquivalent: shortcut)
            item.qtcValue = element.value
            item.target = self
            statusItem.menu!.insertItem(item, at: index)
            shortcutIndex += 1
        }
        
        for (index, sm) in submenus.enumerated() {
            let menuDropdown = NSMenuItem(title: sm.name, action: nil, keyEquivalent: "")
            menu.insertItem(menuDropdown, at: elements.count + index)
            let submenu = NSMenu()
            for smelement in sm.elements {
                let subItem = QTCMenuItem(title: smelement.key, action: #selector(clickedItem), keyEquivalent: "")
                subItem.qtcValue = smelement.value
                subItem.target = self
                submenu.addItem(subItem)
            }
            menu.setSubmenu(submenu, for: menuDropdown)
        }
        
    }
    
}
