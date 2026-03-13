//
// Copyright © 2026 SBB. All rights reserved.
//

import SBBDesignSystemMobileSwiftUI
import SBBJourneyMaps
import SwiftUI

struct MainView: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    private var isLandscape: Bool {
        self.horizontalSizeClass != .compact || self.verticalSizeClass != .regular
    }

    private var welcome: String {
        """
        Welcome to the official SBB Journey Maps Demo App.
        """
    }

    private var staticMap: SBBMapConfiguration {
        SBBMapConfiguration(pitchEnabled: false, rotateEnabled: false, showsUserLocation: false, zoomEnabled: false, scrollEnabled: false)
    }

    private var contentView: some View {
        VStack {
            SBBMapView(centerTo: .constant(nil), mapConfig: staticMap)
                .sbbMapStyleSwitchButton(false)
                .edgesIgnoringSafeArea(.horizontal)
                .frame(height: 250)
            Text(welcome)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.2)
                .padding(.vertical, 16)
                .padding(.horizontal, 8)
            Group {
                NavigationLink("Default Map", destination: DefaultJourneyMapsView())
                    .buttonStyle(SBBSecondaryButtonStyle())
                NavigationLink("Configurable Map", destination: ConfigurableJourneyMapsView())
                    .buttonStyle(SBBSecondaryButtonStyle())
                NavigationLink("Display POI details", destination: PoiJourneyMapsView())
                    .buttonStyle(SBBSecondaryButtonStyle())
                NavigationLink("Choose POI Categories", destination: PoiCategoriesMapsView())
                    .buttonStyle(SBBSecondaryButtonStyle())
                NavigationLink("Display annotations", destination: AnnotationsJourneyMapsView())
                    .buttonStyle(SBBSecondaryButtonStyle())
                NavigationLink("Display a path", destination: PathJourneyMapsView())
                    .buttonStyle(SBBSecondaryButtonStyle())
                NavigationLink("Display a GeoJSON", destination: GeoJSONMapsView())
                    .buttonStyle(SBBSecondaryButtonStyle())
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("SBB Journey Maps")
    }

    var body: some View {
        NavigationStack {
            if isLandscape {
                ScrollView {
                    contentView
                }
            } else {
                contentView
            }
        }
        .accentColor(.white)
    }
}

#Preview {
    MainView()
}
