import Foundation

enum MessageHeader: Codable {
    case video(VideoMetadata)
    case audio(AudioCodec.Metadata)

    struct VideoMetadata: Codable {
        let width: Int
        let height: Int
        let orientation: UInt32
    }
}
