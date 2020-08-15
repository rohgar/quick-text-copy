//
//  QTCUtils.swift
//  Quick Text Copy
//
//  Created by Rohit Gargate on 3/3/19.
//  Copyright © 2019 Rovag. All rights reserved.
//

import Cocoa

class QTCUtils {
    
    static func selectFile() -> String? {
        // Let the user select the file
        let dialog = NSOpenPanel()
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["","txt","log","properties", "json"]
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
    
    static func removeExtension(filename: String) -> String {
        var name = filename
        if (name.contains(".")) {
            var array = name.split(separator: ".")
            array.remove(at: array.count - 1)
            name = array.joined()
        }
        return name
    }
    
}
