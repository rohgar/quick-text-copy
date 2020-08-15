//
//  QTCJSONUtils.swift
//  Quick Text Copy
//
//  Created by Rohit Gargate on 8/11/20.
//  Copyright © 2020 Rovag. All rights reserved.
//

import Foundation

struct QTCJSONMenuItem: Codable {
    let key: String
    let value: String
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

    static func decode(jsonData: Data) -> [QTCJSONMenuItem]? {
        do {
            let items = try JSONDecoder().decode([QTCJSONMenuItem].self, from: jsonData)
            return items
        } catch {
            print("Error info: \(error)")
        }
        return nil
    }
    
}
