//
// Copyright © 2026 SBB. All rights reserved.
//

import MapLibre

protocol MapAnnotation: Identifiable, Equatable {
    var id: String { get }
    var floor: Int? { get }

    func deleteFromMapView(_ mapView: MLNMapView)
    func addToMapView(_ mapView: MLNMapView, floor: Int)
    func updateFloor(_ floor: Int, on mapView: MLNMapView)
}

protocol TappableAnnotation: MapAnnotation {
    associatedtype TapData
    var layerName: String { get }

    func addToMapView(_ mapView: MLNMapView, floor: Int, tapAction: @escaping (TapData) -> Void)
}
