//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import SBBDesignSystemMobileSwiftUI
import SBBJourneyMaps
import SwiftUI

struct DefaultJourneyMapsView: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    private var isLandscape: Bool {
        self.horizontalSizeClass != .compact || self.verticalSizeClass != .regular
    }

    @State private var center: SBBMapCenter?

    var body: some View {
        ZStack(alignment: .bottom) {
            SBBMapView(centerTo: $center)
                .sbbMapButtonHorizontalPadding(isLandscape ? 50 : 0)
                .edgesIgnoringSafeArea(.all)

            Button {
                center = SBBMapCenter(coordinate: .bernTrainstation)
            } label: {
                Text("Center to Bern")
            }
            .buttonStyle(SBBPrimaryButtonStyle(sizeToFit: self.horizontalSizeClass != .compact || self.verticalSizeClass != .regular))
            .sbbScreenPadding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Default")
    }
}

#Preview {
    DefaultJourneyMapsView()
}
