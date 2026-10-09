//
// Copyright © 2026 SBB. All rights reserved.
//

import MapLibre

struct FloorFilter {
    static func getFloorlist(ofMapView mapView: MLNMapView) -> [Int] {
        guard let servicePointsSource = mapView.style?.source(withIdentifier: "service_points") as? MLNShapeSource else {
            return []
        }

        // In short: Get all features having "floor_liststring" in attributes, and then get this string.
        let floorStrings = servicePointsSource.features(matching: NSPredicate(format: "floor_liststring != NULL")).compactMap({ $0.attribute(forKey: "floor_liststring") as? String })

        // In short: separate floor_liststring (e.g. "-1,0,1,2") from commas and extracting unique floor values.
        var floors: Set<Int> = []
        floorStrings.forEach { floorString in
            let _ = floorString.split(separator: ",").compactMap({ Int(String($0)) }).map({ floors.insert($0) })
        }

        return floors.sorted { $0 > $1 }
    }

    static func replaceAllLvlLayersFloor(_ allLvlLayers: [MLNStyleLayer], withLevel newLevel: Int) {
        allLvlLayers.forEach { layer in
            if let vectLayer = layer as? MLNVectorStyleLayer {
                let oldFilter = vectLayer.predicate?.mgl_jsonExpressionObject
                let newFilter = replaceLayerAndFloorFilter(of: oldFilter as? [Any], withLevel: newLevel)
                
                if !newFilter.isEmpty {
                    let pred = NSPredicate(mglJSONObject: newFilter)
                    vectLayer.predicate = pred
                }
            }
        }
    }
    
    static private func replaceLayerAndFloorFilter(of oldFilter: [Any]?, withLevel level: Int) -> [Any] {
        guard let oldFilter, !oldFilter.isEmpty else {
            return []
        }
        return replaceLayerAndFloorFilter(of: oldFilter, withLevel: level)
    }
    
    static private func replaceLayerAndFloorFilter(of filterExpression: [Any], withLevel level: Int) -> [Any] {
        guard !filterExpression.isEmpty else {
            return []
        }
        
        if let firstExpresison = filterExpression.first as? String {
            switch firstExpresison.lowercased() {
            case "all", "any":
                // there are subexpressions, recursively iterate trough them
                if let subexpressions = Array(filterExpression[1...]) as? [[Any]] {
                    let newExp = subexpressions.map({replaceLayerAndFloorFilter(of: $0, withLevel: level)})
                    return [firstExpresison] + newExp
                }
                return [firstExpresison]
            case "==":
                guard filterExpression.count == 3, let secondExpression = filterExpression[1] as? [Any] else {
                    return filterExpression
                }
                
                let expressionString = MapLibreUtils.jsonString(from: secondExpression)
                if isGetLevelFilter(innerPartString: expressionString) || isCaseLvlFilter(innerPartString: expressionString) || isCaseFloorFilter(innerPartString: expressionString) {
                    return [filterExpression[0], filterExpression[1], level]
                }
            default:
                return filterExpression
            }
        }
        return filterExpression
    }
    
    static private func isCaseLvlFilter(innerPartString: String) -> Bool {
        let filterString =
            """
            ["case",["==",["has","level"],true],["get","level"]
            """
        return innerPartString.hasPrefix(filterString)
    }
    
    static private func isCaseFloorFilter(innerPartString: String) -> Bool {
        let filterString =
            """
            ["case",["==",["has","floor"],true],["get","floor"]
            """
        return innerPartString.hasPrefix(filterString)
    }
    
    static private func isGetLevelFilter(innerPartString: String) -> Bool {
        let filterString =
            """
            ["get","level"]
            """
        return innerPartString.hasPrefix(filterString)
    }
}
