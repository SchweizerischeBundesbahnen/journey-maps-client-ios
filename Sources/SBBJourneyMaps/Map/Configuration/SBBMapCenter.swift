//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import Foundation

/// Represents the center configuration for displaying a map.
///
/// `SBBMapCenter` can be defined either by a single center coordinate with a zoom
/// level or by a bounding box. These two configurations are mutually exclusive.
public struct SBBMapCenter: Equatable {

    let coordinate: CLLocationCoordinate2D?
    let zoomLevel: Double?
    let selectUnderlyingPoi: Bool

    let boundingBoxSW: CLLocationCoordinate2D?
    let boundingBoxNE: CLLocationCoordinate2D?

    /// Creates a map center using a single coordinate.
    ///
    /// - Parameters:
    ///   - coordinate: The geographic coordinate to center the map on.
    ///   - zoomLevel: The zoom level to apply. Defaults to `17`.
    ///   - selectUnderlyingPoi: Indicates whether an underlying point of interest
    ///     should be selected. Defaults to `false`.
    public init(coordinate: CLLocationCoordinate2D, zoomLevel: Double = 17, selectUnderlyingPoi: Bool = false) {
        self.coordinate = coordinate
        self.zoomLevel = zoomLevel
        self.selectUnderlyingPoi = selectUnderlyingPoi
        self.boundingBoxSW = nil
        self.boundingBoxNE = nil
    }

    /// Creates a map center using a bounding box.
    ///
    /// The map will be adjusted to fully display the area defined by the
    /// south-west and north-east coordinates.
    ///
    /// - Parameters:
    ///   - bboxSW: The south-west coordinate of the bounding box.
    ///   - bboxNE: The north-east coordinate of the bounding box.
    public init(bboxSW: CLLocationCoordinate2D, bboxNE: CLLocationCoordinate2D) {
        self.boundingBoxSW = bboxSW
        self.boundingBoxNE = bboxNE
        self.coordinate = nil
        self.zoomLevel = nil
        self.selectUnderlyingPoi = false
    }
}
