import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 19
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @State private var contentStore = ContentStore.shared
    @State private var showingResetAlert = false
    @State private var showingPermissionAlert = false
    @State private var reminderTime = Date()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Daily Reminder") {
                    Toggle("Enable daily practice reminder", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { _, newValue in
                            if newValue {
                                enableReminder()
                            } else {
                                disableReminder()
                            }
                        }
                    
                    if reminderEnabled {
                        DatePicker(
                            "Reminder time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: reminderTime) { _, newValue in
                            updateReminderTime(newValue)
                        }
                    }
                }
                
                Section("Data") {
                    Button("Reset all progress", role: .destructive) {
                        showingResetAlert = true
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Content Version")
                        Spacer()
                        Text("\(contentStore.curriculum?.contentVersion ?? 0)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("At the Table")
                        Spacer()
                        Text("на маса")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            setupReminderTime()
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetProgress()
            }
        } message: {
            Text("This will delete all your learning progress. This action cannot be undone.")
        }
        .alert("Notification Permission Denied", isPresented: $showingPermissionAlert) {
            Button("Cancel", role: .cancel) { 
                reminderEnabled = false
            }
            Button("Open Settings") {
                openAppSettings()
            }
        } message: {
            Text("Please enable notifications in Settings to receive daily practice reminders.")
        }
    }
    
    private func setupReminderTime() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute
        reminderTime = calendar.date(from: components) ?? Date()
    }
    
    private func enableReminder() {
        Task {
            let authorized = await ReminderScheduler.requestAuthorization()
            
            await MainActor.run {
                if authorized {
                    scheduleReminder()
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private func disableReminder() {
        ReminderScheduler.cancel()
    }
    
    private func updateReminderTime(_ time: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        reminderHour = components.hour ?? 19
        reminderMinute = components.minute ?? 0
        
        if reminderEnabled {
            scheduleReminder()
        }
    }
    
    private func scheduleReminder() {
        ReminderScheduler.schedule(hour: reminderHour, minute: reminderMinute)
    }
    
    private func resetProgress() {
        do {
            try modelContext.delete(model: CardProgress.self)
        } catch {
            print("Failed to reset progress: \(error)")
        }
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: "app-settings:") {
            // This will be handled by the system
            print("Please enable notifications in Settings app")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: CardProgress.self, inMemory: true)
}