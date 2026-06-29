import SwiftUI

struct ClickWheelView: View {
    @Environment(\.playerTheme) private var theme

    var onRotate: (Int) -> Void
    var onMenu: () -> Void
    var onSelect: () -> Void
    var onPrevious: () -> Void
    var onNext: () -> Void
    var onPlayPause: () -> Void

    @State private var lastAngle: Angle?
    @State private var pressedLabel: String?

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white,
                            theme.wheel,
                            Color(red: 0.70, green: 0.76, blue: 0.82)
                        ],
                        center: .topLeading,
                        startRadius: 8,
                        endRadius: 138
                    )
                )
                .shadow(color: theme.wheelShadow, radius: 12, y: 8)
                .overlay {
                    Circle()
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                }
                .gesture(rotationGesture)

            wheelButton("BACK", offset: CGSize(width: 0, height: -76), action: onMenu, boxed: false)
            wheelButton("<<", offset: CGSize(width: -78, height: 0), action: onPrevious, boxed: true)
            wheelButton(">>", offset: CGSize(width: 78, height: 0), action: onNext, boxed: true)
            wheelButton(">II", offset: CGSize(width: 0, height: 78), action: onPlayPause, boxed: true)

            Button(action: onSelect) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white, Color(red: 0.82, green: 0.87, blue: 0.92)],
                            center: .topLeading,
                            startRadius: 4,
                            endRadius: 62
                        )
                    )
                    .overlay {
                        Circle()
                            .stroke(Color.black.opacity(0.10), lineWidth: 1)
                    }
                    .frame(width: 78, height: 78)
                    .shadow(color: .black.opacity(0.14), radius: 7, y: 4)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 220, height: 220)
    }

    private func wheelButton(_ label: String, offset: CGSize, action: @escaping () -> Void, boxed: Bool) -> some View {
        Button {
            action()
            pressedLabel = label
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                pressedLabel = nil
            }
        } label: {
            Text(label)
                .font(.system(size: boxed ? 17 : 13, weight: .heavy, design: .rounded))
                .foregroundColor(theme.wheelGlyph)
                .frame(width: boxed ? 34 : 70, height: boxed ? 28 : 36)
                .background {
                    if boxed {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color(red: 0.42, green: 0.58, blue: 0.68).opacity(pressedLabel == label ? 0.92 : 0.78))
                            .overlay {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(Color.white.opacity(0.38), lineWidth: 1)
                            }
                    } else {
                        Capsule()
                            .fill(pressedLabel == label ? Color.black.opacity(0.08) : Color.clear)
                    }
                }
        }
        .buttonStyle(.plain)
        .offset(offset)
    }

    private var rotationGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                let center = CGPoint(x: 110, y: 110)
                let vector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
                let angle = Angle(radians: atan2(vector.dy, vector.dx))

                guard let lastAngle else {
                    self.lastAngle = angle
                    return
                }

                var delta = angle.degrees - lastAngle.degrees
                if delta > 180 { delta -= 360 }
                if delta < -180 { delta += 360 }

                if abs(delta) > 18 {
                    onRotate(delta > 0 ? 1 : -1)
                    self.lastAngle = angle
                }
            }
            .onEnded { _ in
                lastAngle = nil
            }
    }
}
