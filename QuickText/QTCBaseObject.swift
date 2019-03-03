//
//  QuickTextMenuBaseController.swift
//  Quick Text
//
//  Created by RohGar on 8/5/17.
//  Copyright © 2017 Rovag. All rights reserved.
//

import Cocoa
import Magnet

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
        loadUserSelectedFile()
        // shortcut
        if let keyCombo = KeyCombo(keyCode: 8, carbonModifiers: 768) {
            let hotKey = HotKey(identifier: "CommandShiftC", keyCombo: keyCombo) { hotKey in
                // Called when ⌘ + Shift + C is pressed
                self.menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
            }
            hotKey.register()
        }
    }
    
    func loadUserSelectedFile() {
        if let file = userSelectedFile {
            intializeStatusItemMenu(allowDisablingItems: true)
            populateMenuFromFile(file)
        } else {
            intializeStatusItemMenu()
        }
    }
    
    // MARK: Selector Functions
    
    @objc func getNewFile(sender: QTCMenuItem) {
        userSelectedFile = selectFile()
        userDefaults.set(userSelectedFile, forKey: KEY_PROPERTY_FILE)
        loadUserSelectedFile()
    }
    
    @objc func refreshFile(sender: QTCMenuItem) {
        loadUserSelectedFile()
    }
    
    @objc func reset(sender: QTCMenuItem) {
        userSelectedFile = nil
        intializeStatusItemMenu()
    }
    
    @objc func clickedItem(sender: QTCMenuItem) {
        // copy the item to clipboard
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.writeObjects([sender.qtcValue as NSString])
        // paste
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
    
    private func intializeStatusItemMenu(allowDisablingItems: Bool = false) {
        statusItem.menu = menu
        statusItem.menu!.autoenablesItems = allowDisablingItems
        // Load File
        let loadMenuItem = QTCMenuItem(title: "Load File ...", action: #selector(getNewFile), keyEquivalent: "l")
        statusItem.menu!.addItem(loadMenuItem)
        // Refresh File
        let refreshMenuItem = QTCMenuItem(title: "Refresh loaded file", action: #selector(refreshFile), keyEquivalent: "r")
        refreshMenuItem.isEnabled = false
        statusItem.menu!.addItem(refreshMenuItem)
        // Refresh File
        let clearMenuItem = QTCMenuItem(title: "Clear loaded file", action: #selector(reset), keyEquivalent: "c")
        clearMenuItem.isEnabled = false
        statusItem.menu!.addItem(clearMenuItem)
        // separator
        statusItem.menu!.addItem(QTCMenuItem.separator())
        // About
        let aboutMenuItem = QTCMenuItem(title: "About", action: #selector(aboutApp), keyEquivalent: "q")
        statusItem.menu!.addItem(aboutMenuItem)
        // separator
        statusItem.menu!.addItem(QTCMenuItem.separator())
        // Quit
        let quitMenuItem = QTCMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        statusItem.menu!.addItem(quitMenuItem)
        
        for item in statusItem.menu!.items {
            item.target = self
        }
    }
    
    private func selectFile() -> String? {
        // Let the user select the file
        let dialog = NSOpenPanel()
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["","txt","log","properties"]
        var chosenFile = ""
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let selection = dialog.url
            if let _selection = selection {
                chosenFile = _selection.path
            }
        } else {
            return nil
        }
        return chosenFile
    }
    
    // Assumes that the user did select a file
    private func populateMenuFromFile(_ chosenFile: String) {
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
    
}
