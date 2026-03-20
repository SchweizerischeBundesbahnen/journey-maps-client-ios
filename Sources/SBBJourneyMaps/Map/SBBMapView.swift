//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import SwiftUI

extension SBBMapView {

    /// Shows the buttons for the zooms (in / out).
    /// - Parameter show: default true
    /// - Returns: The Map View itself with the adapted attribute
    public func sbbMapShowZoomButtons(_ show: Bool) -> SBBMapView {
        var newView = self
        newView.showZoomButtons = show
        return newView
    }

    /// Shows the floor selection Buttons on the right side of the screen if a train station has several floors and if the zoom is high enough.
    /// - Parameter show: default true
    /// - Returns: The Map View itself with the adapted attribute
    public func sbbMapShowFloorSelectionButtons(_ show: Bool) -> SBBMapView {
        var newView = self
        newView.showFloorSelectionButtons = show
        return newView
    }

    /// Shows the Style switch Button on the right of the screen. Pressing the Button shows the satellite map with the street and street name overlaid.
    /// - Parameter show: default true
    /// - Returns: The Map View itself with the adapted attribute
    public func sbbMapStyleSwitchButton(_ show: Bool) -> SBBMapView {
        var newView = self
        newView.showStyleSwitchButton = show
        return newView
    }

    /// Shows the Copyright button on the bottom right of the screen. Pressing the Button opens a modal view with the details.
    /// - Parameter show: default false
    /// - Parameter bottomPadding: default 0
    /// - Returns: The Map View itself with the adapted attribute
    public func sbbMapCopyright(_ show: Bool, bottomPadding: CGFloat = 0) -> SBBMapView {
        var newView = self
        newView.showCopyright = show
        newView.copyrightBottomPadding = bottomPadding
        return newView
    }

    /// In case you want to overlay custom views on your map, you can add an additional top padding in order to move the Style switch and the floor selection buttons a little bit down.
    /// - Parameter value: default 0
    /// - Returns: The Map View itself with the adapted attribute
    public func sbbMapButtonTopPadding(_ value: CGFloat) -> SBBMapView {
        var newView = self
        newView.mapButtonTopPadding = value
        return newView
    }

    /// In case you want to overlay custom views on your map, you can an additional horizontal padding in order to move the Style switch and the floor selection buttons a little bit to the inside (esp. for landscape + ignore edges)..
    /// - Parameter value: default 0
    /// - Returns: The Map View itself with the adapted attribute
    public func sbbMapButtonHorizontalPadding(_ value: CGFloat) -> SBBMapView {
        var newView = self
        newView.mapButtonHorizontalPadding = value
        return newView
    }

    /// When the user taps on a point on the map, this action method returns the coordinate of the tapped point.
    /// - Parameter action: ``CLLocationCoordinate2D`` of the tapped point on the map
    /// - Returns: The Map View itself with the adapted attribute
    public func onSbbMapTap(_ action: @escaping (CLLocationCoordinate2D) -> Void) -> SBBMapView {
        var newView = self
        newView.onMapTapped = action
        return newView
    }

    /// When the user taps on a Point of Interest (POI), this action method receives the attributes of said POI. It then can be used e.g. to display its name on the map.
    /// - Parameter action: ``SBBMapPoi`` received when the user clicks on a POI on the map
    /// - Returns: The Map View itself with the adapted attribute
    public func onSbbMapPoiTap(_ action: @escaping (SBBMapPoi) -> Void) -> SBBMapView {
        var newView = self
        newView.selectedPoi = action
        return newView
    }

    /// When the user has tapped on a POI, and then it moves the map, the selected POI is automatically deselected. In this case the user is informed by this action method.
    /// - Parameter action: received when selected POI are deselected by the map view, i.e. by scrolling on the map.
    /// - Returns: The Map View itself with the adapted attribute
    public func onSbbMapAllPoisDeselected(_ action: @escaping () -> Void) -> SBBMapView {
        var newView = self
        newView.deselectedAllPois = action
        return newView
    }
}

