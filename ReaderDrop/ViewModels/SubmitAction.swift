import Foundation

extension SendViewModel {
    func submit() async {
        guard let destination = URL(string: "https://send2ereader.net") else { return }
        let chosenFile = mode == .file ? selectedFile : nil
        let chosenLink = mode == .link ? validLink : nil
        state = .preparing

        do {
            let request = UploadRequest(
                serverURL: destination,
                key: key,
                file: chosenFile,
                link: chosenLink,
                options: options
            )
            let result = try await UploadService().upload(request) { value in
                Task { @MainActor in
                    self.state = value >= 0.995 ? .processing : .uploading(value)
                }
            }
            state = .success(result.message)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}
