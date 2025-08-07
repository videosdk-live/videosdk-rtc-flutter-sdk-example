import ReplayKit
import OSLog

let broadcastLogger = OSLog(subsystem: "live.videosdk.flutter.example", category: "Broadcast")
private enum Constants {
    // the App Group ID value that the app and the broadcast extension targets are setup with. It differs for each app.
    static let appGroupIdentifier = "group.com.example.broadcastScreen"
    static let videoSocketSuffix = "rtc_SSFD_video"
    static let audioSocketSuffix = "rtc_SSFD_audio"
}

class SampleHandler: RPBroadcastSampleHandler {
    
    private var videoConnection: SocketConnection?
    private var audioConnection: SocketConnection?
    private var videoUploader: SampleUploader?
    private var audioUploader: SampleUploader?
    
    private var frameCount: Int = 0
    private var audioFrameCount: Int = 0
    
    var videoSocketFilePath: String {
        let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)
        return sharedContainer?.appendingPathComponent(Constants.videoSocketSuffix).path ?? ""
    }
    
    var audioSocketFilePath: String {
        let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)
        return sharedContainer?.appendingPathComponent(Constants.audioSocketSuffix).path ?? ""
    }
    
    override init() {
        super.init()
        if let videoConn = SocketConnection(filePath: videoSocketFilePath) {
            videoConnection = videoConn
            setupConnection(videoConn, type: .video)
            videoUploader = SampleUploader(connection: videoConn, type: .video)
        }
        
        if let audioConn = SocketConnection(filePath: audioSocketFilePath) {
            audioConnection = audioConn
            setupConnection(audioConn, type: .audio)
            audioUploader = SampleUploader(connection: audioConn, type: .audio)
        }
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        frameCount = 0
        
        DarwinNotificationCenter.shared.postNotification(.broadcastStarted)
        openConnections()
        let notificationName = CFNotificationName("videosdk.flutter.startScreenShare" as CFString)
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(notificationCenter, notificationName, nil, nil, true)
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        DarwinNotificationCenter.shared.postNotification(.broadcastStopped)
        videoConnection?.close()
        audioConnection?.close()
        let notificationName = CFNotificationName("videosdk.flutter.stopScreenShare" as CFString)
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(notificationCenter, notificationName, nil, nil, true)
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // very simple mechanism for adjusting frame rate by using every third frame
           frameCount += 1
           if frameCount % 2 == 0 {
               videoUploader?.send(sample: sampleBuffer)
             frameCount = 0
           }
        case RPSampleBufferType.audioApp:
            audioUploader?.send(audioSample: sampleBuffer)
        default:
            break
        }
    }
}

private extension SampleHandler {
    enum ConnectionType {
        case video
        case audio
    }
    
    func setupConnection(_ connection: SocketConnection, type: ConnectionType) {
        connection.didClose = { [weak self] error in
            print("\(type) connection did close \(String(describing: error))")
            if let error = error {
                self?.finishBroadcastWithError(error)
            } else {
                // the displayed failure message is more user friendly when using NSError instead of Error
                let JMScreenSharingStopped = 10001
                let customError = NSError(domain: RPRecordingErrorDomain, code: JMScreenSharingStopped, userInfo: [NSLocalizedDescriptionKey: "Screen sharing stopped"])
                self?.finishBroadcastWithError(customError)
            }
        }
    }
    
    func openConnections() {
        openConnection(videoConnection, type: .video)
        openConnection(audioConnection, type: .audio)
    }
    
    func openConnection(_ connection: SocketConnection?, type: ConnectionType) {
        let queue = DispatchQueue(label: "broadcast.connectTimer.\(type)")
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: .milliseconds(100), leeway: .milliseconds(500))
        timer.setEventHandler { [weak connection] in
            guard connection?.open() == true else {
                return
            }
            timer.cancel()
        }
        timer.resume()
    }
}
