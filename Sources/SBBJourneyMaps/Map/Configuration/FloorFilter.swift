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
                let newFilter = calculateLayerFilter(oldFilter: oldFilter as? [Any], level: newLevel)
                if !newFilter.isEmpty {
                    let pred = NSPredicate(mglJSONObject: newFilter)
                    vectLayer.predicate = pred
                }
            }
        }
    }

    static private func calculateLayerFilter(oldFilter: [Any]?, level: Int) -> [Any] {
        guard let oldFilter, !oldFilter.isEmpty else {
            return []
        }

        var newFilter: [Any] = []
        newFilter.append(oldFilter.first!)

        var floorFound = false

        for i in 1...oldFilter.count - 1 {
            if let item = oldFilter[i] as? String, isFloorFilter(innerPartString: item) {
                // "floor" in "rokas_indoor" and "geojson_walk" layers
                floorFound = true
                newFilter.append(item)
            } else if let item = oldFilter[i] as? [Any], !item.isEmpty {
                var levelFound = false
                var newInnerPart = [item.first!]

                for j in 1...item.count - 1 {
                    let innerPart = item[j]
                    let innerPartString = jsonEncode(input: innerPart)
                    if isCaseLvlFilter(innerPartString: innerPartString) {
                        levelFound = true
                        newInnerPart.append(innerPart)
                    } else if isFloorFilter(innerPartString: innerPartString) {
                        levelFound = true
                        // when filter: ['==', ['get','floor'], 0]
                        floorFound = true
                        newInnerPart.append(innerPart)
                    } else if levelFound {
                        levelFound = false
                        newInnerPart.append(level)
                    } else {
                        newInnerPart.append(innerPart)
                    }
                }
                newFilter.append(newInnerPart)
            } else if floorFound {
                floorFound = false
                newFilter.append(level)
            } else {
                newFilter.append(oldFilter[i])
            }
        }

        return newFilter
    }

    static private func jsonEncode(input: Any) -> String {
        if let str = input as? String {
            return str
        }
        if let str = input as? Int {
            return "\(str)"
        }
        if let data = try? JSONSerialization.data(withJSONObject: input, options: []) {
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        }
        return ""
    }

    static private func isCaseLvlFilter(innerPartString: String) -> Bool {
        let filterString =
            """
            ["case",["==",["has","level"],true],["get","level"]
            """
        return innerPartString.hasPrefix(filterString)
    }

    static private func isFloorFilter(innerPartString: String) -> Bool {
        return innerPartString.contains("floor")
    }
}
