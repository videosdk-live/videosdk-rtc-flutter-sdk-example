import Foundation
import ReplayKit

private enum Constants {
    static let bufferMaxLength = 10240
}

class SampleUploader {
    
    enum UploaderType {
        case video
        case audio
    }
    
    private var imageContext: CIContext?
    private var contextCreationTime: Date?
    private let contextLifetime: TimeInterval = 120.0
    private let audioCodec = AudioCodec()
    @Atomic private var isReady = false
    private var connection: SocketConnection
    private let uploaderType: UploaderType
  
    private var dataToSend: Data?
    private var byteIndex = 0
  
    private let serialQueue: DispatchQueue
    
    init(connection: SocketConnection, type: UploaderType) {
        self.connection = connection
        self.uploaderType = type
        self.serialQueue = DispatchQueue(label: "org.videosdk.broadcast.sampleUploader.\(type)")
        
        if type == .video {
            self.createImageContext()
        }
      
        setupConnection()
    }
  
    @discardableResult func send(sample buffer: CMSampleBuffer) -> Bool {
        guard uploaderType == .video && isReady else {
            return false
        }
        
        isReady = false
        dataToSend = prepare(sample: buffer)
        byteIndex = 0

        serialQueue.async { [weak self] in
            self?.sendDataChunk()
        }
        
        return true
    }

    @discardableResult func send(audioSample buffer: CMSampleBuffer) -> Bool {
        guard uploaderType == .audio && isReady else {
            return false
        }
        
        isReady = false
        dataToSend = prepare(audioSample: buffer)
        byteIndex = 0
        
        serialQueue.async { [weak self] in
            self?.sendDataChunk()
        }
        
        return true
    }
}

private extension SampleUploader {
    
    func setupConnection() {
        connection.didOpen = { [weak self] in
            self?.isReady = true
        }
        connection.streamHasSpaceAvailable = { [weak self] in
            self?.serialQueue.async {
                if let success = self?.sendDataChunk() {
                    self?.isReady = !success
                }
            }
        }
    }
    
    @discardableResult func sendDataChunk() -> Bool {
        guard let dataToSend = dataToSend else {
            return false
        }
      
        var bytesLeft = dataToSend.count - byteIndex
        var length = bytesLeft > Constants.bufferMaxLength ? Constants.bufferMaxLength : bytesLeft

        length = dataToSend[byteIndex..<(byteIndex + length)].withUnsafeBytes {
            guard let ptr = $0.bindMemory(to: UInt8.self).baseAddress else {
                return 0
            }

            return connection.writeToStream(buffer: ptr, maxLength: length)
        }

        if length > 0 {
            byteIndex += length
            bytesLeft -= length

            if bytesLeft == 0 {
                self.dataToSend = nil
                byteIndex = 0
            }
        } else {
            print("writeBufferToStream failure")
        }
      
        return true
    }
    
    func prepare(sample buffer: CMSampleBuffer) -> Data? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            print("image buffer not available")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        
        let scaleFactor = 2.0
        let width = CVPixelBufferGetWidth(imageBuffer)/Int(scaleFactor)
        let height = CVPixelBufferGetHeight(imageBuffer)/Int(scaleFactor)
        let orientation = CMGetAttachment(buffer, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil)?.uintValue ?? 0
                                    
        let scaleTransform = CGAffineTransform(scaleX: CGFloat(1.0/scaleFactor), y: CGFloat(1.0/scaleFactor))
        let bufferData = self.jpegData(from: imageBuffer, scale: scaleTransform)
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        
        guard let messageData = bufferData else {
            print("corrupted image buffer")
            return nil
        }
              
        let httpResponse = CFHTTPMessageCreateResponse(nil, 200, nil, kCFHTTPVersion1_1).takeRetainedValue()
        CFHTTPMessageSetHeaderFieldValue(httpResponse, "Content-Length" as CFString, String(messageData.count) as CFString)
        CFHTTPMessageSetHeaderFieldValue(httpResponse, "Buffer-Width" as CFString, String(width) as CFString)
        CFHTTPMessageSetHeaderFieldValue(httpResponse, "Buffer-Height" as CFString, String(height) as CFString)
        CFHTTPMessageSetHeaderFieldValue(httpResponse, "Buffer-Orientation" as CFString, String(orientation) as CFString)
        
        CFHTTPMessageSetBody(httpResponse, messageData as CFData)
        
        let serializedMessage = CFHTTPMessageCopySerializedMessage(httpResponse)?.takeRetainedValue() as Data?
      
        return serializedMessage
    }
    
    func jpegData(from buffer: CVPixelBuffer, scale scaleTransform: CGAffineTransform) -> Data? {
        guard let context = getImageContext() else { return nil }
        
        let image = CIImage(cvPixelBuffer: buffer).transformed(by: scaleTransform)
        
        guard let colorSpace = image.colorSpace else {
            return nil
        }
      
        let options: [CIImageRepresentationOption: Float] = [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.8]

        return context.jpegRepresentation(of: image, colorSpace: colorSpace, options: options)
    }

    func prepare(audioSample buffer: CMSampleBuffer) -> Data? {
        do {
            let (metadata, audioData) = try audioCodec.encode(buffer)
            
            let metadataJSON = try JSONEncoder().encode(metadata)
            guard let metadataString = String(data: metadataJSON, encoding: .utf8) else {
                print("Failed to create metadata string from JSON data")
                return nil
            }
            
            let httpResponse = CFHTTPMessageCreateResponse(nil, 200, nil, kCFHTTPVersion1_1).takeRetainedValue()
            CFHTTPMessageSetHeaderFieldValue(httpResponse, "Content-Type" as CFString, "audio/pcm" as CFString)
            CFHTTPMessageSetHeaderFieldValue(httpResponse, "Content-Length" as CFString, String(audioData.count) as CFString)
            CFHTTPMessageSetHeaderFieldValue(httpResponse, "Buffer-Metadata" as CFString, metadataString as CFString)
            
            CFHTTPMessageSetBody(httpResponse, audioData as CFData)
            
            let serializedMessage = CFHTTPMessageCopySerializedMessage(httpResponse)?.takeRetainedValue()
            
            return serializedMessage as Data?
        } catch {
            print("Failed to encode audio buffer: \(error)")
            return nil
        }
    }
    
    private func createImageContext() {
        let options: [CIContextOption: Any] = [
            .cacheIntermediates: false,
            .useSoftwareRenderer: false
        ]
        self.imageContext = CIContext(options: options)
        self.contextCreationTime = Date()
    }
    
    private func getImageContext() -> CIContext? {
        if let creationTime = contextCreationTime,
           Date().timeIntervalSince(creationTime) > contextLifetime {
            self.imageContext = nil
            self.contextCreationTime = nil
            createImageContext()
        }
        return imageContext
    }
}
