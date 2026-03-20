//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import SBBDesignSystemMobileSwiftUI
import SBBJourneyMaps
import SwiftUI

struct PoiJourneyMapsView: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme

    private var isLandscape: Bool {
        self.horizontalSizeClass != .compact || self.verticalSizeClass != .regular
    }

    @State private var center: SBBMapCenter?

    @State private var tappedCoordinate: CLLocationCoordinate2D?
    @State private var selectedPoi: SBBMapPoi?
    @State private var presentPoiNotification = true
    @State private var selectUnderlyingPoi = true

    private var examplePoiButtons: some View {
        HStack {
            Button {
                center = SBBMapCenter(coordinate: .bernPubiBike, selectUnderlyingPoi: selectUnderlyingPoi)
            } label: {
                Text("PubliBike Bern")
            }
            .buttonStyle(SBBPrimaryButtonStyle(sizeToFit: isLandscape))
            Button {
                center = SBBMapCenter(coordinate: .bernTrainstationBrezelkoenig, selectUnderlyingPoi: selectUnderlyingPoi)
            } label: {
                Text("Brezelkönig")
            }
            .buttonStyle(SBBPrimaryButtonStyle(sizeToFit: isLandscape))
        }
    }

    private var bernButton: some View {
        Button {
            center = SBBMapCenter(coordinate: .bernTrainstation)
        } label: {
            Text("Bern Trainstation")
        }
        .buttonStyle(SBBPrimaryButtonStyle(sizeToFit: isLandscape))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            SBBMapView(centerTo: $center)
                .sbbMapButtonHorizontalPadding(isLandscape ? 50 : 0)
                .onSbbMapTap { coord in
                    selectedPoi = nil
                    tappedCoordinate = coord
                    presentPoiNotification = true
                }
                .onSbbMapPoiTap { poi in
                    selectedPoi = poi
                    presentPoiNotification = true
                }
                .onSbbMapAllPoisDeselected {
                    tappedCoordinate = nil
                    selectedPoi = nil
                    presentPoiNotification = false
                }
                .edgesIgnoringSafeArea(.all)
                .onChange(of: presentPoiNotification) { newValue in
                    if !newValue {
                        tappedCoordinate = nil
                        selectedPoi = nil
                    }
                }
            VStack {
                if isLandscape {
                    HStack(spacing: 8) {
                        examplePoiButtons
                        bernButton
                    }
                }

                SBBSwitchItem(isOn: $selectUnderlyingPoi, label: Text("Select POI when centering"), showBottomLine: false, showLoading: false)
                    .background(Color.sbbColor(colorScheme == .light ? .white : .black))
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 23, style: .circular)
                            .strokeBorder(Color.sbbColor(colorScheme == .light ? .cloud : .metal), lineWidth: 1)
                    )
                    .frame(height: 46)

                if !isLandscape {
                    examplePoiButtons
                    bernButton
                }
            }
            .sbbScreenPadding()
        }
        .overlay(alignment: .top) {
            if let selectedPoi {
                SBBNotification(isPresented: $presentPoiNotification, statusType: .info, title: Text("POI Attribute:"), text: Text(text(of: selectedPoi)))
                    .padding(8)
            } else if let tappedCoordinate {
                SBBNotification(isPresented: $presentPoiNotification, statusType: .info, title: Text("Tapped Coordinate:"), text: Text("\(tappedCoordinate.latitude), \(tappedCoordinate.longitude)"))
                    .padding(8)
            } else {
                EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("POI Details")
    }

    func text(of poi: SBBMapPoi) -> String {
        var attributeTexte: [String] = []
        attributeTexte.append("coordinate: \(poi.coordinate.latitude), \(poi.coordinate.longitude)")
        for (key, value) in poi.attributes {
            attributeTexte.append("\(key): \(value) ")
        }
        return attributeTexte.sorted().joined(separator: "\n")
    }
}

#Preview {
    PoiJourneyMapsView()
}
