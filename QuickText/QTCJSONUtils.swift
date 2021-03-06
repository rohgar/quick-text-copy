//
//  QTCJSONUtils.swift
//  Quick Text Copy
//
//  Created by Rohit Gargate on 8/11/20.
//  Copyright © 2020 Rovag. All rights reserved.
//

import Foundation

struct QTCJSONElement: Codable {
    let key: String
    let value: String
}

struct QTCJSONSubmenu: Codable {
    let name: String
    let elements: [QTCJSONElement]
}

struct QTCJSONObject: Codable {
    let elements: [QTCJSONElement]
    let submenus: [QTCJSONSubmenu]
}

class QTCJSONUtils {
    
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

    static func decode(jsonData: Data) -> QTCJSONObject? {
        do {
            let jsonObject = try JSONDecoder().decode(QTCJSONObject.self, from: jsonData)
            return jsonObject
        } catch {
            print("Error info: \(error)")
        }
        return nil
    }
    
}
