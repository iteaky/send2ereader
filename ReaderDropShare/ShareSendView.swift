import SwiftUI

struct ShareSendView: View {
    @ObservedObject var model: ShareSendViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Reader code") {
                    TextField("ABCD", text: Binding(
                        get: { model.key },
                        set: { model.updateKey($0) }
                    ))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                }

                Section("File") {
                    if let file = model.file {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(file.name).font(.headline)
                            Text(file.formattedSize).foregroundStyle(.secondary)
                        }
                    } else if model.state == .loading {
                        ProgressView("Loading…")
                    }
                }

                Section("Options") {
                    Toggle("Optimize EPUB", isOn: $model.options.optimizeEPUB)
                    Toggle("Crop PDF margins", isOn: $model.options.cropPDFMargins)
                }

                statusSection

                Section {
                    Button("Continue") { model.triggerSubmit() }
                        .disabled(!model.canSend)
                    if model.state == .success {
                        Button("Done") { model.finish() }
                    }
                }
            }
            .navigationTitle("ReaderDrop")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { model.cancel() }
                }
            }
        }
    }

    @ViewBuilder
    private var statusSection: some View {
        switch model.state {
        case .uploading(let value): Section { ProgressView(value: value) }
        case .processing: Section { ProgressView("Processing…") }
        case .success: Section { Label("Completed", systemImage: "checkmark.circle.fill").foregroundStyle(.green) }
        case .failure(let message): Section { Text(message).foregroundStyle(.red) }
        case .loading, .ready: EmptyView()
        }
    }
}
