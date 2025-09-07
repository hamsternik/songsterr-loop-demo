import SwiftUI

struct FretboardView: View {
    let measure: TabMeasure
    let fretboardId: Int
    let isActive: Bool
    let capoPosition: CGFloat
    let isPlaying: Bool
    let onTap: (Int, CGFloat) -> Void
    
    let fretboardWidth: CGFloat = 600
    let fretboardHeight: CGFloat = 240
    
    private let stringSpacing: CGFloat = 40
    private let stringNames = ["e", "B", "G", "D", "A", "E"]
    
    var body: some View {
        ZStack(alignment: .leading) {
            stringLines
            fretNumbers
            if isActive {
                capoLine
            }
        }
        .frame(width: fretboardWidth, height: fretboardHeight)
        .onTapGesture { location in
            let newPosition = max(20, min(fretboardWidth - 4, location.x))
            onTap(fretboardId, newPosition)
        }
    }
    
    private var stringLines: some View {
        VStack(spacing: 0) {
            ForEach(Array(stringNames.enumerated()), id: \.offset) { index, stringName in
                HStack {
                    Text(stringName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    
                    Rectangle()
                        .fill(Color.primary.opacity(0.3))
                        .frame(height: 1)
                }
                .frame(height: stringSpacing)
            }
        }
    }
    
    private var fretNumbers: some View {
        ForEach(measure.notes) { note in
            if let fretNumber = note.fretNumber {
                Text("\(fretNumber)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                    )
                    .position(
                        x: 20 + (fretboardWidth - 20) * note.position,
                        y: CGFloat(note.stringIndex) * stringSpacing + stringSpacing/2
                    )
            }
        }
    }
    
    private var capoLine: some View {
        Rectangle()
            .fill(Color(hex: "#4CAF50"))
            .frame(width: 4, height: fretboardHeight)
            .position(x: capoPosition, y: fretboardHeight/2)
    }
}

#Preview {
    let sampleMeasure = TabMeasure(notes: [
        FretNote(stringIndex: 5, fretNumber: 6, position: 0.1),
        FretNote(stringIndex: 4, fretNumber: 8, position: 0.25),
        FretNote(stringIndex: 3, fretNumber: 8, position: 0.4),
        FretNote(stringIndex: 5, fretNumber: 0, position: 0.6),
        FretNote(stringIndex: 2, fretNumber: 3, position: 0.8)
    ])
    
    FretboardView(
        measure: sampleMeasure,
        fretboardId: 0,
        isActive: true,
        capoPosition: 150,
        isPlaying: false,
        onTap: { _, _ in }
    )
    .padding()
}
