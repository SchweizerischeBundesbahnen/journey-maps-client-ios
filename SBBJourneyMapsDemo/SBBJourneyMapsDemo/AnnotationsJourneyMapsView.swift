//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import SBBDesignSystemMobileSwiftUI
import SBBJourneyMaps
import SwiftUI

struct AnnotationsJourneyMapsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    private enum AnnotationType {
        case markers
        case lines
        case circles
    }

    @State private var selectedType: AnnotationType = .markers

    private var isLandscape: Bool {
        self.horizontalSizeClass != .compact || self.verticalSizeClass != .regular
    }

    @State private var center: SBBMapCenter?

    @State private var markers: [SBBMarker] = []
    private let availableMarkers = [
        SBBMarker(id: "marker1", coordinates: .bernTrainstation, image: UIImage(systemName: "train.side.front.car")!, color: UIColor.sbbColor(.red)),
        SBBMarker(id: "marker2", coordinates: .zurichTrainstation, image: UIImage(systemName: "figure")!, color: UIColor.sbbColor(.blue)),
        SBBMarker(id: "marker3", coordinates: .randomSpot1, image: UIImage(systemName: "sun.max.fill")!, color: UIColor.sbbColor(.peach)),
        SBBMarker(id: "marker4", coordinates: .randomSpot2, image: UIImage(systemName: "fish.fill")!, color: UIColor.sbbColor(.green)),
        SBBMarker(id: "marker5", coordinates: .randomSpot3, image: UIImage(systemName: "bird.fill")!, color: UIColor.sbbColor(.violet)),
    ]
    @State private var lines: [SBBLine] = []
    private let availableLines = [
        SBBLine(id: "line1", coordinates: [.bernTrainstation, .zurichTrainstation], config: SBBLineConfig(color: UIColor.sbbColor(.red))),
        SBBLine(
            id: "line2",
            coordinates: [
                CLLocationCoordinate2D(latitude: 46.94841938376483, longitude: 7.437936262929969), CLLocationCoordinate2D(latitude: 46.948173098253044, longitude: 7.4367877971401715),
                CLLocationCoordinate2D(latitude: 46.9482589103533, longitude: 7.434034531356365), CLLocationCoordinate2D(latitude: 46.94826735131338, longitude: 7.433906308899518),
            ], config: SBBLineConfig(color: UIColor.sbbColor(.blue))),
        SBBLine(id: "line3", coordinates: [.randomSpot1, .randomSpot2, .randomSpot3], config: SBBLineConfig(color: UIColor.sbbColor(.peach))),
    ]
    @State private var circles: [SBBCircle] = []
    private let availableCircles = [
        SBBCircle(id: "circle1", coordinates: .bernTrainstation, color: UIColor.sbbColor(.red)),
        SBBCircle(id: "circle2", coordinates: .zurichTrainstation, color: UIColor.sbbColor(.blue)),
        SBBCircle(id: "circle3", coordinates: .randomSpot1, color: UIColor.sbbColor(.peach)),
        SBBCircle(id: "circle4", coordinates: .randomSpot2, color: UIColor.sbbColor(.green)),
        SBBCircle(id: "circle5", coordinates: .randomSpot3, color: UIColor.sbbColor(.violet)),
    ]

    private var annotationsButton: some View {
        SBBSegmentedPicker(selection: $selectedType, tags: [.markers, .circles, .lines]) {
            Text("Markers")
            Text("Circles")
            Text("Lines")
        }
    }

    private var centerButton: some View {
        Button {
            center = SBBMapCenter(coordinate: .bernTrainstation)
        } label: {
            Text("Center to Bern")
        }
        .buttonStyle(SBBPrimaryButtonStyle(sizeToFit: self.horizontalSizeClass != .compact || self.verticalSizeClass != .regular))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            SBBMapView(centerTo: $center, markers: $markers, lines: $lines, circles: $circles)
                .sbbMapButtonHorizontalPadding(isLandscape ? 50 : 0)
                .onAppear {
                    markers = availableMarkers
                }
                .onChange(of: selectedType) { newValue in
                    markers = newValue == .markers ? availableMarkers : []
                    circles = newValue == .circles ? availableCircles : []
                    lines = newValue == .lines ? availableLines : []
                }
                .edgesIgnoringSafeArea(.all)

            if isLandscape {
                HStack {
                    annotationsButton
                    centerButton
                }
            } else {
                VStack {
                    annotationsButton
                    centerButton
                }
                .sbbScreenPadding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Annotations")
    }
}
