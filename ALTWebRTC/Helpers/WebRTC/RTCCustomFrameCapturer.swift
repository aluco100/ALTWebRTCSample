//
//  RTCCustomFrameCapturer.swift
//  ALTWebRTC
//
//  Created by Alfredo Luco on 06-06-20.
//  Copyright © 2020 Alfredo Luco. All rights reserved.
//

import Foundation
import WebRTC

class RTCCustomFrameCapturer: RTCVideoCapturer {
    
    //MARK: - Variables
    
    let kNanosecondsPerSecond: Float64 = 1000000000 // no se por que es esto
    var nanoseconds: Float64 = 0
    
    
    //MARK: - Capture with buffer
    
    public func capture(_ sampleBuffer: CMSampleBuffer){
        let _pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        if let pixelBuffer = _pixelBuffer {
            let rtcPixelBuffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer)
            let timeStampNs = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * kNanosecondsPerSecond
            let rtcVideoFrame = RTCVideoFrame(buffer: rtcPixelBuffer, rotation: RTCVideoRotation._90, timeStampNs: Int64(timeStampNs))
            self.delegate?.capturer(self, didCapture: rtcVideoFrame)
        }
    }
    
    //MARK: - Capture with pixel buffer
    
    public func capture(_ pixelBuffer: CVPixelBuffer){
        let rtcPixelBuffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer)
        let timeStampNs = nanoseconds * kNanosecondsPerSecond

        let rtcVideoFrame = RTCVideoFrame(buffer: rtcPixelBuffer, rotation: RTCVideoRotation._90, timeStampNs: Int64(timeStampNs))
        self.delegate?.capturer(self, didCapture: rtcVideoFrame)
        nanoseconds += 1
    }
    
}
