import SwiftUI

struct MainView: View {
    @StateObject private var tabData = TabData()
    @State private var activeFretboardId: Int? = nil
    @State private var capoPosition: CGFloat = 20
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Tap on any fretboard to activate its capo line. Only one capo can be active at a time.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                MultiFretboardContentView(
                    tabData: tabData,
                    activeFretboardId: $activeFretboardId,
                    capoPosition: $capoPosition
                )
                
                controlButtons
            }
            .padding()
            .navigationTitle("Songsterr Loop Test")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            Button(action: handlePlayButtonTap) {
                HStack {
                    Image(systemName: tabData.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .medium))
                    Text(tabData.isPlaying ? "Pause" : "Play")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                )
            }
            .disabled(activeFretboardId == nil)
            .opacity(activeFretboardId == nil ? 0.5 : 1.0)
            
            Button(action: handleLoopButtonTap) {
                HStack {
                    Image(systemName: isLoopSelected ? "repeat.1" : "repeat")
                        .font(.system(size: 16, weight: .medium))
                    Text("Loop")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isLoopSelected ? Color(hex: "#4CAF50") : Color.gray)
                )
            }
            .disabled(activeFretboardId == nil)
            .opacity(activeFretboardId == nil ? 0.5 : 1.0)
        }
        .padding(.top, 16)
    }
    
    private var isLoopSelected: Bool {
        guard let selectedMeasureIndex = activeFretboardId else { return false }
        
        var flatMeasureIndex = 0
        for section in tabData.sections {
            for measure in section.measures {
                if flatMeasureIndex == selectedMeasureIndex {
                    return measure.isLoopSelected
                }
                flatMeasureIndex += 1
            }
        }
        return false
    }
    
    private func handlePlayButtonTap() {
        tabData.isPlaying.toggle()
    }
    
    private func handleLoopButtonTap() {
        guard let selectedMeasureIndex = activeFretboardId else { return }
        tabData.toggleLoopSelection(for: selectedMeasureIndex)
    }
}

#Preview {
    MainView()
}
