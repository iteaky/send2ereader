import Foundation

extension ShareSendViewModel {
    func triggerSubmit() {
        Task { await send() }
    }

    func send() async {
        guard let file,
              let destination = URL(string: "https://send2ereader.net") else { return }

        state = .uploading(0)
        do {
            let request = UploadRequest(
                serverURL: destination,
                key: key,
                file: file,
                link: nil,
                options: options
            )
            _ = try await UploadService().upload(request) { value in
                Task { @MainActor in
                    self.state = value >= 0.995 ? .processing : .uploading(value)
                }
            }
            state = .success
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}
