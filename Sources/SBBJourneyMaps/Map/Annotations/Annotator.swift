//
// Copyright © 2026 SBB. All rights reserved.
//

import MapLibre

struct Annotator {
    static func updateAnnotations<T: MapAnnotation>(
        _ current: [T],
        to new: [T]?,
        on mapView: MLNMapView,
        withFloor floor: Int
    ) {
        let newAnnotations = new ?? []
        let newIds = Set(newAnnotations.map(\.id))
        let currentIds = Set(current.map(\.id))

        let toRemove = current.filter { !newIds.contains($0.id) }
        toRemove.forEach { $0.deleteFromMapView(mapView) }

        let toAdd = newAnnotations.filter { !currentIds.contains($0.id) }
        toAdd.forEach { $0.addToMapView(mapView, floor: floor) }

        let existing = newAnnotations.filter { currentIds.contains($0.id) }
        existing.forEach { $0.updateFloor(floor, on: mapView) }
    }

    static func updateAnnotations<T: TappableAnnotation>(
        _ current: [T],
        to new: [T]?,
        on mapView: MLNMapView,
        withFloor floor: Int,
        tapAction: @escaping (T.TapData) -> Void
    ) {
        let newAnnotations = new ?? []
        let newIds = Set(newAnnotations.map(\.id))
        let currentIds = Set(current.map(\.id))

        let toRemove = current.filter { !newIds.contains($0.id) }
        toRemove.forEach { $0.deleteFromMapView(mapView) }

        let toAdd = newAnnotations.filter { !currentIds.contains($0.id) }
        toAdd.forEach { $0.addToMapView(mapView, floor: floor, tapAction: tapAction) }

        let existing = newAnnotations.filter { currentIds.contains($0.id) }
        existing.forEach { $0.updateFloor(floor, on: mapView) }
    }

    static func updateFloor<T: MapAnnotation>(
        for annotations: [T],
        to floor: Int,
        on mapView: MLNMapView
    ) {
        let annotationsNeedingUpdate = annotations.filter { annotation in
            annotation.floor != nil
        }

        annotationsNeedingUpdate.forEach { $0.updateFloor(floor, on: mapView) }
    }

    static func maybeTapOn<T: TappableAnnotation>(_ annotations: [T], onPoint point: CGPoint, onMapView mapView: MLNMapView) {
        let layerIdentifiers = annotations.map { $0.layerName }

        for layerIdentifier in layerIdentifiers {
            let featuresInLayer = mapView.visibleFeatures(
                at: point,
                styleLayerIdentifiers: [layerIdentifier]
            )

            if !featuresInLayer.isEmpty {
                TapManager.shared.handleTap(for: layerIdentifier)
                return
            }
        }
    }
}