/// Journey Maps View for displaying SBB Maps.
public struct SBBMapView: View {

    @Environment(\.colorScheme) private var colorScheme

    @Binding private var centerTo: SBBMapCenter?
    @Binding private var markers: [SBBMarker]
    @Binding private var lines: [SBBLine]
    @Binding private var circles: [SBBCircle]
    @Binding private var floorConnectors: [SBBFloorConnector]
    @State private var compassViewVisible = false
    @State private var userLocationVisible = false
    @State private var possibleFloors: [Int] = []
    @State private var selectedFloor: Int
    @State private var mapAction: MapLibreView.MapLibreAction?

    @State private var errorText = ""
    @State private var attributions: [Attribution]?
    @State private var showCopyrightView: Bool = false

    private var sbbGeoJson: SBBGeoJson

    private var defaultFloor: Int
    // variables that can be changed from `outside`
    private var showZoomButtons: Bool
    private var showFloorSelectionButtons: Bool
    private var showStyleSwitchButton: Bool
    private var mapButtonTopPadding: CGFloat = 0
    private var mapButtonHorizontalPadding: CGFloat = 0
    private var showCopyright: Bool
    private var copyrightBottomPadding: CGFloat = 0

    private var onMapTapped: ((CLLocationCoordinate2D) -> Void)?
    private var selectedPoi: ((SBBMapPoi) -> Void)?
    private var deselectedAllPois: (() -> Void)?
    private let mapConfig: SBBMapConfiguration
    private let sbbMapApiKey: String

    private var isDarkMode: Bool {
        colorScheme == .dark
    }

    /// Initialises the default Journey Maps View with default configuration
    public init() {
        self.init(centerTo: .constant(nil), markers: .constant([]))
    }

