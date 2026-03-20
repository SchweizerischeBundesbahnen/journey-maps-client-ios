//
//  Copyright © 2024 SBB. All rights reserved.
//

import SwiftUI

struct Alert: View {

    @Environment(\.colorScheme) private var colorScheme

    @Binding private var errorText: String

    init(errorText: Binding<String>) {
        self._errorText = errorText
    }

    private var darkMode: Bool {
        colorScheme == .dark
    }

    private var sbbRed: Color {
        Color("sbbRed", bundle: .module)
    }

    var contentView: some View {
        HStack(alignment: .center, spacing: 0) {
            Image("circle-cross-small", bundle: .module)
                .frame(maxHeight: .infinity)
                .foregroundStyle(Color.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                .background(sbbRed)
            Text(errorText)
                .fontWeight(.light)
                .font(.system(size: 14))
                .foregroundStyle(darkMode ? Color.white : .black)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(darkMode ? Color.black : sbbRed.opacity(0.05))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 2)
                .strokeBorder(lineWidth: 1)
                .foregroundColor(sbbRed)
        }
        .cornerRadius(2)
        .fixedSize(horizontal: false, vertical: true)
    }

    var body: some View {
        VStack {
            if !errorText.isEmpty {
                contentView
                    .onTapGesture {
                        errorText = ""
                    }
            }
            Spacer()
        }
    }
}

#Preview {
    VStack {
        Alert(errorText: .constant("This is a very long example text for Preview."))
            .frame(width: 300)
        Alert(errorText: .constant("This is a very long example text for Preview."))
            .frame(width: 200)
    }
}
