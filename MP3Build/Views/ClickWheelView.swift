import SwiftUI
import AudioToolbox
import UIKit

struct ClickWheelView: View {
    @Environment(\.playerTheme) private var theme

    var onRotate: (Int) -> Void
    var onMenu: () -> Void
    var onSelect: () -> Void
    var onPrevious: () -> Void
    var onNext: () -> Void
    var onPlayPause: () -> Void
    var onPreviousLong: () -> Void = {}
    var onNextLong: () -> Void = {}
    var onPlayPauseLong: () -> Void = {}

    @State private var engine = ClickWheelEngine(stepDegrees: 14, maximumStepsPerUpdate: 5)
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

            wheelTextButton("BACK", offset: CGSize(width: 0, height: -76), action: onMenu)
            wheelIconButton("backward.fill", offset: CGSize(width: -78, height: 0), action: onPrevious, longAction: onPreviousLong)
            wheelIconButton("forward.fill", offset: CGSize(width: 78, height: 0), action: onNext, longAction: onNextLong)
            wheelIconButton("playpause.fill", offset: CGSize(width: 0, height: 78), action: onPlayPause, longAction: onPlayPauseLong)

            Button {
                pulse(.medium)
                onSelect()
            } label: {
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

    private func wheelTextButton(_ label: String, offset: CGSize, action: @escaping () -> Void) -> some View {
        Button {
            feedback(.light)
            action()
            pressedLabel = label
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                pressedLabel = nil
            }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(theme.wheelGlyph)
                .frame(width: 70, height: 36)
                .background {
                    Capsule()
                        .fill(pressedLabel == label ? Color.black.opacity(0.08) : Color.clear)
                }
        }
        .buttonStyle(.plain)
        .offset(offset)
    }

    private func wheelIconButton(
        _ systemName: String,
        offset: CGSize,
        action: @escaping () -> Void,
        longAction: @escaping () -> Void = {}
    ) -> some View {
        Button {
            feedback(.light)
            action()
            pressedLabel = systemName
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                pressedLabel = nil
            }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(theme.wheelGlyph)
                .frame(width: 38, height: 31)
                .background {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color(red: 0.42, green: 0.58, blue: 0.68).opacity(pressedLabel == systemName ? 0.92 : 0.78))
                        .overlay {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(Color.white.opacity(0.38), lineWidth: 1)
                        }
                }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.45)
                .onEnded { _ in
                    feedback(.heavy)
                    longAction()
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

                guard steps != 0 else { return }
                feedback(.light)
                let direction = steps > 0 ? 1 : -1
                for _ in 0..<abs(steps) {
                    onRotate(direction)
                }
            }
            .onEnded { _ in
                engine.reset()
            }
    }

    private func feedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
        AudioServicesPlaySystemSound(1104)
    }
}
