import AVFoundation
@testable import HaishinKit

enum CMAudioSampleBufferFactory {
    static func makeSilence(_ sampleRate: Double = 44100, numSamples: Int = 1024, channels: UInt32 = 1, presentaionTimeStamp: CMTime = .zero) -> CMSampleBuffer? {
        var asbd = AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: 0xc,
            mBytesPerPacket: 2 * channels,
            mFramesPerPacket: 1,
            mBytesPerFrame: 2 * channels,
            mChannelsPerFrame: channels,
            mBitsPerChannel: 16,
            mReserved: 0
        )
        var formatDescription: CMAudioFormatDescription?
        var status: OSStatus = noErr
        var blockBuffer: CMBlockBuffer?
        let blockSize = numSamples * Int(asbd.mBytesPerPacket)
        status = CMBlockBufferCreateWithMemoryBlock(
            allocator: nil,
            memoryBlock: nil,
            blockLength: blockSize,
            blockAllocator: nil,
            customBlockSource: nil,
            offsetToData: 0,
            dataLength: blockSize,
            flags: 0,
            blockBufferOut: &blockBuffer
        )
        status = CMAudioFormatDescriptionCreate(
            allocator: kCFAllocatorDefault,
            asbd: &asbd,
            layoutSize: 0,
            layout: nil,
            magicCookieSize: 0,
            magicCookie: nil,
            extensions: nil,
            formatDescriptionOut: &formatDescription
        )
        guard let blockBuffer, status == noErr else {
            return nil
        }
        status = CMBlockBufferFillDataBytes(
            with: 0,
            blockBuffer: blockBuffer,
            offsetIntoDestination: 0,
            dataLength: blockSize
        )
        guard status == noErr else {
            return nil
        }
        var sampleBuffer: CMSampleBuffer?
        status = CMAudioSampleBufferCreateWithPacketDescriptions(
            allocator: nil,
            dataBuffer: blockBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: formatDescription!,
            sampleCount: numSamples,
            presentationTimeStamp: presentaionTimeStamp,
            packetDescriptions: nil,
            sampleBufferOut: &sampleBuffer
        )
        guard let sampleBuffer, status == noErr else {
            return nil
        }
        return sampleBuffer
    }

    static func makeSinWave(_ sampleRate: Double = 44100, numSamples: Int = 1024, channels: UInt32 = 1) -> CMSampleBuffer? {
        var status: OSStatus = noErr
        var sampleBuffer: CMSampleBuffer?
        var timing = CMSampleTimingInfo(
            duration: CMTime(value: 1, timescale: Int32(sampleRate)),
            presentationTimeStamp: CMTime.zero,
            decodeTimeStamp: CMTime.invalid
        )

        var streamDescription = AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: 0xc,
            mBytesPerPacket: 2 * channels,
            mFramesPerPacket: 1,
            mBytesPerFrame: 2 * channels,
            mChannelsPerFrame: channels,
            mBitsPerChannel: 16,
            mReserved: 0
        )

        guard let format = AVAudioFormat(streamDescription: &streamDescription, channelLayout: AVAudioUtil.makeChannelLayout(channels)) else {
            return nil
        }

        status = CMSampleBufferCreate(
            allocator: kCFAllocatorDefault,
            dataBuffer: nil,
            dataReady: false,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: format.formatDescription,
            sampleCount: numSamples,
            sampleTimingEntryCount: 1,
            sampleTimingArray: &timing,
            sampleSizeEntryCount: 0,
            sampleSizeArray: nil,
            sampleBufferOut: &sampleBuffer
        )

        guard status == noErr else {
            return nil
        }

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(numSamples))!
        buffer.frameLength = buffer.frameCapacity

        let channels = Int(format.channelCount)
        let samples = buffer.int16ChannelData![0]
        for n in 0..<Int(buffer.frameLength) {
            switch channels {
            case 1:
                samples[n] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n) / Float(sampleRate)) * 16383.0)
            case 2:
                samples[n * 2 + 0] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 0) / Float(sampleRate)) * 16383.0)
                samples[n * 2 + 1] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 1) / Float(sampleRate)) * 16383.0)
            case 3:
                samples[n * 3 + 0] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 0) / Float(sampleRate)) * 16383.0)
                samples[n * 3 + 1] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 1) / Float(sampleRate)) * 16383.0)
                samples[n * 3 + 2] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 2) / Float(sampleRate)) * 16383.0)
            case 4:
                samples[n * 4 + 0] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 0) / Float(sampleRate)) * 16383.0)
                samples[n * 4 + 1] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 1) / Float(sampleRate)) * 16383.0)
                samples[n * 4 + 2] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 2) / Float(sampleRate)) * 16383.0)
                samples[n * 4 + 3] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 3) / Float(sampleRate)) * 16383.0)
            case 5:
                samples[n * 5 + 0] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 0) / Float(sampleRate)) * 16383.0)
                samples[n * 5 + 1] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 1) / Float(sampleRate)) * 16383.0)
                samples[n * 5 + 2] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 2) / Float(sampleRate)) * 16383.0)
                samples[n * 5 + 3] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 3) / Float(sampleRate)) * 16383.0)
                samples[n * 5 + 4] = Int16(sinf(Float(2.0 * .pi) * 440.0 * Float(n + 4) / Float(sampleRate)) * 16383.0)
            default:
                break
            }
        }

        status = CMSampleBufferSetDataBufferFromAudioBufferList(
            sampleBuffer!,
            blockBufferAllocator: kCFAllocatorDefault,
            blockBufferMemoryAllocator: kCFAllocatorDefault,
            flags: 0,
            bufferList: buffer.audioBufferList
        )

        guard status == noErr else {
            return nil
        }

        return sampleBuffer
    }
}
