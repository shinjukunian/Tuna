public struct Note: CustomStringConvertible, Equatable, Hashable {
    
    /// The letter of a music note in English Notation
    public enum Letter: String, CaseIterable, CustomStringConvertible {
        case C      = "C"
        case CSharp = "C#"
        case D      = "D"
        case DSharp = "D#"
        case E      = "E"
        case F      = "F"
        case FSharp = "F#"
        case G      = "G"
        case GSharp = "G#"
        case A      = "A"
        case ASharp = "A#"
        case B      = "B"

        public var description: String { rawValue }
        
        public var isBlack:Bool{
            switch self {
            case .ASharp ,.CSharp, .DSharp, .FSharp, .GSharp:
                return true
            default:
                return false
            }
        }
        
    }

    /// The index of the note
    public let index: Int

    /// The letter of the note in English Notation
    public let letter: Letter

    /// The octave of the note
    public let octave: Int

    /// The frequency of the note
    public let frequency: Double

    /// The corresponding wave of the note
    public let wave: AcousticWave

    /// A string description of the note including octave (eg A4)
    public var description: String {
        "\(self.letter)\(self.octave)"
    }

    // MARK: - Initialization

    /// Initialize a Note from an index
    /// - Parameter index: The index of the note
    /// - Throws: An error if the rest of the components cannot be calculated
    public init(index: Int) throws {
        self.index     = index
        letter         = try NoteCalculator.letter(forIndex: index)
        octave         = try NoteCalculator.octave(forIndex: index)
        frequency      = try NoteCalculator.frequency(forIndex: index)
        wave           = try AcousticWave(frequency: frequency)
    }

    /// Initialize a Note from a frequency
    /// - Parameter frequency: The frequency of the note
    /// - Throws: An error if the rest of the components cannot be calculated
    public init(frequency: Double) throws {
        index          = try NoteCalculator.index(forFrequency: frequency)
        letter         = try NoteCalculator.letter(forIndex: index)
        octave         = try NoteCalculator.octave(forIndex: index)
        self.frequency = try NoteCalculator.frequency(forIndex: index)
        wave           = try AcousticWave(frequency: frequency)
    }

    /// Initialize a Note from a Letter & Octave
    /// - Parameters:
    ///   - letter: The letter of the note
    ///   - octave: The octave of the note
    /// - Throws: An error if the rest of the components cannot be calculated
    public init(letter: Letter, octave: Int) throws {
        self.letter    = letter
        self.octave    = octave
        index          = try NoteCalculator.index(forLetter: letter, octave: octave)
        frequency      = try NoteCalculator.frequency(forIndex: index)
        wave           = try AcousticWave(frequency: frequency)
    }

    // MARK: - Neighbor Notes

    /// One semitone lower
    /// - Throws: An error if the semitone is out of bounds
    /// - Returns: A note that is one semitone lower
    public func lower() throws -> Note {
        try Note(index: index - 1)
    }

    /// One semitone higher
    /// - Throws: An error if the semitone is out of bounds
    /// - Returns: A note that is one semitone higher
    public func higher() throws -> Note {
        try Note(index: index + 1)
    }
    
    public static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.index == rhs.index
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
    
    
    public static func notes(octave:Int = 4)->[Note]{
        return try! [
            Note(letter: Note.Letter.C, octave: octave),
            Note(letter: .CSharp, octave: octave),
            Note(letter: Note.Letter.D, octave: octave),
            Note(letter: .DSharp, octave: octave),
            Note(letter: Note.Letter.E, octave: octave),
            Note(letter: Note.Letter.F, octave: octave),
            Note(letter: .FSharp, octave: octave),
            Note(letter: Note.Letter.G, octave: octave),
            Note(letter: .GSharp, octave: octave),
            Note(letter: Note.Letter.A, octave: octave),
            Note(letter: .ASharp, octave: octave),
            Note(letter: Note.Letter.B, octave: octave),
            Note(letter: Note.Letter.C, octave: octave+1),
        ]
    }
}
