//
// Copyright © 2026 SBB. All rights reserved.
//

import MapLibre

struct POIAnnotator {

    // take same as in Flutter code
    static let rokasHighlightedPoiLayerId = "journey-pois-first"
    static let rokasBaseLvlPoiClickableLayerId = "journey-pois-second-lvl"
    static let rokasBaseLvlPoiNonClickableLayerId = "journey-pois-third-lvl"
    static let rokasBasePoiClickableLayerId = "journey-pois-second-2d"

    static func updatePOICategories(to categories: [SBBPoiCategoryType], on mapView: MLNMapView) {
        for layerId in [rokasBaseLvlPoiClickableLayerId, rokasHighlightedPoiLayerId] {
            if let layer = mapView.style?.layer(withIdentifier: layerId) as? MLNSymbolStyleLayer {
                
                let existingFilter = layer.predicate?.mgl_jsonExpressionObject as? [Any] ?? []
                let newFilter = setPoiCategories(of: existingFilter, withCategories: categories.map({$0.rawValue}))
                
                layer.predicate = NSPredicate(mglJSONObject: newFilter)
            }
        }
    }
    
    static private func setPoiCategories(of filterExpression: [Any], withCategories categories: [String]) -> [Any] {
        let filterExpressionString = MapLibreUtils.jsonString(from: filterExpression)
        if hasGetSubCategory(filterExpressionString) {
            return replaceExistingPoiCategories(of: filterExpression, withCategories: categories)
        } else {
            return insertNewPoiCategories(of: filterExpression, withCategories: categories)
        }
    }
    
    static private func insertNewPoiCategories(of filterExpression: [Any], withCategories categories: [String]) -> [Any] {
        
        let newCategorieExpression: [Any] = [
            "in",
            ["get", "subCategory"],
            ["literal", categories]
        ]
        
        guard !filterExpression.isEmpty else {
            return newCategorieExpression
        }
        
        if let firstExpresison = filterExpression.first as? String {
            switch firstExpresison.lowercased() {
            case "all":
                return [firstExpresison] + [newCategorieExpression] + Array(filterExpression[1...])
            default:
                return ["all", newCategorieExpression, filterExpression]
            }
        }
        return filterExpression
    }
    
    static private func replaceExistingPoiCategories(of filterExpression: [Any], withCategories categories: [String]) -> [Any] {
        
        if let firstExpresison = filterExpression.first as? String {
            switch firstExpresison.lowercased() {
            case "all", "any":
                // there are subexpressions, recursively iterate trough them
                if let subexpressions = Array(filterExpression[1...]) as? [[Any]] {
                    let newExp = subexpressions.map({replaceExistingPoiCategories(of: $0, withCategories: categories)})
                    return [firstExpresison] + newExp
                }
                return [firstExpresison]
            case "in":
                guard filterExpression.count == 3, let secondExpression = filterExpression[1] as? [Any] else {
                    return filterExpression
                }
                
                let expressionString = MapLibreUtils.jsonString(from: secondExpression)
                if isGetSubCategory(expressionString) {
                    return [filterExpression[0], filterExpression[1], literalArray(of: categories)]
                }
            default:
                return filterExpression
            }
        }
        return filterExpression
    }
    
    static private func hasGetSubCategory(_ expression: String) -> Bool {
        let getSubCategoryExpression =
        """
        ["in",["get","subCategory"]
        """
        return expression.contains(getSubCategoryExpression)
    }
    
    static private func isGetSubCategory(_ expression: String) -> Bool {
        let getSubCategoryExpression =
        """
        ["get","subCategory"]
        """
        return getSubCategoryExpression == expression
    }
    
    static private func literalArray(of categories: [String]) -> String {
        """
        ["literal", [\(categories.map({"\"\($0)\""}).joined(separator: ","))]]
        """
    }

    static func selectNearestPoi(onCoordinate coord: CLLocationCoordinate2D, onMapView mapView: MLNMapView, callback: ((SBBMapPoi) -> Void)?) {
        let point = mapView.convert(coord, toPointTo: mapView)
        let featuresPois = mapView.visibleFeatures(at: point, styleLayerIdentifiers: [rokasBaseLvlPoiClickableLayerId])

        let sortedByDistance = featuresPois.sorted { p1, p2 in
            return p1.coordinate.distance(from: coord) <= p2.coordinate.distance(from: coord)
        }
        select(feature: sortedByDistance.first, onMapView: mapView, callback: callback)
    }

    static func selectNearestPoi(onPoint point: CGPoint, onMapView mapView: MLNMapView, callback: ((SBBMapPoi) -> Void)?) {
        let featuresPois = mapView.visibleFeatures(at: point, styleLayerIdentifiers: [rokasBaseLvlPoiClickableLayerId])

        let coord = mapView.convert(point, toCoordinateFrom: mapView)
        let sortedByDistance = featuresPois.sorted { p1, p2 in
            return p1.coordinate.distance(from: coord) <= p2.coordinate.distance(from: coord)
        }
        select(feature: sortedByDistance.first, onMapView: mapView, callback: callback)
    }

    static func deselectAllPois(onMapView mapView: MLNMapView, callback: (() -> Void)?) {
        for layerId in [rokasBaseLvlPoiClickableLayerId] {
            if let layer = mapView.style?.layer(withIdentifier: layerId) as? MLNSymbolStyleLayer {
                layer.isVisible = true
                layer.iconOpacity = NSExpression(forConstantValue: 1)
            }
        }
        for layerId in [rokasHighlightedPoiLayerId, rokasBaseLvlPoiNonClickableLayerId, rokasBasePoiClickableLayerId] {
            if let layer = mapView.style?.layer(withIdentifier: layerId) as? MLNSymbolStyleLayer {
                layer.isVisible = false
                layer.iconOpacity = NSExpression(forConstantValue: 1)
            }
        }
        callback?()
    }

    static func select(feature: MLNFeature?, onMapView mapView: MLNMapView, callback: ((SBBMapPoi) -> Void)?) {
        guard let pointFeature = feature else { return }
        let attributes = pointFeature.attributes.compactMapValues({ $0 as? String })
        let poiId = attributes["sbbId"] ?? ""
        displaySelectedPoid(withId: poiId, onMapView: mapView)
        callback?(SBBMapPoi(coordinate: pointFeature.coordinate, attributes: attributes))
    }

    static private func displaySelectedPoid(withId poiId: String, onMapView mapView: MLNMapView) {
        if let layer = mapView.style?.layer(withIdentifier: rokasHighlightedPoiLayerId) as? MLNSymbolStyleLayer {
            layer.isVisible = true

            let isSelectedPoi = NSPredicate(format: "%K == '\(poiId)'", "sbbId")
            let enabled = NSExpression(forConstantValue: 1)
            let disabled = NSExpression(forConstantValue: 0)
            let setTrueOnSelectedPoi = NSExpression.init(forConditional: isSelectedPoi, trueExpression: enabled, falseExpression: disabled)

            layer.iconOpacity = setTrueOnSelectedPoi
        }

        if let layer = mapView.style?.layer(withIdentifier: rokasBaseLvlPoiClickableLayerId) as? MLNSymbolStyleLayer {
            layer.isVisible = true

            let isSelectedPoi = NSPredicate(format: "%K == '\(poiId)'", "sbbId")
            let enabled = NSExpression(forConstantValue: 1)
            let disabled = NSExpression(forConstantValue: 0)
            let setFalseOnSelectedPoi = NSExpression.init(forConditional: isSelectedPoi, trueExpression: disabled, falseExpression: enabled)

            layer.iconOpacity = setFalseOnSelectedPoi
        }
    }
}
