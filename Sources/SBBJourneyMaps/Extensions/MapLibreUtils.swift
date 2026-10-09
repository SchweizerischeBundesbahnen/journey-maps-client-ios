// 
// Copyright © Schweizerische Bundesbahnen SBB, 2026
// 

import Foundation

internal struct MapLibreUtils {
    static func jsonString(from input: Any) -> String {
        if let str = input as? String {
            return str
        }
        if let str = input as? Int {
            return "\(str)"
        }
        if let str = input as? Double {
            return "\(str)"
        }
        if let data = try? JSONSerialization.data(withJSONObject: input, options: []) {
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        }
        return ""
    }
}
