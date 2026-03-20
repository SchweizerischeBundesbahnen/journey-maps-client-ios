//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import MapLibre
import SwiftUI

public struct SBBMarker: MapAnnotation {

    public let id: String
    public let coordinates: CLLocationCoordinate2D
    public let image: UIImage
    public let color: UIColor?
    public let disabledColor: UIColor?
    public let minScale: Float
    public let maxScale: Float
    public let minZoom: Float
    public let maxZoom: Float
    public let floor: Int?

    var layerName: String { "\(id)_marker_layer" }
    var sourceName: String { "\(id)_marker_source" }
    var imageName: String { "\(id)_marker_image" }

    /// A marker to be rendered on the map.
    /// - Parameters:
    ///   - id: The unique id of the marker.
    ///   - coordinates: The coordinates of the marker.
    ///   - image: The UIImage to use for the marker.
    ///   - color: The  optional color of the marker.
    ///   - disabledColor: The optional color of the marker if it has an assigned floor and the current floor is not the same. If nil, the marker won't be shown if disabled.
    ///   - minZoom: The minimum zoom level at which the marker appears.
    ///   - maxZoom: The maximum zoom level at which the marker appears.
    ///   - floor: The floor level to which the marker belongs, if any.
    public init(
        id: String, coordinates: CLLocationCoordinate2D, image: UIImage, color: UIColor? = nil, disabledColor: UIColor? = nil, minScale: Float = 1.0, maxScale: Float = 1.0, minZoom: Float = 0,
        maxZoom: Float = 24, floor: Int? = nil
    ) {
        self.id = id
        self.coordinates = coordinates
        self.color = color
        self.disabledColor = disabledColor
        self.minScale = minScale
        self.maxScale = maxScale
        self.image = color != nil ? image.withTintColor(color!, renderingMode: .alwaysTemplate) : image.withRenderingMode(.alwaysOriginal)
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.floor = floor
    }

    func deleteFromMapView(_ mapView: MLNMapView) {
        guard let style = mapView.style else { return }

        if let layer = style.layer(withIdentifier: layerName) as? MLNSymbolStyleLayer {
            style.removeLayer(layer)
        }
        if let source = style.source(withIdentifier: sourceName) as? MLNShapeSource {
            style.removeSource(source)
        }
    }

    func addToMapView(_ mapView: MLNMapView, floor: Int) {
        guard let style = mapView.style, style.layer(withIdentifier: layerName) as? MLNSymbolStyleLayer == nil else { return }

        let point = MLNPointAnnotation()
        point.coordinate = coordinates

        let source = MLNShapeSource(identifier: sourceName, shape: point, options: nil)
        let layer = MLNSymbolStyleLayer(identifier: layerName, source: source)
        style.setImage(image, forName: imageName)

        configureLayer(layer)
        updateLayerVisibility(layer, for: floor)

        style.addSource(source)
        style.addLayer(layer)
    }

    func updateFloor(_ floor: Int, on mapView: MLNMapView) {
        guard let style = mapView.style, let layer = style.layer(withIdentifier: layerName) as? MLNSymbolStyleLayer else { return }

        updateLayerVisibility(layer, for: floor)
    }

    private func configureLayer(_ layer: MLNSymbolStyleLayer) {
        layer.iconImageName = NSExpression(forConstantValue: imageName)

        layer.iconScale = NSExpression(
            forMLNInterpolating: NSExpression.zoomLevelVariable,
            curveType: MLNExpressionInterpolationMode.linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: [14: minScale, 18: maxScale]))

        layer.minimumZoomLevel = minZoom
        layer.maximumZoomLevel = maxZoom
    }

    private func updateLayerVisibility(_ layer: MLNSymbolStyleLayer, for floor: Int) {
        if let markerFloor = self.floor, markerFloor != floor {
            if let disabledColor {
                layer.iconColor = NSExpression(forConstantValue: disabledColor)
            } else {
                layer.isVisible = false
            }
        } else {
            if let color {
                layer.iconColor = NSExpression(forConstantValue: color)
            } else {
                layer.isVisible = true
            }
        }
    }
}
