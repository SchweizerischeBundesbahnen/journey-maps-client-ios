//
// Copyright © 2026 SBB. All rights reserved.
//

import CoreLocation
import SBBDesignSystemMobileSwiftUI
import SBBJourneyMaps
import SwiftUI

struct GeoJSONMapsView: View {

    @State private var center: SBBMapCenter?
    @State private var sbbGeoJson: SBBGeoJson?

    var body: some View {
        ZStack(alignment: .bottom) {
            SBBMapView(centerTo: $center, geoJson: sbbGeoJson)
                .edgesIgnoringSafeArea(.all)

            VStack {

                Button {
                    sbbGeoJson = nil
                } label: {
                    Text("Remove GeoJson")
                }
                .buttonStyle(SBBPrimaryButtonStyle())

                Button {
                    sbbGeoJson = SBBGeoJson(geoJson: geoJsonExampleThunParkRail, fillColor: .blue, lineColor: .red, lineWidth: 3)
                } label: {
                    Text("Display custom GeoJson on Top")
                }
                .buttonStyle(SBBPrimaryButtonStyle())

                Button {
                    sbbGeoJson = SBBGeoJson(geoJson: geoJsonExampleThunParkRail, existingShapeSourceIdentifier: .journeyPoisAreas)
                } label: {
                    Text("Display SBB GeoJson on JourneyMaps")
                }
                .buttonStyle(SBBPrimaryButtonStyle())

                Button {
                    center = SBBMapCenter(coordinate: .thunParkRide)
                } label: {
                    Text("Center to Thun Park & Ride")
                }
                .buttonStyle(SBBPrimaryButtonStyle())
            }
            .sbbScreenPadding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("GeoJSON")
    }

    let geoJsonExampleThunParkRail =
        """
        {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "properties": {
                "category": "parking"
              },
              "geometry": {
                "type": "MultiPolygon",
                "coordinates": [
                  [
                    [
                      [
                        7.6314512,
                        46.75345729
                      ],
                      [
                        7.63190119,
                        46.75298117
                      ],
                      [
                        7.63196292,
                        46.75301012
                      ],
                      [
                        7.63149923,
                        46.75348436
                      ],
                      [
                        7.6314512,
                        46.75345729
                      ]
                    ]
                  ],
                  [
                    [
                      [
                        7.63076676,
                        46.75420434
                      ],
                      [
                        7.63088091,
                        46.75409915
                      ],
                      [
                        7.63099028,
                        46.75415147
                      ],
                      [
                        7.63087881,
                        46.75425847
                      ],
                      [
                        7.63076676,
                        46.75420434
                      ]
                    ]
                  ],
                  [
                    [
                      [
                        7.63063864,
                        46.75412128
                      ],
                      [
                        7.63074226,
                        46.75405412
                      ],
                      [
                        7.63079033,
                        46.75409025
                      ],
                      [
                        7.6306867,
                        46.75415741
                      ],
                      [
                        7.63063864,
                        46.75412128
                      ]
                    ]
                  ],
                  [
                    [
                      [
                        7.63092865,
                        46.75404475
                      ],
                      [
                        7.63147554,
                        46.75356044
                      ],
                      [
                        7.63155024,
                        46.75360015
                      ],
                      [
                        7.63100869,
                        46.75408445
                      ],
                      [
                        7.63092865,
                        46.75404475
                      ]
                    ]
                  ],
                  [
                    [
                      [
                        7.63108984,
                        46.75414482
                      ],
                      [
                        7.63106839,
                        46.75409244
                      ],
                      [
                        7.63193982,
                        46.75337391
                      ],
                      [
                        7.63211811,
                        46.75319986
                      ],
                      [
                        7.63231257,
                        46.75295177
                      ],
                      [
                        7.63239975,
                        46.75283783
                      ],
                      [
                        7.63245339,
                        46.75285713
                      ],
                      [
                        7.63237426,
                        46.75297842
                      ],
                      [
                        7.63225491,
                        46.75313186
                      ],
                      [
                        7.63211306,
                        46.75328377
                      ],
                      [
                        7.63195079,
                        46.75344549
                      ],
                      [
                        7.63180729,
                        46.75356494
                      ],
                      [
                        7.6315934,
                        46.75373766
                      ],
                      [
                        7.63126885,
                        46.75400412
                      ],
                      [
                        7.63108984,
                        46.75414482
                      ]
                    ]
                  ],
                  [
                    [
                      [
                        7.6315656,
                        46.75349556
                      ],
                      [
                        7.63200548,
                        46.75303154
                      ],
                      [
                        7.63212082,
                        46.7530784
                      ],
                      [
                        7.63187942,
                        46.75333201
                      ],
                      [
                        7.63165411,
                        46.75353875
                      ],
                      [
                        7.6315656,
                        46.75349556
                      ]
                    ]
                  ]
                ]
              }
            }
          ]
        }
        """
}

#Preview {
    GeoJSONMapsView()
}
