import Foundation

/// How well the learner recalled a card (SM-2 quality 0...5).
public enum Grade: Int, CaseIterable {
    case blackout = 0, wrong, hard, difficult, good, easy

    public var passed: Bool { rawValue >= 3 }
}

public struct Flashcard: Identifiable, Equatable {
    public let id: UUID
    public var front: String
    public var back: String
    public var easiness: Double = 2.5
    public var repetitions: Int = 0
    public var intervalDays: Int = 0
    /// nil = never studied (a "new" card).
    public var due: Date?
    public var lapses: Int = 0

    public init(id: UUID = UUID(), front: String, back: String) {
        self.id = id
        self.front = front
        self.back = back
    }

    public var isNew: Bool { due == nil }
    /// Cards with a 3-week+ interval are considered mastered.
    public var isMastered: Bool { intervalDays >= 21 }
}

public enum SM2 {
    public static let minimumEasiness = 1.3
    private static let day: TimeInterval = 86_400

    /// Applies one review using the SuperMemo-2 algorithm.
    public static func review(_ card: Flashcard, grade: Grade, at now: Date) -> Flashcard {
        var c = card
        let q = Double(grade.rawValue)
        if grade.passed {
            switch c.repetitions {
            case 0: c.intervalDays = 1
            case 1: c.intervalDays = 6
            default: c.intervalDays = Int((Double(c.intervalDays) * c.easiness).rounded())
            }
            c.repetitions += 1
        } else {
            if c.repetitions > 0 { c.lapses += 1 }
            c.repetitions = 0
            c.intervalDays = 1
        }
        c.easiness = max(minimumEasiness, c.easiness + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)))
        c.due = now.addingTimeInterval(Double(c.intervalDays) * day)
        return c
    }
}

public struct Deck {
    public var name: String
    public private(set) var cards: [Flashcard]

    public init(name: String, cards: [Flashcard] = []) {
        self.name = name
        self.cards = cards
    }

    public mutating func add(front: String, back: String) -> Bool {
        let f = front.trimmingCharacters(in: .whitespacesAndNewlines)
        let b = back.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !f.isEmpty, !b.isEmpty, !cards.contains(where: { $0.front.caseInsensitiveCompare(f) == .orderedSame }) else { return false }
        cards.append(Flashcard(front: f, back: b))
        return true
    }

    /// Today's queue: overdue reviews first (most overdue first), then up to `newLimit` new cards.
    public func studyQueue(now: Date, newLimit: Int = 10) -> [Flashcard] {
        let reviews = cards.filter { ($0.due ?? .distantFuture) <= now }.sorted { $0.due! < $1.due! }
        let fresh = cards.filter(\.isNew).prefix(max(0, newLimit))
        return reviews + fresh
    }

    public mutating func record(_ id: UUID, grade: Grade, at now: Date) {
        guard let i = cards.firstIndex(where: { $0.id == id }) else { return }
        cards[i] = SM2.review(cards[i], grade: grade, at: now)
    }

    public var masteredFraction: Double {
        cards.isEmpty ? 0 : Double(cards.filter(\.isMastered).count) / Double(cards.count)
    }
}
