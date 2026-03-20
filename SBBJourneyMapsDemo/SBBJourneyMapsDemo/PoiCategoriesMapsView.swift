//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import SBBDesignSystemMobileSwiftUI
import SBBJourneyMaps
import SwiftUI

struct PoiCategoriesMapsView: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme

    private var isLandscape: Bool {
        self.horizontalSizeClass != .compact || self.verticalSizeClass != .regular
    }

    @State private var showCategories: Bool = false
    @State private var center: SBBMapCenter?
    @State private var chosenCategories: [SBBPoiCategoryType] = SBBPoiCategoryType.allCases

    var mapConfig: SBBMapConfiguration {
        SBBMapConfiguration(poiCategories: chosenCategories)
    }

    private var categories: some View {
        ScrollView {
            HStack {
                Button {
                    chosenCategories = SBBPoiCategoryType.allCases
                } label: {
                    Text("Select all")
                }
                .buttonStyle(SBBSecondaryButtonStyle())
                Spacer()
                Button {
                    chosenCategories = []
                } label: {
                    Text("Deselect all")
                }
                .buttonStyle(SBBSecondaryButtonStyle())
            }
            .padding(.horizontal, 16)
            ForEach(SBBPoiCategoryType.allCases, id: \.self) { cat in
                SBBCheckBox(
                    isOn:
                        Binding(
                            get: {
                                chosenCategories.contains(cat)
                            },
                            set: { newValue in
                                chosenCategories.removeAll(where: { $0 == cat })
                                if newValue {
                                    chosenCategories.append(cat)
                                }
                            }),
                    text: Text(cat.rawValue),
                    showBottomLine: cat != SBBPoiCategoryType.allCases.last)
            }
        }
        .frame(maxHeight: isLandscape ? 400 : 300)
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

    private var categoriesButton: some View {
        Button(action: {
            withAnimation {
                showCategories = true
            }
        }) {
            Text("Show categories")
        }
        .buttonStyle(SBBSecondaryButtonStyle(sizeToFit: isLandscape))
    }

    private var centerButton: some View {
        Button {
            center = SBBMapCenter(coordinate: .bernTrainstation)
        } label: {
            Text("Center to Bern")
        }
        .buttonStyle(SBBPrimaryButtonStyle(sizeToFit: isLandscape))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            SBBMapView(centerTo: $center, mapConfig: mapConfig)
                .sbbMapButtonHorizontalPadding(isLandscape ? 50 : 0)
                .onSbbMapTap { _ in
                    showCategories = false
                }
                .edgesIgnoringSafeArea(.all)

            if isLandscape {
                HStack {
                    if showCategories {
                        categories
                    } else {
                        categoriesButton
                        centerButton
                    }
                }
            } else {
                VStack {
                    if showCategories {
                        categories
                    } else {
                        categoriesButton
                    }
                    centerButton
                }
                .sbbScreenPadding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("POI Categories")
    }
}

#Preview {
    PoiCategoriesMapsView()
}
