import XCTest
@testable import LearnCore

final class SpacedRepetitionTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_700_000_000)
    private let day: TimeInterval = 86_400

    func testIntervalsGrowOneSixThenTimesEasiness() {
        var c = Flashcard(front: "hola", back: "hello")
        c = SM2.review(c, grade: .good, at: t0)
        XCTAssertEqual(c.intervalDays, 1)
        XCTAssertEqual(c.easiness, 2.5, accuracy: 1e-9) // q=4 leaves EF unchanged
        c = SM2.review(c, grade: .good, at: t0)
        XCTAssertEqual(c.intervalDays, 6)
        c = SM2.review(c, grade: .easy, at: t0)
        XCTAssertEqual(c.intervalDays, 15) // 6 * 2.5
        XCTAssertEqual(c.easiness, 2.6, accuracy: 1e-9)
        XCTAssertEqual(c.due, t0.addingTimeInterval(15 * day))
    }

    func testFailureResetsAndCountsLapse() {
        var c = Flashcard(front: "a", back: "b")
        c = SM2.review(c, grade: .good, at: t0)
        c = SM2.review(c, grade: .wrong, at: t0)
        XCTAssertEqual(c.repetitions, 0)
        XCTAssertEqual(c.intervalDays, 1)
        XCTAssertEqual(c.lapses, 1)
        XCTAssertEqual(c.easiness, 2.5 - 0.54, accuracy: 1e-9)
    }

    func testEasinessNeverDropsBelowMinimum() {
        var c = Flashcard(front: "a", back: "b")
        for _ in 0..<10 { c = SM2.review(c, grade: .blackout, at: t0) }
        XCTAssertEqual(c.easiness, SM2.minimumEasiness, accuracy: 1e-9)
    }

    func testDeckRejectsDuplicatesAndBlanks() {
        var deck = Deck(name: "Spanish")
        XCTAssertTrue(deck.add(front: "Hola", back: "Hello"))
        XCTAssertFalse(deck.add(front: " hola ", back: "Hi"))
        XCTAssertFalse(deck.add(front: "  ", back: "x"))
        XCTAssertEqual(deck.cards.count, 1)
    }

    func testStudyQueueOrdersOverdueThenNew() {
        var deck = Deck(name: "d")
        for w in ["uno", "dos", "tres", "cuatro"] { _ = deck.add(front: w, back: w) }
        let ids = deck.cards.map(\.id)
        deck.record(ids[0], grade: .good, at: t0)               // due t0 + 1d
        deck.record(ids[1], grade: .good, at: t0 - 3 * day)     // due t0 - 2d (more overdue)
        let queue = deck.studyQueue(now: t0 + day, newLimit: 1)
        XCTAssertEqual(queue.map(\.front), ["dos", "uno", "tres"])
        XCTAssertEqual(deck.studyQueue(now: t0, newLimit: 0).map(\.front), ["dos"])
    }

    func testMasteredFraction() {
        var deck = Deck(name: "d")
        XCTAssertEqual(deck.masteredFraction, 0)
        _ = deck.add(front: "a", back: "a")
        _ = deck.add(front: "b", back: "b")
        let id = deck.cards[0].id
        for _ in 0..<4 { deck.record(id, grade: .easy, at: t0) }
        XCTAssertEqual(deck.masteredFraction, 0.5, accuracy: 1e-9)
    }
}
