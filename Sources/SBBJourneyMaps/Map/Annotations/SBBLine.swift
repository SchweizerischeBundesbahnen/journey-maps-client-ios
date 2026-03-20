//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import MapLibre
import SwiftUI

public struct SBBLineConfig: Equatable {
    let minLineWidth: Int
    let maxLineWidth: Int
    let color: UIColor
    let disabledColor: UIColor
    let opacity: Float
    let outlineColor: UIColor?
    let image: UIImage?
    let imageColor: UIColor?
    let imageDisabledColor: UIColor?
    let imageMinScale: Float
    let imageMaxScale: Float
    let imageSpacing: Float

    /// The configuration for a line.
    ///  - Parameters:
    ///     - minLineWidth: The minimum line width, when zoomed out.
    ///     - maxLineWidth: The maximum line width, when zoomed in.
    ///     - color: The color of the line
    ///     - disabledColor: The color of the line if it has an assigned floor and the current floor is not the same.
    ///     - opacity: The opacity of the line.
    ///     - outlineColor: The color of the outline, if any.
    ///     - image: The image rendered along the line, if any.
    ///     - imageColor: The color of the image, if any.
    ///     - imageDisabledColor: The color of the image if the line has an assigned floor and the current floor is not the same.
    ///     - imageMinScale: The minimum scale for the image, when zoomed out.
    ///     - imageMaxScale: The maximum scale for the image, when zoomed in.
    ///     - imageSpacing: The spacing between the images along the line, if any.
    public init(
        minLineWidth: Int = 5, maxLineWidth: Int = 20, color: UIColor = .white, disabledColor: UIColor = .gray, opacity: Float = 1.0, outlineColor: UIColor? = nil, image: UIImage? = nil,
        imageColor: UIColor? = nil, imageDisabledColor: UIColor? = nil, imageMinScale: Float = 0.5, imageMaxScale: Float = 1.0, imageSpacing: Float = 50
    ) {
        self.minLineWidth = minLineWidth
        self.maxLineWidth = maxLineWidth
        self.color = color
        self.disabledColor = disabledColor
        self.opacity = opacity
        self.outlineColor = outlineColor
        if let imageColor {
            self.image = image?.withTintColor(imageColor, renderingMode: .alwaysTemplate)
        } else {
            self.image = image
        }
        self.imageColor = imageColor
        self.imageDisabledColor = imageDisabledColor
        self.imageMinScale = imageMinScale
        self.imageMaxScale = imageMaxScale
        self.imageSpacing = imageSpacing
    }
}

public struct SBBLine: MapAnnotation {

    public let id: String
    public let coordinates: [CLLocationCoordinate2D]
    public let config: SBBLineConfig
    public let minZoom: Float
    public let maxZoom: Float
    public let floor: Int?

    var sourceName: String { "\(id)_line_source" }
    var baseLayerName: String { "\(id)_line_base_layer" }
    var outlineBaseLayerName: String { "\(id)_line_base_layer_outline" }
    var imageLayerName: String { "\(id)_line_image_layer" }
    var imageName: String { "\(id)_line_image" }

    /// A  line to be rendered on the map.
    /// - Parameters:
    ///   - id: The unique name of the line.
    ///   - coordinates: The coordinates of the line.
    ///   - config: The SBBCustomLineConfig for the line.
    ///   - minZoom: The minimum zoom level at which the line appears.
    ///   - maxZoom: The maximum zoom level at which the line appears.
    ///   - floor: The floor level to which the line belongs, if any.
    public init(id: String, coordinates: [CLLocationCoordinate2D], config: SBBLineConfig = SBBLineConfig(), minZoom: Float = 0, maxZoom: Float = 24, floor: Int? = nil) {
        self.id = id
        self.coordinates = coordinates
        self.config = config
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.floor = floor
    }

    func deleteFromMapView(_ mapView: MLNMapView) {
        guard let style = mapView.style else { return }

        if let layer = style.layer(withIdentifier: baseLayerName) as? MLNLineStyleLayer {
            style.removeLayer(layer)
        }
        if let layer = style.layer(withIdentifier: outlineBaseLayerName) as? MLNLineStyleLayer {
            style.removeLayer(layer)
        }
        if let layer = style.layer(withIdentifier: imageLayerName) as? MLNSymbolStyleLayer {
            style.removeLayer(layer)
        }
        if let source = style.source(withIdentifier: sourceName) as? MLNShapeSource {
            style.removeSource(source)
        }
    }

