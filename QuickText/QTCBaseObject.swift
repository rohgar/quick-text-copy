//
//  QuickTextMenuBaseController.swift
//  Quick Text
//
//  Created by RohGar on 8/5/17.
//  Copyright © 2017 Rovag. All rights reserved.
//

import Cocoa

class QTCMenuItem: NSMenuItem {
    var qtcValue: String!
}

class QTCBaseObject: NSObject {
    
    @objc let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    @objc var userSelectedFile : String? = nil
    
    override func awakeFromNib() {
        let icon = NSImage(named: "StatusBarIcon")
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.title = nil
        intializeStatusItemMenu()
    }
    
    // MARK: Selector Functions
    
    @objc func loadNewFile(sender: QTCMenuItem) {
        userSelectedFile = selectFile()
        loadUserSelectedFile(sender: sender)
    }
    
    @objc func loadUserSelectedFile(sender: QTCMenuItem) {
        if let file = userSelectedFile {
            intializeStatusItemMenu(allowDisablingItems: true)
            populateMenuFromFile(file)
        }
    }
    
    @objc func reset(sender: QTCMenuItem) {
        userSelectedFile = nil
        intializeStatusItemMenu()
    }
    
    @objc func clickedItem(sender: QTCMenuItem) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.writeObjects([sender.qtcValue as NSString])
    }
    
    @objc func quitApp(sender: QTCMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    // MARK: Private Functions
    
    private func intializeStatusItemMenu(allowDisablingItems: Bool = false) {
        statusItem.menu = NSMenu()
        statusItem.menu!.autoenablesItems = allowDisablingItems
        // Load File
        let loadMenuItem = QTCMenuItem(title: "Load File ...", action: #selector(loadNewFile), keyEquivalent: "l")
        statusItem.menu!.addItem(loadMenuItem)
        // Refresh File
        let refreshMenuItem = QTCMenuItem(title: "Refresh loaded file", action: #selector(loadUserSelectedFile), keyEquivalent: "r")
        refreshMenuItem.isEnabled = false
        statusItem.menu!.addItem(refreshMenuItem)
        // Refresh File
        let clearMenuItem = QTCMenuItem(title: "Clear loaded file", action: #selector(reset), keyEquivalent: "c")
        clearMenuItem.isEnabled = false
        statusItem.menu!.addItem(clearMenuItem)
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
