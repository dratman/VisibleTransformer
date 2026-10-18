// The model's character vocabulary and its embedding table.
//
// An embedding vector is the list of numbers the model uses to stand for one
// character. The table has one such vector for every character in the
// vocabulary. Here the numbers are random (the model is untrained), but a
// fixed seed makes them identical on every run.

/// A small, fast random number generator with a fixed seed (SplitMix64),
/// so the "random" embeddings are repeatable.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

public struct EmbeddingTable {
    public let vocabulary: [Character]
    public let dimension: Int
    private let vectors: [[Float]]          // one vector per vocabulary entry
    private let indexOfCharacter: [Character: Int]

    /// Vocabulary: space, a-z, and a few punctuation marks.
    public static let defaultVocabulary: [Character] =
        Array(" abcdefghijklmnopqrstuvwxyz.,'!?")

    public init(vocabulary: [Character] = EmbeddingTable.defaultVocabulary,
                dimension: Int = 16,
                seed: UInt64 = 1) {
        self.vocabulary = vocabulary
        self.dimension = dimension
        var generator = SeededGenerator(seed: seed)
        // Each number is drawn uniformly from -1...1.
        vectors = vocabulary.map { _ in
            (0..<dimension).map { _ in Float.random(in: -1...1, using: &generator) }
        }
        var lookup: [Character: Int] = [:]
        for (i, c) in vocabulary.enumerated() { lookup[c] = i }
        indexOfCharacter = lookup
    }

    /// The embedding vector for a character. Characters not in the
    /// vocabulary are treated as a space.
    public func vector(for character: Character) -> [Float] {
        let lowered = Character(character.lowercased())
        return vectors[indexOfCharacter[lowered] ?? 0]
    }
}
