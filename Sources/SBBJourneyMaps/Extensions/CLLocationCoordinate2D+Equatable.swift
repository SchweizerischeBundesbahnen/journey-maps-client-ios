//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import Foundation

/// Adds `Equatable` conformance to `CLLocationCoordinate2D`.
///
/// Two coordinates are considered equal when **both** their latitude and
/// longitude values are exactly the same.
///
/// - Note: This performs a strict floating-point comparison. If you need
///   tolerance-based comparison (e.g. for GPS inaccuracies), consider
///   implementing a custom comparison with an epsilon value instead.
extension CLLocationCoordinate2D: Equatable {

    /// Compares two geographic coordinates for equality.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand coordinate to compare.
    ///   - rhs: The right-hand coordinate to compare.
    /// - Returns: `true` if both the latitude and longitude values are equal;
    ///   otherwise, `false`.
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
