import SwiftUI
import UIKit

struct ClickWheelView: View {
    @Environment(\.playerTheme) private var theme

    var onRotate: (Int) -> Void
    var onMenu: () -> Void
    var onSelect: () -> Void
    var onPrevious: () -> Void
    var onNext: () -> Void
    var onPreviousLong: () -> Void
    var onNextLong: () -> Void
    var onPlayPause: () -> Void

    @State private var engine = ClickWheelEngine()
    @State private var pressedLabel: String?
    private let haptic = UISelectionFeedbackGenerator()

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
            wheelButton("<<", offset: CGSize(width: -78, height: 0), action: onPrevious, longAction: onPreviousLong, boxed: true)
            wheelButton(">>", offset: CGSize(width: 78, height: 0), action: onNext, longAction: onNextLong, boxed: true)
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
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in pressedLabel = "SELECT" }
                    .onEnded { _ in pressedLabel = nil }
            )
        }
        .frame(width: 220, height: 220)
        .onAppear {
            haptic.prepare()
        }
    }

    private func wheelButton(
        _ label: String,
        offset: CGSize,
        action: @escaping () -> Void,
        longAction: (() -> Void)? = nil,
        boxed: Bool
    ) -> some View {
        Button {
            action()
            haptic.selectionChanged()
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
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.45)
                .onEnded { _ in
                    longAction?()
                    haptic.selectionChanged()
                }
        )
        .offset(offset)
    }

    private var rotationGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                let center = CGPoint(x: 110, y: 110)
                let vector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
                let angle = Angle(radians: atan2(vector.dy, vector.dx))

                let steps = engine.update(angleDegrees: angle.degrees)
                if steps != 0 {
                    onRotate(steps)
                    haptic.selectionChanged()
                }
            }
            .onEnded { _ in
                engine.reset()
            }
    }
}
