//
// Copyright © 2026 SBB. All rights reserved.
//

import SwiftUI

public struct SBBMapButton: View {

    let image: Image
    let action: () -> Void

    public init(image: Image, action: @escaping () -> Void) {
        self.image = image
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            image
        }
        .buttonStyle(SBBMapButtonStyle())
    }
}

struct SBBMapButtonStyle: ButtonStyle {

    let size: CGFloat
    let color: Color

    init(size: CGFloat = 33, color: Color = Color("buttonBackground", bundle: .module)) {
        self.size = size
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(configuration.isPressed ? Color("buttonPressed", bundle: .module) : color)
            .clipShape(Circle())
            .background(Circle().stroke(lineWidth: 1).foregroundStyle(Color("divider", bundle: .module)))
            .foregroundColor(Color("textBlack", bundle: .module))
    }
}

#Preview {
    VStack {
        SBBMapButton(image: Image("arrow-compass-small", bundle: Bundle.module)) {}
        SBBMapButton(image: Image("layers-small", bundle: Bundle.module)) {}
    }
}
