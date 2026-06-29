import Foundation

struct ClickWheelEngine {
    var stepDegrees: Double = 18
    var maximumStepsPerUpdate: Int = 4

    private var lastAngleDegrees: Double?
    private var accumulatedDegrees: Double = 0

    mutating func update(angleDegrees: Double) -> Int {
        guard let lastAngleDegrees else {
            self.lastAngleDegrees = angleDegrees
            return 0
        }

        var delta = angleDegrees - lastAngleDegrees
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }

        accumulatedDegrees += delta
        self.lastAngleDegrees = angleDegrees

        guard abs(accumulatedDegrees) >= stepDegrees else {
            return 0
        }

        let direction = accumulatedDegrees > 0 ? 1 : -1
        let steps = min(maximumStepsPerUpdate, Int(abs(accumulatedDegrees) / stepDegrees))
        accumulatedDegrees -= Double(direction * steps) * stepDegrees
        return direction * steps
    }

    mutating func reset() {
        lastAngleDegrees = nil
        accumulatedDegrees = 0
    }
}
