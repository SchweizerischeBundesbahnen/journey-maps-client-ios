//
// Copyright © 2026 SBB. All rights reserved.
//

import MapLibre

struct POIAnnotator {

    // take same saming as in Flutter code
    static let rokasHighlightedPoiLayerId = "journey-pois-first"
    static let rokasBaseLvlPoiClickableLayerId = "journey-pois-second-lvl"
    static let rokasBaseLvlPoiNonClickableLayerId = "journey-pois-third-lvl"
    static let rokasBasePoiClickableLayerId = "journey-pois-second-2d"

    static func updatePOICategories(to categories: [SBBPoiCategoryType], on mapView: MLNMapView) {
        for layerId in [rokasBaseLvlPoiClickableLayerId, rokasHighlightedPoiLayerId] {
            if let layer = mapView.style?.layer(withIdentifier: layerId) as? MLNSymbolStyleLayer {
                let predicates = categories.map { subCategory in
                    NSPredicate(format: "subCategory == '\(subCategory.rawValue)'")
                }
                let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                layer.predicate = predicate
            }
        }
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
