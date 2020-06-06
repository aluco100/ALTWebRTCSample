//
//  CameraSession.swift
//  ALTWebRTC
//
//  Created by Alfredo Luco on 06-06-20.
//  Copyright © 2020 Alfredo Luco. All rights reserved.
//

import Foundation
import AVFoundation

//MARK: - <Camera Session Delegate>

protocol CameraSessionDelegate: class {
    func didOutput(_ sampleBuffer: CMSampleBuffer)
}

//MARK: - <Camera Session Definition>

class CameraSession: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //Session
    
    private var session: AVCaptureSession?
    
    //Output
    private var output: AVCaptureVideoDataOutput?
    
    //Device
    private var device: AVCaptureDevice?
    
    //Delegate
    weak var delegate: CameraSessionDelegate?
    
    //Setup
    func setupSession() {
        
        //init session
        
        self.session = AVCaptureSession()
        session?.sessionPreset = .medium
        
        //selfie mode
        
        self.device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        
        // Add input
        guard let device = self.device, let input = try? AVCaptureDeviceInput(device: device) else {
            print("input av capture device input failed!")
            return
        }
        self.session?.addInput(input)
        
        // output
        
        self.output = AVCaptureVideoDataOutput()
        
        // logic into a thread
        let queue: DispatchQueue = DispatchQueue(label: "videodata", attributes: .concurrent)
        self.output?.setSampleBufferDelegate(self, queue: queue)
        self.output?.alwaysDiscardsLateVideoFrames = false
        self.output?.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] as [String : Any]
        self.session?.addOutput(self.output!)
        self.session?.sessionPreset = AVCaptureSession.Preset.inputPriority
        self.session?.usesApplicationAudioSession = false
        
        self.session?.startRunning()
        
    }
    
    //MARK: - <Output Delegate>
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.delegate?.didOutput(sampleBuffer)
    }
    
}
