//
// Copyright © 2026 SBB. All rights reserved.
//

import MapLibre

public enum JourneyMapsSourceIdentifier: String {
    case journeyPoisAreas = "journey-pois-areas-source"
}

public struct SBBGeoJson {

    public static var empty: SBBGeoJson {
        SBBGeoJson()
    }

    private enum SBBGeoJsonConfig {
        case empty
        case shapeSourceIdentifier(identifier: JourneyMapsSourceIdentifier)
        case customAreaColor(fillColor: UIColor, lineColor: UIColor, lineWidth: Int)
    }

    private let id: String
    private let geoJson: String
    private let config: SBBGeoJsonConfig

    private var fillLayername: String {
        return "\(id)_fill_layer"
    }
    private var lineLayername: String {
        return "\(id)_line_layer"
    }
    private var sourceName: String {
        return "\(id)_source"
    }

    /// Creates an empty `SBBGeoJson` object
    public init() {
        id = ""
        geoJson = ""
        config = .empty
    }

    /// Creates a `SBBGeoJson` object that is displayed on top of the map. If the provided GeoJSON is not valid, nothing is shown.
    /// - Parameters:
    ///   - geoJson: Valid GeoJSON String.
    ///   - fillColor: Color of the area
    ///   - lineColor: Color of the border of the area
    ///   - lineWidth: Width of the border of the area
    public init(geoJson: String, fillColor: UIColor, lineColor: UIColor, lineWidth: Int) {
        id = UUID().uuidString
        self.geoJson = geoJson
        self.config = .customAreaColor(fillColor: fillColor, lineColor: lineColor, lineWidth: lineWidth)
    }

    /// Creates a `SBBGeoJson` object that is placed in the existing source of the currently displayed style. If the provided GeoJSON is not valid, nothing is shown
    /// - Parameters:
    ///   - geoJson: Valid GeoJSON String.
    ///   - existingShapeSourceIdentifier: Source identifier that support GeoJSON Files provided by journey-maps, that have specific category property keys.
    public init(geoJson: String, existingShapeSourceIdentifier: JourneyMapsSourceIdentifier = .journeyPoisAreas) {
        id = UUID().uuidString
        self.geoJson = geoJson
        self.config = .shapeSourceIdentifier(identifier: existingShapeSourceIdentifier)
    }

    func deleteFromMapView(_ mapView: MLNMapView) {
        guard let style = mapView.style else { return }

        switch config {
        case .shapeSourceIdentifier(let identifier):
            guard let identifiedSource = mapView.style?.sources.first(where: { $0.identifier == identifier.rawValue }) as? MLNShapeSource else {
                return
            }
            identifiedSource.shape = nil
        case .customAreaColor(_, _, _):
            if let layer = style.layer(withIdentifier: fillLayername) as? MLNFillStyleLayer {
                style.removeLayer(layer)
            }
            if let layer = style.layer(withIdentifier: lineLayername) as? MLNLineStyleLayer {
                style.removeLayer(layer)
            }
            if let source = style.source(withIdentifier: sourceName) as? MLNShapeSource {
                style.removeSource(source)
            }
        case .empty:
            break
        }
    }

    func addToMapView(_ mapView: MLNMapView) {
        switch config {
        case .shapeSourceIdentifier(let identifier):
            guard let identifiedSource = mapView.style?.sources.first(where: { $0.identifier == identifier.rawValue }) as? MLNShapeSource else {
                return
            }
            guard let geoJsonData = geoJson.data(using: .utf8) else {
                return
            }
            let shape = try? MLNShape(data: geoJsonData, encoding: String.Encoding.utf8.rawValue)
            identifiedSource.shape = shape

        case .customAreaColor(let fillColor, let lineColor, let lineWidth):

            guard let geoJsonData = geoJson.data(using: .utf8) else {
                return
            }

            let shape = try? MLNShape(data: geoJsonData, encoding: String.Encoding.utf8.rawValue)
            let source = MLNShapeSource(identifier: sourceName, shape: shape, options: nil)
            mapView.style?.addSource(source)

            let fillLayer = MLNFillStyleLayer(identifier: fillLayername, source: source)
            fillLayer.fillColor = NSExpression(forConstantValue: fillColor)
            mapView.style?.addLayer(fillLayer)

            let lineLayer = MLNLineStyleLayer(identifier: lineLayername, source: source)
            lineLayer.lineColor = NSExpression(forConstantValue: lineColor)
            lineLayer.lineWidth = NSExpression(forConstantValue: lineWidth)
            mapView.style?.addLayer(lineLayer)
        case .empty:
            break
        }
    }
}

extension SBBGeoJson: Equatable {
    public static func == (lhs: SBBGeoJson, rhs: SBBGeoJson) -> Bool {
        lhs.id == rhs.id
    }
}
