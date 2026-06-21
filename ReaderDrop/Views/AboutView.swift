import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 14) {
                    Image("AppIconPreview")
                        .resizable()
                        .frame(width: 92, height: 92)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    Text("ReaderDrop").font(.title2.bold())
                    HStack(spacing: 4) {
                        Text("about.version")
                        Text(appVersion)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            }

            Section("about.how.title") {
                Label("about.how.1", systemImage: "1.circle.fill")
                Label("about.how.2", systemImage: "2.circle.fill")
                Label("about.how.3", systemImage: "3.circle.fill")
            }

            Section("about.privacy.title") {
                Text("about.privacy.message")
                Text("about.attribution").foregroundStyle(.secondary)
            }
        }
        .navigationTitle("settings.about.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}