    func addToMapView(_ mapView: MLNMapView, floor: Int) {
        guard let style = mapView.style, style.layer(withIdentifier: baseLayerName) as? MLNLineStyleLayer == nil else { return }
        let polyline = MLNPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        let source = MLNShapeSource(identifier: sourceName, shape: polyline, options: nil)
        style.addSource(source)

        let baseLayer = MLNLineStyleLayer(identifier: baseLayerName, source: source)
        configureBaseLayer(baseLayer, for: floor)
        style.addLayer(baseLayer)

        if self.floor == nil || self.floor == floor, config.outlineColor != nil, style.layer(withIdentifier: outlineBaseLayerName) == nil {
            let outlineLayer = MLNLineStyleLayer(identifier: outlineBaseLayerName, source: source)
            configureOutlineLayer(outlineLayer, for: floor)
            style.insertLayer(outlineLayer, below: baseLayer)
        }

        if let image = config.image, style.layer(withIdentifier: imageLayerName) == nil {
            let imageLayer = MLNSymbolStyleLayer(identifier: imageLayerName, source: source)
            style.setImage(image, forName: imageName)
            configureImageLayer(imageLayer)
            updateLayerVisibility(imageLayer, for: floor)
            style.addLayer(imageLayer)
        }
    }

    func updateFloor(_ floor: Int, on mapView: MLNMapView) {
        guard let style = mapView.style else { return }

        if let layer = style.layer(withIdentifier: imageLayerName) as? MLNSymbolStyleLayer {
            updateLayerVisibility(layer, for: floor)
        }
        if let layer = style.layer(withIdentifier: baseLayerName) as? MLNLineStyleLayer {
            updateLayerVisibility(layer, for: floor)
        }
    }

    private func configureBaseLayer(_ layer: MLNLineStyleLayer, for floor: Int) {
        configureLayer(layer)
        updateLayerVisibility(layer, for: floor)

        layer.lineWidth = NSExpression(
            forMLNInterpolating: NSExpression.zoomLevelVariable, curveType: MLNExpressionInterpolationMode.linear, parameters: nil,
            stops: NSExpression(forConstantValue: [14: config.minLineWidth, 18: config.maxLineWidth]))
    }

    private func configureOutlineLayer(_ layer: MLNLineStyleLayer, for floor: Int) {
        configureLayer(layer)

        layer.lineGapWidth = NSExpression(
            forMLNInterpolating: NSExpression.zoomLevelVariable, curveType: MLNExpressionInterpolationMode.linear, parameters: nil,
            stops: NSExpression(forConstantValue: [14: config.minLineWidth, 18: config.maxLineWidth]))

        layer.lineBlur = NSExpression(forConstantValue: "10")
        layer.lineColor = NSExpression(forConstantValue: config.outlineColor ?? .black)
        layer.lineWidth = NSExpression(forConstantValue: 2)
    }

    private func configureLayer(_ layer: MLNLineStyleLayer) {
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")

        layer.minimumZoomLevel = minZoom
        layer.maximumZoomLevel = maxZoom
    }

    private func configureImageLayer(_ layer: MLNSymbolStyleLayer) {
        layer.symbolSpacing = NSExpression(forConstantValue: config.imageSpacing)
        layer.iconColor = NSExpression(forConstantValue: UIColor.white)
        layer.iconImageName = NSExpression(forConstantValue: imageName)
        layer.symbolPlacement = NSExpression(forConstantValue: "line")
        layer.iconAllowsOverlap = NSExpression(forConstantValue: true)

        layer.iconScale = NSExpression(
            forMLNInterpolating: NSExpression.zoomLevelVariable, curveType: MLNExpressionInterpolationMode.linear, parameters: nil,
            stops: NSExpression(forConstantValue: [14: config.imageMinScale, 18: config.imageMaxScale]))

        layer.minimumZoomLevel = minZoom
        layer.maximumZoomLevel = maxZoom
    }

    private func updateLayerVisibility(_ layer: MLNLineStyleLayer, for floor: Int) {
        if self.floor == nil || self.floor == floor {
            layer.lineColor = NSExpression(forConstantValue: config.color)
        } else {
            layer.lineColor = NSExpression(forConstantValue: config.disabledColor)
        }
    }

    private func updateLayerVisibility(_ layer: MLNSymbolStyleLayer, for floor: Int) {
        if self.floor == nil || self.floor == floor {
            layer.iconColor = NSExpression(forConstantValue: config.imageColor ?? .black)
        } else {
            layer.iconColor = NSExpression(forConstantValue: config.imageDisabledColor ?? .gray)
        }
    }
}
