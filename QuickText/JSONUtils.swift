//
//  JSONUtils.swift
//  Quick Text Copy
//
//  Created by Rohit Gargate on 8/11/20.
//  Copyright © 2020 Rovag. All rights reserved.
//

import Foundation
import Cocoa

struct JSONElement: Codable {
    let key: String
    let value: String
}

struct JSONSubmenu: Codable {
    let name: String
    let elements: [JSONElement]
}

struct JSONObject: Codable {
    let elements: [JSONElement]
    let submenus: [JSONSubmenu]
}

class JSONUtils {
    
    static func readJSONData(fromFile file: String) -> Data? {
        do {
            if let jsonData = try String(contentsOfFile: file).data(using: .utf8) {
                return jsonData
            }
        } catch {
            let alert = NSAlert.init()
            alert.messageText = "JSON Error!"
            alert.informativeText = "There was an error while reading JSON content, please verify that your input JSON file is valid."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        let jsonData = String("{}").data(using: .utf8)
        return jsonData
    }

    static func decode(jsonData: Data) -> JSONObject? {
        do {
            let jsonObject = try JSONDecoder().decode(JSONObject.self, from: jsonData)
            return jsonObject
        } catch {
            print("Error info: \(error)")
        }
        return nil
    }
    
}
