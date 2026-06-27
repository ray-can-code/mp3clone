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
                .fill(theme.wheel)
                .shadow(color: theme.wheelShadow, radius: 10, y: 5)
                .overlay {
                    Circle()
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                }
                .gesture(rotationGesture)

            wheelButton("MENU", offset: CGSize(width: 0, height: -78), action: onMenu)
            wheelButton("PREV", offset: CGSize(width: -82, height: 0), action: onPrevious)
            wheelButton("NEXT", offset: CGSize(width: 82, height: 0), action: onNext)
            wheelButton("PLAY", offset: CGSize(width: 0, height: 82), action: onPlayPause)

            Button(action: onSelect) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.bodyTop, theme.bodyBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        Circle()
                            .stroke(Color.black.opacity(0.10), lineWidth: 1)
                    }
                    .frame(width: 94, height: 94)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 252, height: 252)
    }

    private func wheelButton(_ label: String, offset: CGSize, action: @escaping () -> Void) -> some View {
        Button {
            action()
            pressedLabel = label
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                pressedLabel = nil
            }
        } label: {
            Text(label)
                .font(.system(size: label.count > 4 ? 16 : 18, weight: .heavy, design: .rounded))
                .foregroundColor(theme.wheelGlyph)
                .frame(width: 70, height: 44)
                .background {
                    Capsule()
                        .fill(pressedLabel == label ? Color.black.opacity(0.08) : Color.clear)
                }
        }
        .buttonStyle(.plain)
        .offset(offset)
    }

    private var rotationGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                let center = CGPoint(x: 126, y: 126)
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
