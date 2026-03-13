//
// Copyright © 2026 SBB. All rights reserved.
//

import SBBDesignSystemMobileSwiftUI
import SwiftUI

@main
struct SBBJourneyMapsDemoApp: App {

    init() {
        SBBAppearance.setupSBBAppearance()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
