//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import SBBDesignSystemMobileSwiftUI
import SBBJourneyMaps
import SwiftUI

struct ConfigurableJourneyMapsView: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme

    private var isLandscape: Bool {
        self.horizontalSizeClass != .compact || self.verticalSizeClass != .regular
    }

    @State private var showOptions: Bool = false

    @State private var center: SBBMapCenter?

    @State private var pitchEnabled = true
    @State private var rotateEnabled = true
    @State private var showsUserLocation = true
    @State private var showScale = true
    @State private var scaleBarUsesMetricSystem = true
    @State private var zoomEnabled = true
    @State private var scrollEnabled = true

    @State private var buttonTopPadding: CGFloat = 0
    @State private var showStyleSwitchButton = true
    @State private var showFloorSelectionButton = true
    @State private var showCopyright = true

    private var customMapConfig: SBBMapConfiguration {
        SBBMapConfiguration(
            pitchEnabled: pitchEnabled,
            rotateEnabled: rotateEnabled,
            showsUserLocation: showsUserLocation,
            showsScale: showScale,
            scaleBarUsesMetricSystem: scaleBarUsesMetricSystem,
            zoomEnabled: zoomEnabled,
            scrollEnabled: scrollEnabled
        )
    }

    private var minPadding: CGFloat {
        0
    }

    private var maxPadding: CGFloat {
        200
    }

    private var options: some View {
        VStack {
            HStack {
                SBBCheckBox(isOn: $pitchEnabled, text: Text("Pitch"), showBottomLine: false)
                SBBCheckBox(isOn: $rotateEnabled, text: Text("Rotate"), showBottomLine: false)
            }
            .frame(height: 33)
            HStack {
                SBBCheckBox(isOn: $zoomEnabled, text: Text("Zoom"), showBottomLine: false)
                SBBCheckBox(isOn: $showsUserLocation, text: Text("User Location"), showBottomLine: false)
            }
            .frame(height: 33)
            HStack {
                SBBCheckBox(isOn: $scrollEnabled, text: Text("Scroll"), showBottomLine: false)
                SBBCheckBox(isOn: $showFloorSelectionButton, text: Text("Floor Button"), showBottomLine: false)
            }
            .frame(height: 33)
            HStack {
                SBBCheckBox(isOn: $showScale, text: Text("Scale"), showBottomLine: false)
                SBBCheckBox(isOn: $showStyleSwitchButton, text: Text("Style switcher"), showBottomLine: false)
            }
            .frame(height: 33)
            if showScale {
                HStack {
                    SBBCheckBox(isOn: $scaleBarUsesMetricSystem, text: Text("Metric System"), showBottomLine: false)
                    SBBCheckBox(isOn: $showCopyright, text: Text("Copyright"), showBottomLine: false)
                }
                .frame(height: 33)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Button Top Padding: \(Int(buttonTopPadding))")
                    .sbbFont(.medium_bold)
                Slider(value: $buttonTopPadding, in: minPadding...maxPadding)
                    .sbbStyle()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.2)
        .padding(.vertical, 8)
        .background(Color.sbbColor(colorScheme == .light ? .white : .black))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 17, style: .circular)
                .strokeBorder(Color.sbbColor(colorScheme == .light ? .cloud : .metal), lineWidth: 1)
        )
    }

    private var optionsButton: some View {
        Button(action: {
            withAnimation {
                showOptions = true
            }
        }) {
            Text("Show options")
        }
        .buttonStyle(SBBSecondaryButtonStyle(sizeToFit: isLandscape))
    }

    private var centerButton: some View {
        Button {
            showOptions = false
            center = SBBMapCenter(coordinate: .bernTrainstation)
        } label: {
            Text("Center to Bern")
        }
        .buttonStyle(SBBPrimaryButtonStyle(sizeToFit: self.horizontalSizeClass != .compact || self.verticalSizeClass != .regular))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            SBBMapView(centerTo: $center, mapConfig: customMapConfig)
                .sbbMapButtonHorizontalPadding(isLandscape ? 50 : 0)
                .sbbMapButtonTopPadding(buttonTopPadding)
                .sbbMapStyleSwitchButton(showStyleSwitchButton)
                .sbbMapShowFloorSelectionButtons(showFloorSelectionButton)
                .sbbMapCopyright(showCopyright, bottomPadding: 140)
                .sbbMapShowZoomButtons(zoomEnabled)
                .onSbbMapTap { _ in
                    showOptions = false
                }
                .edgesIgnoringSafeArea(.all)

            if isLandscape {
                HStack {
                    if showOptions {
                        options
                    } else {
                        optionsButton
                        centerButton
                    }
                }
            } else {
                VStack {
                    if showOptions {
                        options
                    } else {
                        optionsButton
                    }
                    centerButton
                }
                .sbbScreenPadding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Configurable")
    }
}

#Preview {
    ConfigurableJourneyMapsView()
}
