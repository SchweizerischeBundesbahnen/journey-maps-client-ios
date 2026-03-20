//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import Foundation

/// Detailed information of the Journey Maps POI.
public struct SBBMapPoi: Equatable {
    public let coordinate: CLLocationCoordinate2D
    public let attributes: [String: String]

    public var name: String {
        attributes["name"] ?? ""
    }

    public var poiId: String {
        attributes["sbbId"] ?? ""
    }

    public var category: String {
        attributes["category"] ?? ""
    }
}
