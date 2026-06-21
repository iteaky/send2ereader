import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettingsStore

    var body: some View {
        NavigationStack {
            Form {
                Section("settings.server.title") {
                    TextField("settings.server.placeholder", text: $settings.serverURLString)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }

                Section("settings.defaults.title") {
                    Toggle("settings.optimize", isOn: $settings.optimizeEPUB)
                    Toggle("settings.crop", isOn: $settings.cropPDFMargins)
                    Toggle("settings.transliterate", isOn: $settings.transliterateFilename)
                    Toggle("settings.keepFiles", isOn: $settings.keepSentFiles)
                }

                Section {
                    NavigationLink("settings.about.title") { AboutView() }
                    Button("settings.reset", role: .destructive) { settings.reset() }
                }
            }
            .navigationTitle("settings.title")
        }
    }
}
