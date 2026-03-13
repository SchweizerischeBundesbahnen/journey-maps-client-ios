# Release Notes SBB Journey Maps Client

## v1.5.0
### Features
- Style changes: The new default styles are: "journey_maps_bright_v1", "journey_maps_dark_v1" and "journey_maps_aerial_v1".
- More POIs: You can select over 130 different POI categories (before: 6). 
- GeoJSON: Adding GeoJSON strings is now possible. 
- MapLibre Library: v6.4.0 -> v6.20.1

## v1.4.0
### Features
- Annotations: lines, circles and floor connectors. As for the markers, `SBBMapView` now accepts `lines: Binding<[SBBLine]>`, `circles: Binding[SBBCircle]` and `floorConnectors: [SBBFloorConnector]`. Note that when initializing, they are added in order: lines, circles, markers and floor connectors. Take care of the order in which you change their value, as at the moment, the layers are simply rendered on top. Additionally, they are not deleted and re-added if they were already present.
- Default floor: a `selectedFloor` can be specified, the map will update to this selectedFloor if it is available; otherwise it will be reset to 0.
- Copyright button: `.sbbMapCopyright(<Bool>, bottomPadding: <CGFloat>). It will show a © Button on the map, and on click, will show the list of attributions.

### Breaking change
- `SBBMapView':`customMarkers` has been renamed to `markers`, `customAccessibilityText` has been renamed to `accessibilityText`.
- `SBBCustomMarker` has been renamed to `SBBMarker`. `name` has been renamed to `id`.

## v1.3.0
### Features
- When creating a `SBBMapView()`, one can use the parameters `customMarkers: Binding<[SBBCustomMarker]?>` to display markers on the map.
- Button for zooming in and out can be added with `.sbbMapShowZoomButtons(_ show: Bool)`
- The package is now localized and the button have proper accessibility labels.
- Additional (custom) accessibility label can be added to the map itself with the config `customAccessibilityText: String?`

## v1.2.0
### Features
- When setting a ```SBBMapCenter(center: <CLLocationCoordinate2D>, selectUnderlyingPoi: true)``` to center the map to a specific location, an underlying POI will be automatically selected as if someone would have tapped on it.
### Improvements
- Updating MapLibre version 5.13.0 to 6.4.0 (https://github.com/maplibre/maplibre-native/releases?q=ios&expanded=true)

## v1.1.0 
### Features
- Possibility to select different POI categories to show on the map
