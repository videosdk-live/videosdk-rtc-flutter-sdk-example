//
//  AudioCodec.swift
//  FlutterBroadcast
//
//  Created by Pavan Faldu on 05/08/25.
//

import AVFoundation
import CoreMedia

struct AudioCodec {
    struct Metadata: Codable {
        let sampleCount: Int32
        let description: AudioStreamBasicDescription
    }

    enum Error: Swift.Error {
        case encodingFailed
        case blockBufferNotReady
    }

    func encode(_ audioBuffer: CMSampleBuffer) throws -> (Metadata, Data) {
        guard let formatDescription = audioBuffer.formatDescription,
              let basicDescription = formatDescription.audioStreamBasicDescription else {
            throw Error.encodingFailed
        }

        var audioBufferList = AudioBufferList()
        var blockBuffer: CMBlockBuffer?

        try CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            audioBuffer,
            bufferListSizeNeededOut: nil,
            bufferListOut: &audioBufferList,
            bufferListSize: MemoryLayout<AudioBufferList>.stride,
            blockBufferAllocator: kCFAllocatorDefault,
            blockBufferMemoryAllocator: kCFAllocatorDefault,
            flags: 0,
            blockBufferOut: &blockBuffer
        )

        guard blockBuffer != nil else {
            throw Error.blockBufferNotReady
        }

        let audioData = NSMutableData()
        let buffers = UnsafeBufferPointer<AudioBuffer>(start: &audioBufferList.mBuffers, count: Int(audioBufferList.mNumberBuffers))

        for audioBuffer in buffers {
            if let data = audioBuffer.mData {
                audioData.append(data, length: Int(audioBuffer.mDataByteSize))
            }
        }

        let metadata = Metadata(
            sampleCount: Int32(audioBuffer.numSamples),
            description: basicDescription
        )
        return (metadata, audioData as Data)
    }
}

extension AudioStreamBasicDescription: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(mSampleRate)
        try container.encode(mFormatID)
        try container.encode(mFormatFlags)
        try container.encode(mBytesPerPacket)
        try container.encode(mFramesPerPacket)
        try container.encode(mBytesPerFrame)
        try container.encode(mChannelsPerFrame)
        try container.encode(mBitsPerChannel)
    }

    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(
            mSampleRate: container.decode(Float64.self),
            mFormatID: container.decode(AudioFormatID.self),
            mFormatFlags: container.decode(AudioFormatFlags.self),
            mBytesPerPacket: container.decode(UInt32.self),
            mFramesPerPacket: container.decode(UInt32.self),
            mBytesPerFrame: container.decode(UInt32.self),
            mChannelsPerFrame: container.decode(UInt32.self),
            mBitsPerChannel: container.decode(UInt32.self),
            mReserved: 0
        )
    }
}
