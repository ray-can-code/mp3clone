import XCTest
@testable import MP3Build

final class ClickWheelEngineTests: XCTestCase {
    func testRotationBelowThresholdDoesNotMoveSelection() {
        var engine = ClickWheelEngine(stepDegrees: 18)

        XCTAssertEqual(engine.update(angleDegrees: 0), 0)
        XCTAssertEqual(engine.update(angleDegrees: 10), 0)
    }

    func testRotationPastThresholdProducesStep() {
        var engine = ClickWheelEngine(stepDegrees: 18)

        XCTAssertEqual(engine.update(angleDegrees: 0), 0)
        XCTAssertEqual(engine.update(angleDegrees: 22), 1)
    }

    func testFastRotationAcceleratesSteps() {
        var engine = ClickWheelEngine(stepDegrees: 18)

        XCTAssertEqual(engine.update(angleDegrees: 0), 0)
        XCTAssertEqual(engine.update(angleDegrees: 80), 4)
    }

    func testWraparoundUsesShortestAngleDelta() {
        var engine = ClickWheelEngine(stepDegrees: 18)

        XCTAssertEqual(engine.update(angleDegrees: 170), 0)
        XCTAssertEqual(engine.update(angleDegrees: -170), 1)
    }
}
