//
//  RTCSimulatorVideoDecoderFactory.swift
//  ALTWebRTC
//
//  Created by Alfredo Luco on 06-06-20.
//  Copyright © 2020 Alfredo Luco. All rights reserved.
//

import Foundation
import WebRTC

class RTCSimulatorVideoDecoderFactory: RTCDefaultVideoDecoderFactory {
    override func supportedCodecs() -> [RTCVideoCodecInfo] {
        var codecs = super.supportedCodecs()
        codecs = codecs.filter{$0.name != "H264"} // no se porque es esto
        return codecs
    }
}
