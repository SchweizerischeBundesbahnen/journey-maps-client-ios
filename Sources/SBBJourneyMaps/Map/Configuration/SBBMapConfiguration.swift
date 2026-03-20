//
// Copyright © 2026 SBB. All rights reserved.
//

import Foundation
import MapLibre

/// Configuration for the Map View
public struct SBBMapConfiguration {
    let pitchEnabled: Bool
    let rotateEnabled: Bool
    let showsUserLocation: Bool
    let showsScale: Bool
    let scaleBarUsesMetricSystem: Bool
    let zoomEnabled: Bool
    let scrollEnabled: Bool
    let poiCategories: [SBBPoiCategoryType]
    let accessibilityText: String?

    /// Configures the Map View
    /// - Parameters:
    ///   - pitchEnabled: default true
    ///   - rotateEnabled: default true
    ///   - showsUserLocation: default true. Displays the blue user location pin. Needs the Locaton permission.
    ///   - showsScale: default false
    ///   - scaleBarUsesMetricSystem: default true
    ///   - zoomEnabled: default true
    ///   - scrollEnabled: default true
    ///   - poiCategores: Poi Categories to display on map
    public init(
        pitchEnabled: Bool = true,
        rotateEnabled: Bool = true,
        showsUserLocation: Bool = true,
        showsScale: Bool = false,
        scaleBarUsesMetricSystem: Bool = true,
        zoomEnabled: Bool = true,
        scrollEnabled: Bool = true,
        poiCategories: [SBBPoiCategoryType] = SBBPoiCategoryType.allCases,
        accessibilityText: String? = nil
    ) {
        self.pitchEnabled = pitchEnabled
        self.rotateEnabled = rotateEnabled
        self.showsUserLocation = showsUserLocation
        self.showsScale = showsScale
        self.scaleBarUsesMetricSystem = scaleBarUsesMetricSystem
        self.zoomEnabled = zoomEnabled
        self.scrollEnabled = scrollEnabled
        self.poiCategories = poiCategories
        self.accessibilityText = accessibilityText
    }

    func apply(on mapView: MLNMapView) {
        mapView.isPitchEnabled = pitchEnabled
        mapView.isRotateEnabled = rotateEnabled
        mapView.showsUserLocation = showsUserLocation
        mapView.showsScale = showsScale
        mapView.scaleBarUsesMetricSystem = scaleBarUsesMetricSystem
        mapView.isZoomEnabled = zoomEnabled
        mapView.isScrollEnabled = scrollEnabled
    }
}
