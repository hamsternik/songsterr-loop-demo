import Foundation

struct GuitarString: Identifiable {
    let id = UUID()
    let name: String
    let position: Int
    
    static let standard = [
        GuitarString(name: "e", position: 0),
        GuitarString(name: "B", position: 1),
        GuitarString(name: "G", position: 2),
        GuitarString(name: "D", position: 3),
        GuitarString(name: "A", position: 4),
        GuitarString(name: "E", position: 5)
    ]
}

struct FretNote: Identifiable {
    let id = UUID()
    let stringIndex: Int
    let fretNumber: Int?
    let position: Double
}

struct TabMeasure: Identifiable {
    let id = UUID()
    let notes: [FretNote]
    let tempo: Int
    var isLoopSelected: Bool
    
    init(notes: [FretNote], tempo: Int = 71, isLoopSelected: Bool = false) {
        self.notes = notes
        self.tempo = tempo
        self.isLoopSelected = isLoopSelected
    }
}

struct TabSection: Identifiable {
    let id = UUID()
    var measures: [TabMeasure]
    let name: String?
    
    init(measures: [TabMeasure], name: String? = nil) {
        self.measures = measures
        self.name = name
    }
}

class TabData: ObservableObject {
    @Published var sections: [TabSection] = []
    @Published var currentCapoPosition: Double = 0.0
    @Published var isPlaying: Bool = false
    @Published var selectedLoopRange: ClosedRange<Int>?
    
    init() {
        setupDemoData()
    }
    
    func toggleLoopSelection(for measureIndex: Int) {
        var flatMeasureIndex = 0
        for sectionIndex in 0..<sections.count {
            for measureIndexInSection in 0..<sections[sectionIndex].measures.count {
                if flatMeasureIndex == measureIndex {
                    let currentlySelected = sections[sectionIndex].measures[measureIndexInSection].isLoopSelected
                    
                    if currentlySelected {
                        // If currently selected, deselect it
                        sections[sectionIndex].measures[measureIndexInSection].isLoopSelected = false
                    } else {
                        // If not selected, clear all others and select this one
                        clearAllLoopSelections()
                        sections[sectionIndex].measures[measureIndexInSection].isLoopSelected = true
                    }
                    return
                }
                flatMeasureIndex += 1
            }
        }
    }
    
    func clearAllLoopSelections() {
        for sectionIndex in 0..<sections.count {
            for measureIndex in 0..<sections[sectionIndex].measures.count {
                sections[sectionIndex].measures[measureIndex].isLoopSelected = false
            }
        }
    }
    
    private func setupDemoData() {
        // Measure 1 (Intro)
        let measure1 = TabMeasure(notes: [
            FretNote(stringIndex: 0, fretNumber: 0, position: 0.25),
            FretNote(stringIndex: 1, fretNumber: 0, position: 0.5),
            FretNote(stringIndex: 2, fretNumber: 0, position: 0.75),
            FretNote(stringIndex: 3, fretNumber: 6, position: 0.0),
            FretNote(stringIndex: 4, fretNumber: 8, position: 0.0),
            FretNote(stringIndex: 5, fretNumber: 8, position: 0.0),
            FretNote(stringIndex: 5, fretNumber: 0, position: 1.0)
        ])
        
        // Measure 2 (with loop selection - green background)
        let measure2 = TabMeasure(notes: [
            FretNote(stringIndex: 3, fretNumber: 3, position: 0.25),
            FretNote(stringIndex: 2, fretNumber: 0, position: 0.5),
            FretNote(stringIndex: 1, fretNumber: 0, position: 0.75),
            FretNote(stringIndex: 0, fretNumber: 7, position: 1.0),
            FretNote(stringIndex: 5, fretNumber: 0, position: 0.0)
//        ], isLoopSelected: true)
        ])
        
        // Measure 3 (Em section)
        let measure3 = TabMeasure(notes: [
            FretNote(stringIndex: 0, fretNumber: 7, position: 0.0),
            FretNote(stringIndex: 1, fretNumber: 0, position: 0.25),
            FretNote(stringIndex: 2, fretNumber: 0, position: 0.5),
            FretNote(stringIndex: 3, fretNumber: 7, position: 0.75),
            FretNote(stringIndex: 4, fretNumber: 0, position: 1.0),
            FretNote(stringIndex: 5, fretNumber: 0, position: 0.0)
        ])
        
        // Measure 4
        let measure4 = TabMeasure(notes: [
            FretNote(stringIndex: 0, fretNumber: 0, position: 0.25),
            FretNote(stringIndex: 1, fretNumber: 0, position: 0.5),
            FretNote(stringIndex: 2, fretNumber: 0, position: 0.75),
            FretNote(stringIndex: 0, fretNumber: 7, position: 1.0),
            FretNote(stringIndex: 5, fretNumber: 0, position: 0.0)
        ])
        
        // Measure 5 (Em section)
        let measure5 = TabMeasure(notes: [
            FretNote(stringIndex: 0, fretNumber: 7, position: 0.0),
            FretNote(stringIndex: 1, fretNumber: 0, position: 0.25),
            FretNote(stringIndex: 2, fretNumber: 0, position: 0.5),
            FretNote(stringIndex: 3, fretNumber: 7, position: 0.75),
            FretNote(stringIndex: 4, fretNumber: 0, position: 1.0),
            FretNote(stringIndex: 5, fretNumber: 0, position: 0.0)
        ])
        
        let introSection = TabSection(measures: [measure1], name: "Intro")
        let emSection = TabSection(measures: [measure2, measure3, measure4, measure5], name: "Em")
        
        self.sections = [introSection, emSection]
    }
}
