//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import MapLibre
import UIKit

public struct SBBFloorConnector: TappableAnnotation {
    typealias TapData = Int

    public let id: String
    public let coordinates: CLLocationCoordinate2D
    public let floor: Int?
    public let destinationFloor: Int
    public let backgroundColor: UIColor
    public let borderColor: UIColor
    public let floorConnectorIcon: UIImage
    public let directionIcon: UIImage
    public let iconsColor: UIColor
    public let minScale: Float
    public let maxScale: Float
    public let minZoom: Float
    public let maxZoom: Float

    var layerName: String { "\(id)_floor_connector_layer" }
    var sourceName: String { "\(id)_floor_connector_source" }
    var imageName: String { "\(id)_floor_connector_image" }

    /// A  floor connector to be rendered on the map.
    ///  - Parameters:
    ///   - id: The unique id of the floor connector.
    ///   - coordinates: The coordinates for the floor connector.
    ///   - originFloor: The floor level at which it starts.
    ///   - destinationFloor: The floor level at which it ends.
    ///   - floorConnectorIcon: The icon display for the floor connector.
    ///   - directionIcon: The icon display for the direction in which the floor connector goes.
    ///   - minScale: The minimum scale for the floor connector, when zoomed out.
    ///   - maxScale: The maximum scale for the floor connector, when zoomed in.
    ///   - minZoom: The minimum zoom level at which the floor connector appears.
    ///   - maxZoom: The maximum zoom level at which the floor connector appears.
    public init(
        id: String, coordinates: CLLocationCoordinate2D, originFloor: Int, destinationFloor: Int, backgroundColor: UIColor = .white, borderColor: UIColor = .gray, floorConnectorIcon: UIImage,
        directionIcon: UIImage, iconsColor: UIColor = .black, minScale: Float = 0.5, maxScale: Float = 1.0, minZoom: Float = 16, maxZoom: Float = 24
    ) {
        self.id = id
        self.coordinates = coordinates
        self.floor = originFloor
        self.destinationFloor = destinationFloor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.floorConnectorIcon = floorConnectorIcon.withTintColor(iconsColor, renderingMode: .alwaysTemplate)
        self.directionIcon = directionIcon.withTintColor(iconsColor, renderingMode: .alwaysTemplate)
        self.iconsColor = iconsColor
        self.minScale = minScale
        self.maxScale = maxScale
        self.minZoom = minZoom
        self.maxZoom = maxZoom
    }

    func deleteFromMapView(_ mapView: MLNMapView) {
        if let style = mapView.style {
            if let layer = style.layer(withIdentifier: layerName) {
                style.removeLayer(layer)
            }
            if let source = style.source(withIdentifier: sourceName) {
                style.removeSource(source)
            }
        }
    }

    func addToMapView(_ mapView: MLNMapView, floor: Int) {
        addToMapView(mapView, floor: floor, tapAction: { _ in })
    }

    func addToMapView(_ mapView: MLNMapView, floor: Int, tapAction: @escaping (Int) -> Void) {
        guard let style = mapView.style,
            style.layer(withIdentifier: layerName) == nil
        else { return }

        let compositeImage = createCompositeImage()

        if style.image(forName: imageName) == nil {
            style.setImage(compositeImage, forName: imageName)
        }

        let point = MLNPointAnnotation()
        point.coordinate = coordinates

        let source = MLNShapeSource(identifier: sourceName, shape: point, options: nil)
        let layer = MLNSymbolStyleLayer(identifier: layerName, source: source)

        style.addSource(source)

        configureLayer(layer)
        updateLayerVisibility(layer, for: floor)

        style.addLayer(layer)

        TapManager.shared.setTapHandler(
            for: layerName,
            handler: {
                tapAction(destinationFloor)
            })
    }

    func updateFloor(_ floor: Int, on mapView: MLNMapView) {
        guard let style = mapView.style,
            let layer = style.layer(withIdentifier: layerName) as? MLNSymbolStyleLayer
        else { return }

        updateLayerVisibility(layer, for: floor)
    }

    private func configureLayer(_ layer: MLNSymbolStyleLayer) {
        layer.iconImageName = NSExpression(forConstantValue: imageName)
        layer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        layer.iconIgnoresPlacement = NSExpression(forConstantValue: true)
        layer.iconOffset = NSExpression(
            forMLNInterpolating: NSExpression.zoomLevelVariable,
            curveType: MLNExpressionInterpolationMode.linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: [
                14: NSExpression(forConstantValue: [-40 * minScale, 0]),
                18: NSExpression(forConstantValue: [-52.5 * maxScale, 0]),
            ])
        )
        layer.iconScale = NSExpression(
            forMLNInterpolating: NSExpression.zoomLevelVariable,
            curveType: MLNExpressionInterpolationMode.linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: [14: minScale, 18: maxScale]))

        layer.minimumZoomLevel = minZoom
        layer.maximumZoomLevel = maxZoom
    }

    private func updateLayerVisibility(_ layer: MLNSymbolStyleLayer, for floor: Int) {
        if let originFloor = self.floor, originFloor != floor {
            layer.iconOpacity = NSExpression(forConstantValue: 0.0)
        } else {
            layer.iconOpacity = NSExpression(forConstantValue: 1.0)
        }
    }

    private func createCompositeImage() -> UIImage {
        let width: CGFloat = 105
        let height: CGFloat = 35
        let iconSize: CGFloat = 20
        let padding: CGFloat = 10
        let cornerRadius: CGFloat = 16

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))

        return renderer.image { context in
            let ctx = context.cgContext

            // Draw background
            backgroundColor.setFill()
            let backgroundRect = CGRect(x: 0, y: 0, width: width, height: height)
            UIBezierPath(roundedRect: backgroundRect, cornerRadius: cornerRadius).fill()

            borderColor.setStroke()
            let borderInset: CGFloat = 1
            let borderRect = backgroundRect.insetBy(dx: borderInset, dy: borderInset)
            let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius)
            borderPath.lineWidth = 1
            borderPath.stroke()

            let leftIconRect = CGRect(x: padding, y: (height - iconSize) / 2, width: iconSize, height: iconSize)
            let rightIconRect = CGRect(x: width - padding - iconSize, y: (height - iconSize) / 2, width: iconSize, height: iconSize)

            floorConnectorIcon.draw(in: leftIconRect)
            directionIcon.draw(in: rightIconRect)

            let separatorColor = borderColor
            ctx.setStrokeColor(separatorColor.cgColor)
            ctx.setLineWidth(1)

            let leftSeparatorX = leftIconRect.maxX + 4
            let rightSeparatorX = rightIconRect.minX - 4
            let separatorYStart: CGFloat = 6
            let separatorYEnd = height - 6

            ctx.move(to: CGPoint(x: leftSeparatorX, y: separatorYStart))
            ctx.addLine(to: CGPoint(x: leftSeparatorX, y: separatorYEnd))

            ctx.move(to: CGPoint(x: rightSeparatorX, y: separatorYStart))
            ctx.addLine(to: CGPoint(x: rightSeparatorX, y: separatorYEnd))

            ctx.strokePath()

            let text = String(destinationFloor)
            let fontSize: CGFloat = 14
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: iconsColor,
            ]

            let textSize = text.size(withAttributes: textAttributes)

            let textCenterX = (leftSeparatorX + rightSeparatorX) / 2
            let textOrigin = CGPoint(
                x: textCenterX - textSize.width / 2,
                y: (height - textSize.height) / 2
            )

            let textRect = CGRect(origin: textOrigin, size: textSize)
            text.draw(in: textRect, withAttributes: textAttributes)
        }
    }
}
