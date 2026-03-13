//
// Copyright © 2026 SBB. All rights reserved.
//

import SwiftUI

struct FloorSelectionButton: View {
    @Environment(\.colorScheme) private var colorScheme

    private let possibleFloors: [Int]
    @Binding private var selectedFloor: Int

    init(possibleFloors: [Int], selectedFloor: Binding<Int>) {
        self.possibleFloors = possibleFloors
        self._selectedFloor = selectedFloor
    }

    private var isDarkMode: Bool {
        colorScheme == .dark
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(possibleFloors, id: \.self) { floor in
                let first = floor == possibleFloors.first
                let last = floor == possibleFloors.last
                let selected = floor == selectedFloor

                Button {
                    selectedFloor = floor
                } label: {
                    Text("\(floor)")
                        .font(.system(size: 14))
                        .foregroundColor(floorForeground(selected: selected))
                        .frame(maxWidth: .infinity)
                        .padding(4)
                }
                // cornerRadius of 22 is not displayed properly
                // try the new .clipShape with UnevenRoundedRectangle on iOS 16+, with Xcode 15
                // https://stackoverflow.com/questions/56760335/round-specific-corners-swiftui
                .background(
                    floorBackground(selected: selected)
                        .cornerRadius(first ? 12 : 4, corners: .topLeft)
                        .cornerRadius(first ? 12 : 4, corners: .topRight)
                        .cornerRadius(last ? 12 : 4, corners: .bottomLeft)
                        .cornerRadius(last ? 12 : 4, corners: .bottomRight)
                )
                .padding(4)
                .background(alignment: .bottom) {
                    Rectangle().frame(height: 1)
                        .padding(.horizontal, 4)
                        .foregroundColor(last ? .clear : listDivider)
                }
                .accessibilityLabel(selected ? Text("Floor \(floor), selected", bundle: .module) : Text("Floor \(floor)", bundle: .module))
            }
        }
        .frame(width: 33)
        .background(isDarkMode ? Color.black : Color.white)
        .cornerRadius(22)
        .background(RoundedRectangle(cornerRadius: 22).stroke(lineWidth: 1).foregroundStyle(Color("divider", bundle: .module)))
        .animation(.easeInOut, value: possibleFloors)
    }

    private func floorForeground(selected: Bool) -> Color {
        if isDarkMode {
            return selected ? .black : .white
        } else {
            return selected ? .white : .black
        }
    }

    private func floorBackground(selected: Bool) -> Color {
        if isDarkMode {
            return selected ? Color("levelSwitchPressed", bundle: .module) : .black
        } else {
            return selected ? Color.black : .clear
        }
    }

    var listDivider: Color {
        Color("divider", bundle: .module)
    }
}

#Preview {
    FloorSelectionButton(possibleFloors: [1, 2, 3], selectedFloor: .constant(2))
}
