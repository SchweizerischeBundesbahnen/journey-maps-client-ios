//
// Copyright © 2026 SBB. All rights reserved.
//

class TapManager {
    static let shared = TapManager()
    private var tapHandlers: [String: () -> Void] = [:]

    private init() {}

    func setTapHandler(for id: String, handler: @escaping () -> Void) {
        tapHandlers[id] = handler
    }

    func handleTap(for id: String) {
        tapHandlers[id]?()
    }

    func removeTapHandler(for id: String) {
        tapHandlers.removeValue(forKey: id)
    }
}
