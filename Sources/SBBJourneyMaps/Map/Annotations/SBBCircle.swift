//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import MapLibre
import SwiftUI

/// Custom circle
public struct SBBCircle: MapAnnotation {
    public let id: String
    public let coordinates: CLLocationCoordinate2D
    public let minRadius: Int
    public let maxRadius: Int
    public let color: UIColor
    public let disabledColor: UIColor
    public let minZoom: Float
    public let maxZoom: Float
    public let floor: Int?

    var layerName: String { "\(id)_circle_layer" }
    var sourceName: String { "\(id)_circle_source" }

    /// A circle to be rendered on the map.
    /// - Parameters:
    ///   - id: The unique id of the circle.
    ///   - coordinates: The coordinates of the circle.
    ///   - minRadius: The minimum radius, when zoomed out.
    ///   - maxRadius: The maximum radius, when zoomed in.
    ///   - color: The color of the circle.
    ///   - disabledColor: The color of the circle if it has an assigned floor and the current floor is not the same.
    ///   - minZoom: The minimum zoom level at which the circle appears.
    ///   - maxZoom: The maximum zoom level at which the circle appears.
    ///   - floor: The floor level to which the circle belongs, if any.
    public init(
        id: String, coordinates: CLLocationCoordinate2D, minRadius: Int = 10, maxRadius: Int = 20, color: UIColor = .black, disabledColor: UIColor = .gray, minZoom: Float = 0, maxZoom: Float = 24,
        floor: Int? = nil
    ) {
        self.id = id
        self.coordinates = coordinates
        self.minRadius = minRadius
        self.maxRadius = maxRadius
        self.color = color
        self.disabledColor = disabledColor
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.floor = floor
    }

    func deleteFromMapView(_ mapView: MLNMapView) {
        guard let style = mapView.style else { return }

        if let layer = style.layer(withIdentifier: layerName) as? MLNCircleStyleLayer {
            style.removeLayer(layer)
        }
        if let source = style.source(withIdentifier: sourceName) as? MLNShapeSource {
            style.removeSource(source)
        }
    }

    func addToMapView(_ mapView: MLNMapView, floor: Int) {
        guard let style = mapView.style, style.layer(withIdentifier: layerName) as? MLNCircleStyleLayer == nil else { return }

        let point = MLNPointAnnotation()
        point.coordinate = coordinates

        let source = MLNShapeSource(identifier: sourceName, shape: point, options: nil)
        let layer = MLNCircleStyleLayer(identifier: layerName, source: source)

        configureLayer(layer)
        updateLayerVisibility(layer, for: floor)

        style.addSource(source)
        style.addLayer(layer)
    }

    func updateFloor(_ floor: Int, on mapView: MLNMapView) {
        guard let style = mapView.style, let layer = style.layer(withIdentifier: layerName) as? MLNCircleStyleLayer else { return }

        updateLayerVisibility(layer, for: floor)
    }

    private func configureLayer(_ layer: MLNCircleStyleLayer) {
        layer.circleRadius = NSExpression(
            forMLNInterpolating: NSExpression.zoomLevelVariable, curveType: MLNExpressionInterpolationMode.linear, parameters: nil,
            stops: NSExpression(forConstantValue: [14: minRadius, 18: maxRadius]))

        layer.minimumZoomLevel = minZoom
        layer.maximumZoomLevel = maxZoom
    }

    private func updateLayerVisibility(_ layer: MLNCircleStyleLayer, for floor: Int) {
        if let circleFloor = self.floor, circleFloor != floor {
            layer.circleColor = NSExpression(forConstantValue: disabledColor)
        } else {
            layer.circleColor = NSExpression(forConstantValue: color)
        }
    }
}
