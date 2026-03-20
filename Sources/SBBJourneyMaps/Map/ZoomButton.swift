//
// Copyright © 2026 SBB. All rights reserved.
//

import SwiftUI

struct ZoomButton: View {
    @Environment(\.colorScheme) private var colorScheme

    let increaseAction: () -> Void
    let decreaseAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button {
                increaseAction()
            } label: {
                Image("plus-small", bundle: .module)
                    .foregroundColor(Color("textBlack", bundle: .module))
                    .padding(4)
            }
            .accessibilityLabel(Text("Increase zoom", bundle: .module))

            Button {
                decreaseAction()
            } label: {
                Image("minus-small", bundle: .module)
                    .foregroundColor(Color("textBlack", bundle: .module))
                    .padding(4)
            }
            .accessibilityLabel(Text("Decrease zoom", bundle: .module))
        }
        .frame(width: 33)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(22)
        .background(RoundedRectangle(cornerRadius: 22).stroke(lineWidth: 1).foregroundStyle(Color("divider", bundle: .module)))
    }
}
