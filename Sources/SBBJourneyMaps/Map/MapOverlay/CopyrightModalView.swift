//
// Copyright © 2026 SBB. All rights reserved.
//

import SwiftUI

struct BackgroundTransparentView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
            view.superview?.superview?.layer.removeAllAnimations()
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct CopyrightModalView: View {
    @Binding private var isPresented: Bool
    let attributions: [Attribution]?

    init(attributions: [Attribution]?, isPresented: Binding<Bool>) {
        self.attributions = attributions
        self._isPresented = isPresented
    }

    private var contentView: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text("MapLibre Maps SDK for iOS")
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image("cross-small", bundle: .module)
                    }
                    .buttonStyle(SBBMapButtonStyle(size: 28, color: Color("viewBackground", bundle: .module)))
                    .accessibilityLabel(String(localized: "close"))
                }
                .padding(16)

                if let attributions {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(attributions, id: \.title) { attribution in
                            Button(action: {
                                guard let url = attribution.url, UIApplication.shared.canOpenURL(url) else { return }
                                UIApplication.shared.open(url)
                            }) {
                                HStack {
                                    Text(attribution.title)
                                    Spacer()
                                }
                                .frame(minHeight: 44)
                                .padding(.horizontal, 16)
                            }
                            if attribution != attributions.last {
                                Rectangle()
                                    .fill(Color("divider", bundle: .module))
                                    .frame(height: 1)
                            }
                        }
                    }
                    .foregroundStyle(Color("textBlack", bundle: .module))
                    .background(Color("viewBackground", bundle: .module))
                    .cornerRadius(16, corners: .allCorners)
                    .padding(.bottom, 32)
                    .padding(.horizontal, 16)
                }
            }
            .background(Color("background", bundle: .module).ignoresSafeArea(edges: .bottom))
            .cornerRadius(16, corners: [.topLeft, .topRight])
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.clear)
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            contentView
        }
        .background(BackgroundTransparentView())
    }
}

#Preview {
    CopyrightModalView(
        attributions: [
            Attribution(title: "Attribution1", url: nil),
            Attribution(title: "Attribution2", url: nil),
            Attribution(title: "Attribution3", url: nil),
        ], isPresented: .constant(true))
}
