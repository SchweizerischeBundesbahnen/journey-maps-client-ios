//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import Foundation

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {

        let locSelf = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let locFrom = CLLocation(latitude: from.latitude, longitude: from.longitude)
        return locSelf.distance(from: locFrom)
    }
}
