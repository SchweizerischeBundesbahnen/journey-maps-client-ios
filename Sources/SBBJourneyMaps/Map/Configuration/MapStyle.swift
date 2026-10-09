//
// Copyright © 2026 SBB. All rights reserved.
//

import Foundation

struct MapStyle {
    private let journeyMapsBaseBrightStyle = "https://journey-maps-tiles.api.sbb.ch:443/styles/sbbmaps_bright/style.json?api_key="
    private let journeyMapsBaseDarkStyle = "https://journey-maps-tiles.api.sbb.ch/styles/sbbmaps_dark/style.json?api_key="
    private let journeyMapsAerialStyle = "https://journey-maps-tiles.api.sbb.ch:443/styles/sbbmaps_aerial/style.json?api_key="

    let mapApiKey: String

    init(mapApiKey: String) {
        self.mapApiKey = mapApiKey
    }

    func styleToUse(showAerial: Bool, darkMode: Bool) -> URL {
        let styleString: String
        if showAerial {
            styleString = journeyMapsAerialStyle + mapApiKey
        } else {
            styleString = darkMode ? journeyMapsBaseDarkStyle + mapApiKey : journeyMapsBaseBrightStyle + mapApiKey
        }

        return URL(string: styleString)!
    }
}
