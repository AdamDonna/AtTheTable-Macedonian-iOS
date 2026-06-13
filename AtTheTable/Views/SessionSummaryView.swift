import SwiftUI

struct SessionSummaryView: View {
    let totalCards: Int
    let gotItCount: Int
    let notYetCount: Int
    let onDismiss: () -> Void
    
    private var accuracy: Double {
        guard totalCards > 0 else { return 0 }
        return Double(gotItCount) / Double(totalCards)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                
                Text("Session Complete!")
                    .font(.largeTitle.bold())
                
                Text("Great work on your practice session.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                StatRow(label: "Cards Reviewed", value: "\(totalCards)")
                StatRow(label: "Got It", value: "\(gotItCount)", color: .green)
                StatRow(label: "Not Yet", value: "\(notYetCount)", color: .orange)
                StatRow(label: "Accuracy", value: "\(Int(accuracy * 100))%", color: accuracy >= 0.8 ? .green : .orange)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
            )
            
            VStack(spacing: 8) {
                Text("Next Review")
                    .font(.headline)
                
                Text("Cards you got right will appear later based on spaced repetition.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Cards to review again will appear tomorrow.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button("Back to Home") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .navigationBarBackButtonHidden()
    }
}

struct StatRow: View {
    let label: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundColor(color)
        }
    }
}

#Preview {
    SessionSummaryView(
        totalCards: 8,
        gotItCount: 6,
        notYetCount: 2,
        onDismiss: {}
    )
}