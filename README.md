# JourneyMaps Client iOS

This package allows you to easily incorporate SBB styled maps into your iOS application. It is built on top of MapLibre and meant as a client for the Journey Maps API. You need to register your application at [developer.sbb.ch](https://developer.sbb.ch/apis/) to receive an API key for style and routing usage (see details below).

#### Table Of Contents

- [Introduction](#Introduction)
- [Getting Started](#Getting-Started)
- [Contributing](#Contributing)
- [Documentation](#Documentation)
- [Code of Conduct](#code-of-conduct)
- [Coding Standards](#coding-standards)
- [License](#License)

<a id="Introduction"></a>

## Introduction

The package is meant as a client for the [Journey Maps API] and is based on the [MapLibre Native iOS] - solely for iOS.

<a id="Getting-Started"></a>

## Getting-Started

### Precondition

In order to access styles and tile data, you need to register your application to the [Journey Maps Tiles API] to receive an API Key.
Create an account (e.g. using SwissPass Login) to be able to setup an application and then register this application to the API.
You can get one by signing up on [developer.sbb.ch](https://developer.sbb.ch/apis/journey-maps-tiles/information).

You'll need iOS 16+, since the library is written in SwiftUI with a few advanced features.

### Setup

To include it with SPM, you will need to add the following dependency:
```
https://github.com/SchweizerischeBundesbahnen/journey-maps-client-ios.git
```

There are two possibilities to include the API Key you received from [developer.sbb.ch](https://developer.sbb.ch/apis/journey-maps-tiles/information): 

1. Inside Info.plist file with the key `JOURNEYMAPS_API_KEY`:
```
    <key>JOURNEYMAPS_API_KEY</key>
    <string><your-api-key></string>
```

2. Inserting it directly with the initialiser:
```
    SBBMapView(centerTo: $center, sbbMapApiKey: <your-api-key>)
```

(If both methods are used, the key given by the initialiser has priority over the one given with the Info.plist)


### Usage

To use the JourneyMaps, you have to import the `SBBJourneyMaps` Library. 

For displaying the map in its simplest form:

```
    var body: some View {
        SBBMapView()
    }
```


**Example code**

The default SBBMapView (see [DefaultJourneyMapsView.swift](./SBBJourneyMapsDemo/SBBJourneyMapsDemo/DefaultJourneyMapsView.swift))

#### Configuration possibilities

- Configuring the map itself via a SBBMapConfiguration

```
    var mapConfig: SBBMapConfiguration {
        SBBMapConfiguration(
            pitchEnabled: true,                 // default true
            rotateEnabled: true,                // default true
            showsUserLocation: true,            // default true
            showsScale: true,                   // default false
            scaleBarUsesMetricSystem: true,     // default true
            zoomEnabled: true,                  // default true
            scrollEnabled: true,                // default true
            poiCategories: [SBBPoiCategoryType] = SBBPoiCategoryType.allCases  // default all POI categories
        )
    }

    var body: some View {
        SBBMapView(centerTo: .constant(nil), mapConfig: mapConfig)
    }
```

- Move the map Buttons (style switch, floor selections) further down

```
    var body: some View {
        SBBMapView()
            .sbbMapButtonTopPadding(32)
    }
```

- Hide the map Buttons (style switch, floor selections)

```
    var body: some View {
        SBBMapView()
            .sbbMapShowFloorSelectionButtons(false)
            .sbbMapStyleSwitchButton(false)
    }
```

**Example code**

A configurable SBBMapView (see [ConfigurableJourneyMapsView.swift](./SBBJourneyMapsDemo/SBBJourneyMapsDemo/ConfigurableJourneyMapsView.swift))

#### Centering the Map to a specific coordinate

You can set an optional center coordinate.

```
    @State private var center: SBBMapCenter?

    var body: some View {
        SBBMapView(centerTo: $center)
    }
```

The SBBMapCenter can be set like this `center = SBBMapCenter(coordinate: <CLLocationCoordinate2D>)`

This center variable is automatically set to nil as soon as the map has been centered.

#### Centering the Map to the current location

Centering to the user location is done by pressing the corresponding button. It only appears when
1. in the SBBMapConfiguration, the parameter ``showsUserLocation`` is set to true
2. when the user location is visible on the map.


#### Display POI and getting its details

Point of Interests (POI) are automatically shown when the user zooms close enough in the map. You can select one by tapping on a POI. Its details is then propagated in a ``SBBMapPoi`` struct to a callback of the ``SBBMapView``. 

```
    var body: some View {
        SBBMapView()
            .onSbbMapPoiTap { poi in
                // SBBMapPoi of selected POI
            }
    }
```

Deselection of the POI on the map is done automatically when you move the map. In this case another callback is invoked:

```
    var body: some View {
        SBBMapView()
            .onSbbMapAllPoisDeselected { 
                // all SBBMapPois have been deselected
            }
    }
```

When centering the map, there is also the possibility to automatically select an underlying POI if one exists. For this case you can set the corresponding boolean directly in the SBBMapCenter struct like this

```
    ... = SBBMapCenter(coordinate: ..., selectUnderlyingPoi: true)
```

**Example code**

Displaying and interacting with POI (see [PoiJourneyMapsView.swift](./SBBJourneyMapsDemo/SBBJourneyMapsDemo/PoiJourneyMapsView.swift))

#### Getting map coordinates of tapped point

You can get the coordinates of the tapped point by implementing the following callback

```
    var body: some View {
        SBBMapView()
            .onSbbMapTap { coordinate
                // coordinate of tapped point on the map
            }
    }
```

#### Configure POI Categories to show on the map

You can select what POI Categories are shown on the map (after a certain zoom level) by specifying them in the SBBMapConfiguration. In the example below, only Park+Rail and Bike Sharing are shown. Not specifying any categories display all per default. See ```SBBPoiCategoryType``` for the list of all the possible Categories.

```
    var mapConfig: SBBMapConfiguration {
        SBBMapConfiguration(poiCategories: [.park_rail, .bike_sharing])
    }

    var body: some View {
        SBBMapView(mapConfig: mapConfig)
    }
```
Note: all operators of a category are displayed. Filtering of only specific operators is not supported (yet).


**Example code**

Filtering POI categories (see [PoiCategoriesMapsView.swift](./SBBJourneyMapsDemo/SBBJourneyMapsDemo/PoiCategoriesMapsView.swift))

#### Display annotations: markers, lines, circles and floor connectors
You can display markers, lines and circles on the map.

```
    @State private var markers: [SBBMarker] = []
    @State private var lines: [SBBLine] = []
    @State private var circles: [SBBCircles] = []
    @State private var floorConnectors: [SBBFloorConnector] = []
    
    var body: some View {
        SBBMapView(markers: $markers, lines: $lines, circles: $circles, floorConnectors: $floorConnectors)
    }
```

The annotations can then be set like this:

```
markers = [SBBMarker(
                id: <String>, 
                coordinates: <CLLocationCoordinates2D>, 
                image: <UIImage>)]
lines = [SBBLine(
                id: <String>, 
                coordinates: <CLLocationCoordinates2D>, 
                config: <SBBLineConfig>)]
circles = [SBBCircle(
                id: <String>, 
                coordinates: <CLLocationCoordinates2D>)]
floorConnectors = [SBBFloorConnector(
                            id: <String>, 
                            coordinates: <CLLocationCoordinates2D>, 
                            originFloor: <Int>, 
                            destinationFloor: <Int>, 
                            floorConnectorIcon: <UIImage>, 
                            directionIcon: <UIImage>)]
```

The floor connector appear only on the `originFloor`. On tap, the floor displayed is changed to `destinationFloor`.

**Example code**

Displaying annotations on the map (see [AnnotationsJourneyMapsView.swift](./SBBJourneyMapsDemo/SBBJourneyMapsDemo/AnnotationsJourneyMapsView.swift))

Using annotations to display a path (see [PathJourneyMapsView.swift](./SBBJourneyMapsDemo/SBBJourneyMapsDemo/PathJourneyMapsView.swift))

**Example code**

Display GeoJSON data on the map (see [GeoJSONMapsView.swift](./SBBJourneyMapsDemo/SBBJourneyMapsDemo/GeoJSONMapsView.swift))

#### Display GeoJSON data on the map

You can display GeoJSON data by providing a `SBBGeoJson` object to the `SBBMapView`.

```
    @State private var sbbGeoJson: SBBGeoJson?
    
    var body: some View {
        SBBMapView(geoJson: sbbGeoJson)
    }
```

There are two ways to create a `SBBGeoJson` object:

1. Any GeoJSON string with custom fillColor, lineColor and lineWidth. The area in the data is then display on top of the map:
```
    sbbGeoJson = SBBGeoJson(geoJson: geoJsonExampleThunParkRail, fillColor: .blue, lineColor: .red, lineWidth: 3)
```

2. Provinding a GeoJSON String to an existing area source of the currently selected default style (either "journey_maps_bright_v1", "journey_maps_dark_v1" or "journey_maps_aerial_v1"). The area in the data is then displayed with the colours defined in the style, if the data has the corresponding "category" key. This is especially useful for displaying Park+Rail areas.
```
    sbbGeoJson = SBBGeoJson(geoJson: geoJsonExampleThunParkRail, existingShapeSourceIdentifier: .journeyPoisAreas)
```


<a id="Documentation"></a>

## Documentation

Links to all relevant documentation files, including:

- [CODING_STANDARDS.md](CODING_STANDARDS.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [LICENSE.md](LICENSE.md)

<a id="License"></a>

## License

> Choose a license that meets the organization's legal requirements and supports the sharing and modification of the code.
> Please follow the internal Open Source guidelines while chosing the License.
> This repository includes two [suggested license texts](./suggested_licenses) (Apache 2.0 and EPL 2.0). Rename the license you prefer to [LICENSE.md](LICENSE.md) and remove the other one.

This project is licensed under [INSERT LICENSE].

<a id="Contributing"></a>

## Contributing

Open-source projects thrive on collaboration and contributions from the community. To encourage others to contribute to your project, you should provide clear guidelines on how to get involved.

This repository includes a [CONTRIBUTING.md](CONTRIBUTING.md) file that outlines how to contribute to the project, including how to submit bug reports, feature requests, and pull requests.

<a id="coding-standards"></a>

## Coding Standards

To maintain a high level of code quality and consistency across your project, you should establish coding standards that all contributors should follow.

This repository includes a [CODING_STANDARDS.md](CODING_STANDARDS.md) file that outlines the coding standards that you should follow when contributing to the project.

<a id="code-of-conduct"></a>

## Code of Conduct

To ensure that your project is a welcoming and inclusive environment for all contributors, you should establish a good [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
