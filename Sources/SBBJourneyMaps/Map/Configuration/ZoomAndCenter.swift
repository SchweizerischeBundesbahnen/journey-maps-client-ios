//
// Copyright © 2026 SBB. All rights reserved.
//

import MapLibre

struct ZoomAndCenter {
    static func increaseZoom(_ mapView: MLNMapView) {
        mapView.setZoomLevel(mapView.zoomLevel + 1, animated: true)
    }

    static func decreaseZoom(_ mapView: MLNMapView) {
        mapView.setZoomLevel(mapView.zoomLevel - 1, animated: true)
    }

    static func centerToCurrentLocation(onMapView mapView: MLNMapView) {
        if let userLocation = mapView.userLocation?.location {
            mapView.setCenter(userLocation.coordinate, animated: true)
        }
    }

    static func center(toPosition position: CLLocationCoordinate2D, zoomLevel: Double, selectUnderlyingPoi: Bool = false, onMapView mapView: MLNMapView, callback: ((SBBMapPoi) -> Void)? = nil) {
        mapView.setCenter(position, zoomLevel: zoomLevel, direction: -1, animated: true) {
            if selectUnderlyingPoi {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    POIAnnotator.selectNearestPoi(onCoordinate: position, onMapView: mapView, callback: callback)
                }
            }
        }
    }

    static func center(to bounds: MLNCoordinateBounds, onMapView mapView: MLNMapView) {
        let camera = mapView.camera(mapView.camera, fitting: bounds, edgePadding: UIEdgeInsets.zero)
        mapView.setCamera(camera, animated: true)
    }
}