    /// Initialises the Journey Maps View with various configuration possibilities.
    /// - Parameters:
    ///   - centerTo: Optional Binding to the location you want to center. The given center is zoomed to level 17. After the map has been centered, the location is set to nil.
    ///   - markers: Optional Binding to markers.
    ///   - lines: Optional Binding to lines.
    ///   - currentLocation: for centering to the current location, you'll have to insert it from the LocationManager.
    ///   - defaultFloor: Optional the default Floor to use when displaying a train station - used especially for routing.
    ///   - mapConfig: Configuring the underying map. See ``SBBMapConfiguration`` for its default values.
    ///   - sbbMapApiKey: Optional Journay Maps API key. See README.md to read about different possibilities on how to provide the API key.
    public init(
        centerTo: Binding<SBBMapCenter?> = .constant(nil),
        markers: Binding<[SBBMarker]> = .constant([]),
        lines: Binding<[SBBLine]> = .constant([]),
        circles: Binding<[SBBCircle]> = .constant([]),
        floorConnectors: Binding<[SBBFloorConnector]> = .constant([]),
        defaultFloor: Int = 0,
        geoJson: SBBGeoJson? = nil,
        mapConfig: SBBMapConfiguration = SBBMapConfiguration(),
        sbbMapApiKey: String? = nil
    ) {
        _centerTo = centerTo
        _markers = markers
        _lines = lines
        _circles = circles
        _floorConnectors = floorConnectors
        _selectedFloor = .init(initialValue: defaultFloor)
        self.showZoomButtons = false
        self.showStyleSwitchButton = true
        self.showFloorSelectionButtons = true
        self.showCopyright = false
        self.sbbGeoJson = geoJson ?? .empty
        self.mapConfig = mapConfig
        self.sbbMapApiKey = sbbMapApiKey ?? (Bundle.main.infoDictionary?["JOURNEYMAPS_API_KEY"] as? String) ?? ""
        self.defaultFloor = defaultFloor
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let accessibilityText = mapConfig.accessibilityText {
                    mapView
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(Text(accessibilityText))
                        .accessibilitySortPriority(1)
                } else {
                    mapView
                }
            }
            buttonsView

        }
        .fullScreenCover(isPresented: $showCopyrightView) {
            CopyrightModalView(attributions: attributions, isPresented: $showCopyrightView)
        }
        .animation(.easeInOut, value: compassViewVisible)
        .overlay {
            Alert(errorText: $errorText)
        }
    }

    private var mapView: some View {
        MapLibreView(
            compassViewVisible: $compassViewVisible,
            userLocationVisible: $userLocationVisible,
            possibleFloors: $possibleFloors,
            selectedFloor: $selectedFloor,
            mapAction: $mapAction,
            errorText: $errorText,
            attributions: $attributions,
            showAttributions: $showCopyrightView,
            centerTo: centerTo,
            markers: markers,
            lines: lines,
            circles: circles,
            floorConnectors: floorConnectors,
            defaultFloor: defaultFloor,
            mapConfig: mapConfig,
            mapApiKey: sbbMapApiKey,
            tappedMapCoordinateAction: { coord in
                DispatchQueue.main.async {
                    onMapTapped?(coord)
                }
            },
            selectedPoiAction: { newPoi in
                DispatchQueue.main.async {
                    selectedPoi?(newPoi)
                }
            },
            deselectAllPoisAction: {
                DispatchQueue.main.async {
                    deselectedAllPois?()
                }
            }
        )
        .onChange(of: centerTo) { newCenter in
            if let newCenter {
                mapAction = .centerTo(center: newCenter)
                centerTo = nil
            }
        }
        .onChange(of: markers) { newCustomMarkers in
            mapAction = .displayAnnotations(markers: newCustomMarkers, lines: lines, circles: circles, floorConnectors: floorConnectors)
        }
        .onChange(of: lines) { newCustomLines in
            mapAction = .displayAnnotations(markers: markers, lines: newCustomLines, circles: circles, floorConnectors: floorConnectors)
        }
        .onChange(of: circles) { newCustomCircles in
            mapAction = .displayAnnotations(markers: markers, lines: lines, circles: newCustomCircles, floorConnectors: floorConnectors)
        }
        .onChange(of: floorConnectors) { newFloorConnectors in
            mapAction = .displayAnnotations(markers: markers, lines: lines, circles: circles, floorConnectors: newFloorConnectors)
        }
        .onChange(of: sbbGeoJson) { [sbbGeoJson] newValue in
            let oldValue = sbbGeoJson
            mapAction = .displayGeoJson(oldGeoJson: oldValue, newGeoJson: newValue)
        }
    }

    private var buttonsView: some View {
        VStack {
            if mapConfig.showsUserLocation && userLocationVisible {
                SBBMapButton(image: Image("arrow-compass-small", bundle: .module)) {
                    mapAction = .centerToUserLocation
                }
                .accessibilityLabel(Text("Center to your location", bundle: .module))
            }
            if showStyleSwitchButton {
                SBBMapButton(image: Image("layers-small", bundle: .module)) {
                    mapAction = .toggleSatellite
                }
                .accessibilityLabel(Text("Toggle satellite", bundle: .module))
            }
            if showZoomButtons {
                ZoomButton(
                    increaseAction: {
                        mapAction = .increaseZoom
                    },
                    decreaseAction: {
                        mapAction = .decreaseZoom
                    })
            }

            if showFloorSelectionButtons {
                FloorSelectionButton(possibleFloors: possibleFloors, selectedFloor: $selectedFloor)
            }

            Spacer()

            if showCopyright {
                Button(action: {
                    showCopyrightView = true
                }) {
                    Text("©")
                        .font(.system(size: 14, weight: .light))
                }
                .buttonStyle(SBBMapButtonStyle(size: 28))
                .padding(.bottom, copyrightBottomPadding)
            }
        }
        .padding(.top, mapButtonTopPadding)
        .padding(.top, compassViewVisible ? max(40 - mapButtonTopPadding, 0) : 0)
        .padding(.horizontal, mapButtonHorizontalPadding)
        .padding()
    }
}

#Preview {
    SBBMapView(
        centerTo: .constant(
            SBBMapCenter(
                coordinate: CLLocationCoordinate2D(
                    latitude: 46.9491, longitude: 7.4388))))
}
