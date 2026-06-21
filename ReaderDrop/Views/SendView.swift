import SwiftUI
import UniformTypeIdentifiers

struct SendView: View {
    @EnvironmentObject private var settings: AppSettingsStore
    @EnvironmentObject private var history: HistoryStore
    @StateObject private var model = SendViewModel()
    @State private var isPickingFile = false

    var body: some View {
        NavigationStack {
            Form {
                Section("send.key.title") {
                    TextField("send.key.placeholder", text: Binding(
                        get: { model.key },
                        set: { model.updateKey($0) }
                    ))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                }

                Section("send.file.title") {
                    if let file = model.selectedFile {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(file.name).font(.headline)
                            Text(file.formattedSize).foregroundStyle(.secondary)
                        }
                        Button("send.file.remove", role: .destructive) {
                            model.clearContent()
                        }
                    } else {
                        Button("send.file.choose") { isPickingFile = true }
                    }
                }

                Section("send.options.title") {
                    Toggle("settings.optimize", isOn: $model.options.optimizeEPUB)
                    Toggle("settings.crop", isOn: $model.options.cropPDFMargins)
                    Toggle("settings.transliterate", isOn: $model.options.transliterateFilename)
                }

                statusSection

                Section {
                    Button("send.button") {
                        Task { await submitSelectedFile() }
                    }
                    .disabled(!model.canSend)
                }
            }
            .navigationTitle("send.title")
            .fileImporter(
                isPresented: $isPickingFile,
                allowedContentTypes: [.data],
                allowsMultipleSelection: false
            ) { result in
                if case let .success(urls) = result, let url = urls.first {
                    model.selectFile(from: url)
                }
            }
            .onAppear { model.loadDefaults(from: settings) }
        }
    }

    private func submitSelectedFile() async {
        guard let file = model.selectedFile else { return }
        await model.submit()
        guard case .success = model.state else { return }

        history.add(HistoryItem(
            kind: .file,
            displayName: file.name,
            detail: file.formattedSize,
            storedFilePath: nil,
            serverURL: "https://send2ereader.net"
        ))
    }

    @ViewBuilder
    private var statusSection: some View {
        switch model.state {
        case .uploading(let value):
            Section("send.progress") { ProgressView(value: value) }
        case .preparing, .processing:
            Section { ProgressView("send.processing") }
        case .success(let message):
            let text = message.isEmpty ? String(localized: "send.success") : message
            Section {
                Label {
                    Text(text)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .foregroundStyle(.green)
            }
        case .failure(let message):
            Section {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }
        case .idle:
            EmptyView()
        }
    }
}
