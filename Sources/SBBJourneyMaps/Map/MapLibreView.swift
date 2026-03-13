//
// Copyright © 2026 SBB. All rights reserved.
//

import Foundation
import MapLibre
import SwiftUI

struct MapLibreView: UIViewRepresentable {

    @Environment(\.colorScheme) private var colorScheme

    enum MapLibreAction {
        case increaseZoom
        case decreaseZoom
        case scrollTo(position: CLLocationCoordinate2D, selectUnderlyingPoi: Bool)
        case centerTo(center: SBBMapCenter)
        case zoomTo(position: CLLocationCoordinate2D, zoomLevel: Double, selectUnderlyingPoi: Bool)
        case toggleSatellite
        case centerToUserLocation
        case displayAnnotations(markers: [SBBMarker]?, lines: [SBBLine]?, circles: [SBBCircle]?, floorConnectors: [SBBFloorConnector]?)
        case displayGeoJson(oldGeoJson: SBBGeoJson, newGeoJson: SBBGeoJson)
    }

    @Binding private var compassViewVisible: Bool
    @Binding private var userLocationVisible: Bool
    @Binding private var possibleFloors: [Int]
    @Binding var selectedFloor: Int
    @Binding private var mapAction: MapLibreAction?
    @Binding private var errorText: String
    @Binding private var attributions: [Attribution]?
    @Binding private var showAttributions: Bool

    private let defaultFloor: Int

    private let mapConfig: SBBMapConfiguration
    private let mapApiKey: String

    private let tappedMapCoordinateAction: ((CLLocationCoordinate2D) -> Void)?
    let selectedPoiAction: ((SBBMapPoi) -> Void)?
    private let deselectAllPoisAction: (() -> Void)?

    @State var showAerialInsteadBaseStyle = false
    @State private var currentTapPoint: CGPoint?
    @State private var allLvlLayers: [MLNStyleLayer] = []

    @State private var currentPoiCategories = SBBPoiCategoryType.allCases
    @State var currentFloorLevel: Int = 0
    @State var currentCustomMarkers: [SBBMarker] = []
    @State var currentCustomLines: [SBBLine] = []
    @State var currentCustomCircles: [SBBCircle] = []
    @State var currentFloorConnectors: [SBBFloorConnector] = []

