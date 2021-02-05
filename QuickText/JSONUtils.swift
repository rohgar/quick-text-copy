//
//  JSONUtils.swift
//  Quick Text Copy
//
//  Created by Rohit Gargate on 8/11/20.
//  Copyright © 2020 Rovag. All rights reserved.
//

import Foundation

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
            print("Error info: \(error)")
        }
        return nil
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
