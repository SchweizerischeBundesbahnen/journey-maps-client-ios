//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import SBBDesignSystemMobileSwiftUI
import SBBJourneyMaps
import SwiftUI

struct PathJourneyMapsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme

    private var isLandscape: Bool {
        self.horizontalSizeClass != .compact || self.verticalSizeClass != .regular
    }

    @State private var mapCenter: SBBMapCenter? = nil
    @State private var showPath: Bool = false

    @State private var markers: [SBBMarker] = []
    @State private var lines: [SBBLine] = []
    @State private var circles: [SBBCircle] = []
    @State private var floorConnectors: [SBBFloorConnector] = []

    private let firstPart = [
        CLLocationCoordinate2D(latitude: 46.94841938376483, longitude: 7.437936262929969),
        CLLocationCoordinate2D(latitude: 46.948214553634784, longitude: 7.436949063838279),
    ]
    private let firstStairs = [
        CLLocationCoordinate2D(latitude: 46.948214553634784, longitude: 7.436949063838279),
        CLLocationCoordinate2D(latitude: 46.948173098253044, longitude: 7.4367877971401715),
    ]
    private let middlePart = [
        CLLocationCoordinate2D(latitude: 46.948173098253044, longitude: 7.4367877971401715),
        CLLocationCoordinate2D(latitude: 46.948586489124615, longitude: 7.4364025857686835),
        CLLocationCoordinate2D(latitude: 46.9482589103533, longitude: 7.434034531356365),
    ]
    private let secondStairs = [
        CLLocationCoordinate2D(latitude: 46.9482589103533, longitude: 7.434034531356365),
        CLLocationCoordinate2D(latitude: 46.94826735131338, longitude: 7.433906308899518),
    ]
    private let lastPart = [
        CLLocationCoordinate2D(latitude: 46.94826735131338, longitude: 7.433906308899518),
        CLLocationCoordinate2D(latitude: 46.94825202574774, longitude: 7.433300095211762),
    ]

    private var availableFloorConnectors: [SBBFloorConnector] {
        [
            SBBFloorConnector(
                id: "first-stairs",
                coordinates: CLLocationCoordinate2D(latitude: 46.948214553634784, longitude: 7.436949063838279),
                originFloor: 0,
                destinationFloor: 1,
                backgroundColor: colorScheme == .light ? .white : .black,
                borderColor: colorScheme == .light ? .sbbColor(.cloud) : .sbbColor(.metal),
                floorConnectorIcon: UIImage(systemName: "figure.stairs")!,
                directionIcon: UIImage(systemName: "arrow.up")!,
                iconsColor: colorScheme == .light ? .black : .white,
                minZoom: 16),

            SBBFloorConnector(
                id: "second-stairs",
                coordinates: CLLocationCoordinate2D(latitude: 46.9482589103533, longitude: 7.434034531356365),
                originFloor: 1, destinationFloor: 0,
                backgroundColor: colorScheme == .light ? .white : .black,
                borderColor: colorScheme == .light ? .sbbColor(.cloud) : .sbbColor(.metal),
                floorConnectorIcon: UIImage(systemName: "figure.stairs")!,
                directionIcon: UIImage(systemName: "arrow.down")!,
                iconsColor: colorScheme == .light ? .black : .white,
                minZoom: 16),
        ]
    }

    private let availableMarker = SBBMarker(
        id: "end_path",
        coordinates: .bernTrainstation,
        image: UIImage(systemName: "flag.checkered")!,
        color: .red,
        minZoom: 16)
    private var lineConfig: SBBLineConfig {
        SBBLineConfig(
            minLineWidth: 2,
            maxLineWidth: 8,
            color: UIColor(red: 0, green: 121 / 256, blue: 199 / 256, alpha: colorScheme == .light ? 0.3 : 1.0),
            disabledColor: UIColor(red: 125 / 256, green: 125 / 256, blue: 125 / 256, alpha: colorScheme == .light ? 0.3 : 1.0),
            image: UIImage(systemName: "arrow.forward")!,
            imageColor: colorScheme == .light ? UIColor(red: 0, green: 121 / 256, blue: 199 / 256, alpha: 1.0) : UIColor(red: 222 / 256, green: 222 / 256, blue: 222 / 256, alpha: 1.0),
            imageDisabledColor: colorScheme == .light ? UIColor(red: 125 / 256, green: 125 / 256, blue: 125 / 256, alpha: 1.0) : UIColor(red: 222 / 256, green: 222 / 256, blue: 222 / 256, alpha: 1.0),
            imageMinScale: 0.1,
            imageMaxScale: 0.5,
            imageSpacing: 20)
    }
    private var routingPath: [SBBLine] {
        [
            SBBLine(
                id: "base-path",
                coordinates: firstPart + firstStairs + middlePart + secondStairs + lastPart,
                config: SBBLineConfig(color: colorScheme == .light ? UIColor.sbbColor(.white) : UIColor.sbbColor(.black), outlineColor: colorScheme == .light ? .gray : nil),
                minZoom: 16
            ),
            SBBLine(id: "first-part", coordinates: firstPart, config: lineConfig, minZoom: 16, floor: 0),
            SBBLine(id: "first-stairs", coordinates: firstStairs, config: lineConfig, minZoom: 16, floor: 1),
            SBBLine(id: "middle-part", coordinates: middlePart, config: lineConfig, minZoom: 16, floor: 1),
            SBBLine(id: "second-stairs", coordinates: secondStairs, config: lineConfig, minZoom: 16, floor: 0),
            SBBLine(id: "last-part", coordinates: lastPart, config: lineConfig, minZoom: 16, floor: 0),
        ]
    }

    private let startAndEndCircles = [
        SBBCircle(
            id: "start-circle", coordinates: CLLocationCoordinate2D(latitude: 46.94841938376483, longitude: 7.437936262929969),
            minRadius: 5, maxRadius: 10, color: .black, disabledColor: .gray, floor: 1),
        SBBCircle(
            id: "end-circle", coordinates: CLLocationCoordinate2D(latitude: 46.94825202574774, longitude: 7.433300095211762),
            minRadius: 5, maxRadius: 10, color: .black, disabledColor: .gray, floor: -2),
    ]

    private let center = SBBMapCenter(coordinate: CLLocationCoordinate2D(latitude: 46.948586489124615, longitude: 7.4364025857686835), zoomLevel: 16)

    private var pathButton: some View {
        SBBSwitchItem(isOn: $showPath, label: Text("Show path"), showBottomLine: false, showLoading: false)
            .background(Color.sbbColor(colorScheme == .light ? .white : .black))
            .cornerRadius(22)
            .overlay(
                RoundedRectangle(cornerRadius: 23, style: .circular)
                    .strokeBorder(Color.sbbColor(colorScheme == .light ? .cloud : .metal), lineWidth: 1)
            )
            .frame(height: 46)
    }

    private var centerButton: some View {
        Button(action: {
            mapCenter = center
        }) {
            Text("Center to path")
        }
        .buttonStyle(SBBPrimaryButtonStyle())
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            SBBMapView(centerTo: $mapCenter, markers: $markers, lines: $lines, circles: $circles, floorConnectors: $floorConnectors, mapConfig: SBBMapConfiguration(poiCategories: []))
                .sbbMapButtonHorizontalPadding(isLandscape ? 50 : 0)
                .sbbMapShowZoomButtons(true)
                .sbbMapStyleSwitchButton(false)
                .edgesIgnoringSafeArea(.all)
                .onChange(of: showPath) { newValue in
                    lines = newValue ? routingPath : []
                    circles = newValue ? startAndEndCircles : []
                    floorConnectors = newValue ? availableFloorConnectors : []
                }
                .onChange(of: colorScheme) { _ in
                    lines = showPath ? routingPath : []
                    circles = showPath ? startAndEndCircles : []
                    floorConnectors = showPath ? availableFloorConnectors : []
                }

            VStack {
                if isLandscape {
                    HStack(spacing: 8) {
                        pathButton
                        centerButton
                    }
                } else {
                    pathButton
                    centerButton
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Path")
    }
}

#Preview {
    DefaultJourneyMapsView()
}
