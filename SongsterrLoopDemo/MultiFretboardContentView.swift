//
//  MultiFretboardContentView.swift
//  SongsterrLoopDemo
//
//  Created by Niki Khomitsevych on 9/7/25.
//

import SwiftUI

struct MultiFretboardContentView: View {
    @ObservedObject var tabData: TabData
    @Binding var activeFretboardId: Int?
    @Binding var capoPosition: CGFloat
    
    @State private var animationTimer: Timer?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 20) {
                headerInfo
                
                ForEach(Array(allMeasures.enumerated()), id: \.offset) { index, measure in
                    VStack(alignment: .leading, spacing: 8) {
                        measureHeader(for: index, measure: measure)
                        
                        FretboardView(
                            measure: measure,
                            fretboardId: index,
                            isActive: activeFretboardId == index,
                            capoPosition: activeFretboardId == index ? capoPosition : 20,
                            isPlaying: tabData.isPlaying,
                            onTap: handleFretboardTap
                        )
                        .border(
                            measure.isLoopSelected ? Color(hex: "#4CAF50") : Color.gray.opacity(0.3),
                            width: measure.isLoopSelected ? 2 : 1
                        )
                    }
                }
            }
            .padding()
        }
        .onReceive(tabData.$isPlaying) { isPlaying in
            if isPlaying {
                startCapoAnimation()
            } else {
                stopCapoAnimation()
            }
        }
        .onDisappear {
            stopCapoAnimation()
        }
    }
    
    private var headerInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("♩ = 71")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("let ring - - - - - - - - - - - - - - - - - - - - - - |")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var allMeasures: [TabMeasure] {
        tabData.sections.flatMap { $0.measures }
    }
    
    private func measureHeader(for index: Int, measure: TabMeasure) -> some View {
        HStack {
            if let sectionName = getSectionName(for: index) {
                Text(sectionName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Text("Measure \(index + 1)")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
            
            if measure.isLoopSelected {
                Text("LOOP SELECTED")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#4CAF50"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#4CAF50").opacity(0.1))
                    )
            }
        }
    }
    
    private func getSectionName(for measureIndex: Int) -> String? {
        var currentIndex = 0
        for section in tabData.sections {
            if currentIndex == measureIndex {
                return section.name
            }
            currentIndex += section.measures.count
        }
        return nil
    }
    
    private func handleFretboardTap(fretboardId: Int, position: CGFloat) {
        let previousActiveFretboardId = activeFretboardId
        activeFretboardId = fretboardId
        capoPosition = position
        
        // Transfer loop selection from previous measure to new measure
        transferLoopSelection(from: previousActiveFretboardId, to: fretboardId)
        
        // If playing, restart animation from the new position
        if tabData.isPlaying {
            startCapoAnimation()
        }
    }
    
    private func transferLoopSelection(from previousMeasureId: Int?, to newMeasureId: Int) {
        // Check if previous measure was loop-selected
        var wasLoopSelected = false
        if let previousId = previousMeasureId,
           let previousMeasure = getMeasure(at: previousId) {
            wasLoopSelected = previousMeasure.isLoopSelected
        }
        
        // If there was a loop selection, transfer it to the new measure
        if wasLoopSelected {
            // Clear all loop selections first
            tabData.clearAllLoopSelections()
            
            // Set loop selection for the new measure
            var flatMeasureIndex = 0
            for sectionIndex in 0..<tabData.sections.count {
                for measureIndexInSection in 0..<tabData.sections[sectionIndex].measures.count {
                    if flatMeasureIndex == newMeasureId {
                        tabData.sections[sectionIndex].measures[measureIndexInSection].isLoopSelected = true
                        return
                    }
                    flatMeasureIndex += 1
                }
            }
        }
    }
    
    private func startCapoAnimation() {
        stopCapoAnimation()
        
        guard activeFretboardId != nil else { return }
        
        let fretboardWidth: CGFloat = 600
        let startPosition = capoPosition
        let endPosition = fretboardWidth - 20
        let duration: TimeInterval = 3.0
        let fps: Double = 60
        let totalFrames = Int(duration * fps)
        var currentFrame = 0
        
        // Calculate starting frame based on current position
        let progress = (startPosition - 20) / (endPosition - 20)
        currentFrame = Int(progress * Double(totalFrames))
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/fps, repeats: true) { _ in
            guard activeFretboardId != nil else {
                stopCapoAnimation()
                return
            }
            
            let progress = Double(currentFrame) / Double(totalFrames)
            let currentPosition = 20 + (endPosition - 20) * progress
            
            // Update capoPosition directly during animation
            capoPosition = currentPosition
            
            currentFrame += 1
            
            // When reaching the end, move to next measure
            if currentFrame >= totalFrames {
                moveToNextMeasure()
                currentFrame = 0
                
                // Restart animation parameters for the new measure
                let newStartPosition = capoPosition
                let newProgress = (newStartPosition - 20) / (endPosition - 20)
                currentFrame = Int(newProgress * Double(totalFrames))
            }
        }
    }
    
    private func moveToNextMeasure() {
        guard let activeId = activeFretboardId else { return }
        
        let activeMeasure = getMeasure(at: activeId)
        
        // Check if current measure is loop-selected
        if let measure = activeMeasure, measure.isLoopSelected {
            // LOOP MODE: Stay in the same measure and restart from beginning
            capoPosition = 20
        } else {
            // SEQUENTIAL MODE: Move to next measure one-by-one
            let nextMeasureId = activeId + 1
            if nextMeasureId < allMeasures.count {
                // Move to next measure
                activeFretboardId = nextMeasureId
                capoPosition = 20
            } else {
                // End of all measures - loop back to first measure
                activeFretboardId = 0
                capoPosition = 20
            }
        }
    }
    
    private func findFirstSelectedMeasure() -> Int? {
        for (index, measure) in allMeasures.enumerated() {
            if measure.isLoopSelected {
                return index
            }
        }
        return nil
    }
    
    private func getMeasure(at index: Int) -> TabMeasure? {
        guard index < allMeasures.count else { return nil }
        return allMeasures[index]
    }
    
    private func stopCapoAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

#Preview("Default MultiFretboardContentView() Preview") {
    @Previewable @State var activeFretboardId: Int? = 0
    @Previewable @State var capoPosition: CGFloat = 0
    
    VStack {
        MultiFretboardContentView(
            tabData: TabData(),
            activeFretboardId: $activeFretboardId,
            capoPosition: $capoPosition
        )
    }
}