    private var initialCenter: SBBMapCenter?
    private var geographicalCenterCH: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: 46.801111, longitude: 8.226667)
    }

    private let style: MapStyle

    private var darkMode: Bool {
        colorScheme == .dark
    }
    private var styleToUse: URL {
        style.styleToUse(showAerial: showAerialInsteadBaseStyle, darkMode: darkMode)
    }

    init(
        compassViewVisible: Binding<Bool>,
        userLocationVisible: Binding<Bool>,
        possibleFloors: Binding<[Int]>,
        selectedFloor: Binding<Int>,
        mapAction: Binding<MapLibreAction?>,
        errorText: Binding<String>,
        attributions: Binding<[Attribution]?>,
        showAttributions: Binding<Bool>,
        centerTo: SBBMapCenter?,
        markers: [SBBMarker]? = nil,
        lines: [SBBLine]? = nil,
        circles: [SBBCircle]? = nil,
        geoJson: SBBGeoJson? = nil,
        floorConnectors: [SBBFloorConnector]? = nil,
        defaultFloor: Int,
        mapConfig: SBBMapConfiguration,
        mapApiKey: String,
        tappedMapCoordinateAction: ((CLLocationCoordinate2D) -> Void)?,
        selectedPoiAction: ((SBBMapPoi) -> Void)?,
        deselectAllPoisAction: (() -> Void)?
    ) {
        _compassViewVisible = compassViewVisible
        _userLocationVisible = userLocationVisible
        _possibleFloors = possibleFloors
        _selectedFloor = selectedFloor
        _mapAction = mapAction
        _errorText = errorText
        _attributions = attributions
        _showAttributions = showAttributions
        self.mapConfig = mapConfig
        self.mapApiKey = mapApiKey
        self.tappedMapCoordinateAction = tappedMapCoordinateAction
        self.selectedPoiAction = selectedPoiAction
        self.deselectAllPoisAction = deselectAllPoisAction
        self.initialCenter = centerTo
        self.currentCustomMarkers = markers ?? []
        self.currentCustomCircles = circles ?? []
        self.currentCustomLines = lines ?? []
        self.currentFloorConnectors = floorConnectors ?? []
        self.defaultFloor = defaultFloor
        self.style = MapStyle(mapApiKey: mapApiKey)
    }

    func makeUIView(context: Context) -> MLNMapView {
        // Default is base style
        let styleURL = styleToUse

        let mapView = MLNMapView(frame: .zero, styleURL: styleURL)
        // not configurable yet
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true

        mapConfig.apply(on: mapView)

        mapView.delegate = context.coordinator

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(_:)))
        mapView.addGestureRecognizer(tapGesture)
        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {
        let newStyleToUse = styleToUse
        let currentStyle = mapView.styleURL!
        if newStyleToUse != currentStyle {
            mapView.styleURL = newStyleToUse
        }

        mapConfig.apply(on: mapView)

        if showAttributions {
            let attributionInfos: [MLNAttributionInfo]? = {
                guard let style = mapView.style else { return nil }
                let attributions = style.sources
                    .compactMap({ $0 as? MLNTileSource })
                    .flatMap({ $0.attributionInfos })  // sort reversed alphabetically, so SBB is on top
                return Set(attributions).sorted { $0.title.string.compare($1.title.string, options: .caseInsensitive) == .orderedDescending }
            }()
            if let attributionInfos {
                DispatchQueue.main.async {
                    self.attributions = attributionInfos.compactMap({ Attribution(title: $0.title.string, url: $0.url) })
                }
            }
        }

        // Map actions
        if let mapAction {
            switch mapAction {
            case .increaseZoom:
                ZoomAndCenter.increaseZoom(mapView)
            case .decreaseZoom:
                ZoomAndCenter.decreaseZoom(mapView)
            case .scrollTo(position: let newCenter, let selectUnderlyingPoi):
                let currentZoomLevel = mapView.zoomLevel
                ZoomAndCenter.center(toPosition: newCenter, zoomLevel: currentZoomLevel, selectUnderlyingPoi: selectUnderlyingPoi, onMapView: mapView, callback: self.selectedPoiAction)
            case .zoomTo(position: let newCenter, zoomLevel: let newZoomLevel, let selectUnderlyingPoi):
                ZoomAndCenter.center(toPosition: newCenter, zoomLevel: newZoomLevel, selectUnderlyingPoi: selectUnderlyingPoi, onMapView: mapView, callback: self.selectedPoiAction)
            case .toggleSatellite:
                DispatchQueue.main.async {
                    showAerialInsteadBaseStyle.toggle()
                }
            case .centerTo(let center):
                if let coordinate = center.coordinate, let zoomLevel = center.zoomLevel {
                    ZoomAndCenter.center(toPosition: coordinate, zoomLevel: zoomLevel, selectUnderlyingPoi: center.selectUnderlyingPoi, onMapView: mapView, callback: self.selectedPoiAction)
                } else if let bboxSW = center.boundingBoxSW, let bboxNE = center.boundingBoxNE {
                    ZoomAndCenter.center(to: MLNCoordinateBounds(sw: bboxSW, ne: bboxNE), onMapView: mapView)
                }
            case .centerToUserLocation:
                ZoomAndCenter.centerToCurrentLocation(onMapView: mapView)
            case .displayAnnotations(let markers, let lines, let circles, let floorConnectors):
                Annotator.updateAnnotations(currentCustomLines, to: lines, on: mapView, withFloor: currentFloorLevel)
                Annotator.updateAnnotations(currentCustomCircles, to: circles, on: mapView, withFloor: currentFloorLevel)
                Annotator.updateAnnotations(currentCustomMarkers, to: markers, on: mapView, withFloor: currentFloorLevel)
                Annotator.updateAnnotations(
                    currentFloorConnectors, to: floorConnectors, on: mapView, withFloor: currentFloorLevel,
                    tapAction: { floor in
                        DispatchQueue.main.async {
                            self.selectedFloor = floor
                        }
                    })
                DispatchQueue.main.async {
                    currentCustomMarkers = markers ?? []
                    currentCustomLines = lines ?? []
                    currentCustomCircles = circles ?? []
                    currentFloorConnectors = floorConnectors ?? []
                }
            case .displayGeoJson(let oldGeoJson, let newGeoJson):
                oldGeoJson.deleteFromMapView(mapView)
                newGeoJson.addToMapView(mapView)
            }
            DispatchQueue.main.async {
                self.mapAction = nil
            }
        }

        // Floor change
        if currentFloorLevel != selectedFloor {
            Annotator.updateFloor(for: currentCustomLines, to: selectedFloor, on: mapView)
            Annotator.updateFloor(for: currentCustomMarkers, to: selectedFloor, on: mapView)
            Annotator.updateFloor(for: currentCustomCircles, to: selectedFloor, on: mapView)
            Annotator.updateFloor(for: currentFloorConnectors, to: selectedFloor, on: mapView)
            FloorFilter.replaceAllLvlLayersFloor(allLvlLayers, withLevel: selectedFloor)
            DispatchQueue.main.async {
                currentFloorLevel = selectedFloor
            }
        }

        // POI
        if currentPoiCategories != mapConfig.poiCategories {
            POIAnnotator.updatePOICategories(to: mapConfig.poiCategories, on: mapView)
            DispatchQueue.main.async {
                currentPoiCategories = mapConfig.poiCategories
            }
        }

        // Tap gesture
        if let currentTapPoint {
            let tappedCoordinate = mapView.convert(currentTapPoint, toCoordinateFrom: nil)
            tappedMapCoordinateAction?(tappedCoordinate)
            Annotator.maybeTapOn(currentFloorConnectors, onPoint: currentTapPoint, onMapView: mapView)
            POIAnnotator.selectNearestPoi(onPoint: currentTapPoint, onMapView: mapView, callback: selectedPoiAction)

            DispatchQueue.main.async {
                self.currentTapPoint = nil
            }
        }
    }

    func makeCoordinator() -> MapLibreView.Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MLNMapViewDelegate {
        var parent: MapLibreView

        init(_ control: MapLibreView) {
            self.parent = control
        }

        @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
            guard let mapView = sender.view as? MLNMapView else { return }
            let location = sender.location(in: mapView)
            parent.currentTapPoint = location
        }

        // MARK: Responding to Map Position Changes
        func mapView(_ mapView: MLNMapView, regionWillChangeAnimated animated: Bool) {
            POIAnnotator.deselectAllPois(onMapView: mapView, callback: self.parent.deselectAllPoisAction)
        }

        func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool) {
            let floors = FloorFilter.getFloorlist(ofMapView: mapView)
            DispatchQueue.main.async {
                if floors.isEmpty {
                    self.parent.selectedFloor = self.parent.defaultFloor
                }
                self.parent.possibleFloors = floors
                self.parent.compassViewVisible = mapView.compassView.alpha > 0
            }
        }

        func mapView(_ mapView: MLNMapView, didUpdate userLocation: MLNUserLocation?) {
            parent.userLocationVisible = userLocation?.location != nil
        }

        func mapViewDidFailLoadingMap(_ mapView: MLNMapView, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.errorText = error.localizedDescription
            }
        }

        // MARK: Loading the map
        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            // initial centering
            if let coordinate = self.parent.initialCenter?.coordinate, let zoomLevel = self.parent.initialCenter?.zoomLevel {
                ZoomAndCenter.center(toPosition: coordinate, zoomLevel: zoomLevel, selectUnderlyingPoi: false, onMapView: mapView, callback: nil)
            } else if let bboxSW = self.parent.initialCenter?.boundingBoxSW, let bboxNE = self.parent.initialCenter?.boundingBoxNE {
                ZoomAndCenter.center(to: MLNCoordinateBounds(sw: bboxSW, ne: bboxNE), onMapView: mapView)
            } else {
                ZoomAndCenter.center(toPosition: self.parent.geographicalCenterCH, zoomLevel: 6, onMapView: mapView)
            }

            self.parent.allLvlLayers = style.layers.filter({ $0.identifier.hasSuffix("-lvl") })
            POIAnnotator.updatePOICategories(to: self.parent.mapConfig.poiCategories, on: mapView)
            Annotator.updateAnnotations([], to: self.parent.currentCustomLines, on: mapView, withFloor: self.parent.defaultFloor)
            Annotator.updateAnnotations([], to: self.parent.currentCustomCircles, on: mapView, withFloor: self.parent.defaultFloor)
            Annotator.updateAnnotations([], to: self.parent.currentCustomMarkers, on: mapView, withFloor: self.parent.defaultFloor)
            Annotator.updateAnnotations(
                [], to: self.parent.currentFloorConnectors, on: mapView, withFloor: self.parent.defaultFloor,
                tapAction: { floor in
                    DispatchQueue.main.async {
                        self.parent.selectedFloor = floor
                    }
                })
            FloorFilter.replaceAllLvlLayersFloor(self.parent.allLvlLayers, withLevel: self.parent.defaultFloor)
        }
    }
}
