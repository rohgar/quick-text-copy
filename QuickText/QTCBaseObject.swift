//
//  QuickTextMenuBaseController.swift
//  Quick Text
//
//  Created by RohGar on 8/5/17.
//  Copyright © 2017 Rovag. All rights reserved.
//

import Cocoa

class QTCBaseObject: NSObject {
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var userSelectedFile : String? = nil
    
    override func awakeFromNib() {
        let icon = NSImage(named: "StatusBarIcon")
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.title = nil
        intializeStatusItemMenu()
    }
    
    // MARK: Selector Functions
    
    func loadNewFile(sender: NSMenuItem) {
        userSelectedFile = selectFile()
        loadUserSelectedFile(sender: sender)
    }
    
    func loadUserSelectedFile(sender: NSMenuItem) {
        if let file = userSelectedFile {
            intializeStatusItemMenu(allowDisablingItems: true)
            populateMenuFromFile(file)
        }
    }
    
    func reset(sender: NSMenuItem) {
        userSelectedFile = nil
        intializeStatusItemMenu()
    }
    
    func clickedItem(sender: NSMenuItem) {
        let pasteBoard = NSPasteboard.general()
        pasteBoard.clearContents()
        pasteBoard.writeObjects([sender.title as NSString])
    }
    
    func rateApp(sender: NSMenuItem) {
        let appstoreUrl = "https://itunes.apple.com/app/quick-text-copy/id1268494519?action=write-review"
        if let url = URL(string: appstoreUrl), NSWorkspace.shared().open(url) {}
    }
    
    func quitApp(sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    // MARK: Private Functions
    
    private func intializeStatusItemMenu(allowDisablingItems: Bool = false) {
        statusItem.menu = NSMenu()
        statusItem.menu!.autoenablesItems = allowDisablingItems
        // Load File
        let loadMenuItem = NSMenuItem(title: "Load File ...", action: #selector(loadNewFile), keyEquivalent: "l")
        statusItem.menu!.addItem(loadMenuItem)
        // Refresh File
        let refreshMenuItem = NSMenuItem(title: "Refresh loaded file", action: #selector(loadUserSelectedFile), keyEquivalent: "r")
        refreshMenuItem.isEnabled = false
        statusItem.menu!.addItem(refreshMenuItem)
        // Refresh File
        let clearMenuItem = NSMenuItem(title: "Clear loaded file", action: #selector(reset), keyEquivalent: "c")
        clearMenuItem.isEnabled = false
        statusItem.menu!.addItem(clearMenuItem)
        // separator
        statusItem.menu!.addItem(NSMenuItem.separator())
        // Rate
        let rateMenuItem = NSMenuItem(title: "Rate App", action: #selector(rateApp), keyEquivalent: "")
        statusItem.menu!.addItem(rateMenuItem)
        // Quit
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
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
        if (dialog.runModal() == NSModalResponseOK) {
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
        // Read the contents of the file into an array of Strings
        do {
            let content = try NSString(contentsOfFile: chosenFile, encoding: String.Encoding.utf8.rawValue)
            // load the file contents
            let values = content.components(separatedBy: "\n")
            var index = 0
            var shortcutIndex = 0
            // add values from the file
            for _value in values {
                if (_value.isEmpty) {
                    statusItem.menu!.insertItem(NSMenuItem.separator(), at: index)
                } else {
                    var shortcut = ""
                    if (shortcutIndex < 10) {
                        shortcut = "\(shortcutIndex)"
                    }
                    let item = NSMenuItem(title: _value, action: #selector(clickedItem), keyEquivalent: shortcut)
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
