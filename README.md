# ReaderDrop

ReaderDrop is a native SwiftUI application for sending ebooks from an iPhone or iPad to an eReader through [send2ereader](https://send2ereader.net/).

## Features

- Native SwiftUI interface for iPhone and iPad
- Direct upload to `https://send2ereader.net`
- Four-character reader code validation
- EPUB, MOBI, PDF, TXT, HTML, CBZ and CBR support
- EPUB optimization through the server
- PDF margin cropping
- Filename transliteration
- Local transfer history
- iOS Share Extension for sending a book from Files and other apps
- English and Russian localization
- Light and dark appearance support

## Requirements

- Xcode 16 or newer
- iOS 17 or newer
- An Apple development team for installation on a physical device

## Build

1. Clone this repository.
2. Open `ReaderDrop.xcodeproj` in Xcode.
3. Select your development team for both targets:
   - `ReaderDrop`
   - `ReaderDropShare`
4. Choose an iPhone simulator or connected device.
5. Build and run.

## Usage

1. Open `https://send2ereader.net` in the browser on your eReader.
2. Copy the four-character code displayed on the eReader.
3. Enter the code in ReaderDrop.
4. Select a supported ebook file.
5. Choose the required processing options and submit it.
6. Download the file from the link that appears on the eReader.

The code is temporary and must remain active on the eReader while the file is being transferred.

## Privacy

ReaderDrop does not require an account. A selected file is uploaded to `send2ereader.net` for temporary processing and delivery. Review the server's own privacy and hosting terms before transferring sensitive material.

## Server attribution

ReaderDrop is an independent iOS client compatible with the open-source [send2ereader server](https://github.com/daniel-j/send2ereader) created by djazz. ReaderDrop is not an official application of the server author.

## License

ReaderDrop is available under the MIT License. See [LICENSE](LICENSE).
