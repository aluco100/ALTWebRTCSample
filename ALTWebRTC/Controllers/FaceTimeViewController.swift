//
//  FaceTimeViewController.swift
//  ALTWebRTC
//
//  Created by Alfredo Luco on 06-06-20.
//  Copyright © 2020 Alfredo Luco. All rights reserved.
//

import UIKit
import Starscream
import WebRTC

class FaceTimeViewController: UIViewController {
    
    //MARK: - Properties
    var webRTCClient: WebRTCClient!
    var socket: WebSocket!
    var tryToConnectWebSocket: Timer!
    var cameraSession: CameraSession?
    var config: WebRTCConfig!
    var isConnected: Bool = false
    
    // Constants
    let wsStatusMessageBase = "WebSocket: "
    let webRTCStatusMesasgeBase = "WebRTC: "
    
    // UI
    var wsStatusLabel: UILabel!
    var webRTCStatusLabel: UILabel!
    var webRTCMessageLabel: UILabel!
    
    //MARK: - Init
    convenience init(config: WebRTCConfig) {
        self.init(nibName: String(describing: FaceTimeViewController.self),bundle: Bundle(for: FaceTimeViewController.self))
        self.config = config
    }

    //MARK: - App lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webRTCClient = WebRTCClient()
        webRTCClient.delegate = self
        webRTCClient.setup(videoTrack: true, audioTrack: true, dataChannel: true, customFrameCapturer: false)
        
       
        socket = WebSocket(request: URLRequest(url: URL(string: "ws://" + config.ipAddress + ":8080/\(config.userName)")!))
        socket.delegate = self
        
        tryToConnectWebSocket = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            if self.webRTCClient.isConnected || self.isConnected {
                return
            }
            
            self.socket.connect()
        })
        
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UI
    //Estos son temas de interfaz. Cuando haga una libreria me vuelo esto.
    private func setupUI(){
        let remoteVideoViewContainter = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height()*0.7))
        remoteVideoViewContainter.backgroundColor = .gray
        self.view.addSubview(remoteVideoViewContainter)
        
        let remoteVideoView = webRTCClient.remoteVideoView()
        webRTCClient.setupRemoteViewFrame(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width()*0.7, height: ScreenSizeUtil.height()*0.7))
        remoteVideoView.center = remoteVideoViewContainter.center
        remoteVideoViewContainter.addSubview(remoteVideoView)
        
        let localVideoView = webRTCClient.localVideoView()
        webRTCClient.setupLocalViewFrame(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width()/3, height: ScreenSizeUtil.height()/3))
        localVideoView.center.y = self.view.center.y
        localVideoView.subviews.last?.isUserInteractionEnabled = true
        self.view.addSubview(localVideoView)
        
        wsStatusLabel = UILabel(frame: CGRect(x: 0, y: remoteVideoViewContainter.bottom, width: ScreenSizeUtil.width(), height: 30))
        wsStatusLabel.textAlignment = .center
        self.view.addSubview(wsStatusLabel)
        webRTCStatusLabel = UILabel(frame: CGRect(x: 0, y: wsStatusLabel.bottom, width: ScreenSizeUtil.width(), height: 30))
        webRTCStatusLabel.textAlignment = .center
        webRTCStatusLabel.text = webRTCStatusMesasgeBase + "initialized"
        self.view.addSubview(webRTCStatusLabel)
        webRTCMessageLabel = UILabel(frame: CGRect(x: 0, y: webRTCStatusLabel.bottom, width: ScreenSizeUtil.width(), height: 30))
        webRTCMessageLabel.textAlignment = .center
        self.view.addSubview(webRTCMessageLabel)
        
        let buttonWidth = ScreenSizeUtil.width()*0.4
        let buttonHeight: CGFloat = 60
        let buttonRadius: CGFloat = 30
        let callButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
        callButton.setBackgroundImage(UIColor.blue.rectImage(width: callButton.frame.width, height: callButton.frame.height), for: .normal)
        callButton.layer.cornerRadius = buttonRadius
        callButton.layer.masksToBounds = true
        callButton.center.x = ScreenSizeUtil.width()/4
        callButton.center.y = webRTCStatusLabel.bottom + (ScreenSizeUtil.height() - webRTCStatusLabel.bottom)/2
        callButton.setTitle("Call", for: .normal)
        callButton.titleLabel?.font = UIFont.systemFont(ofSize: 23)
        callButton.addTarget(self, action: #selector(self.callButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(callButton)
        
        let hangupButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
        hangupButton.setBackgroundImage(UIColor.red.rectImage(width: hangupButton.frame.width, height: hangupButton.frame.height), for: .normal)
        hangupButton.layer.cornerRadius = buttonRadius
        hangupButton.layer.masksToBounds = true
        hangupButton.center.x = ScreenSizeUtil.width()/4 * 3
        hangupButton.center.y = callButton.center.y
        hangupButton.setTitle("hang up" , for: .normal)
        hangupButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        hangupButton.addTarget(self, action: #selector(self.hangupButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(hangupButton)
    }
    
    // MARK: - UI Events
    @objc func callButtonTapped(_ sender: UIButton){
        if !webRTCClient.isConnected {
            webRTCClient.connect(onSuccess: { (offerSDP: RTCSessionDescription) -> Void in
                self.sendSDP(sessionDescription: offerSDP)
            })
        }
    }
    
    @objc func hangupButtonTapped(_ sender: UIButton){
        if webRTCClient.isConnected {
            webRTCClient.disconnect()
        }
    }
    
    @objc func sendMessageButtonTapped(_ sender: UIButton){
        webRTCClient.sendMessge(message: (sender.titleLabel?.text!)!)
    }
    
    // MARK: - WebRTC Signaling
    private func sendSDP(sessionDescription: RTCSessionDescription){
        var type = ""
        if sessionDescription.type == .offer {
            type = "offer"
        }else if sessionDescription.type == .answer {
            type = "answer"
        }
        
        //TODO: No se que pasa aqui
//        let sdp = SDP.init(sdp: sessionDescription.sdp)
//        let signalingMessage = SignalingMessage.init(type: type, sessionDescription: sdp, candidate: nil)
//        do {
//            let data = try JSONEncoder().encode(signalingMessage)
//            let message = String(data: data, encoding: String.Encoding.utf8)!
//
//            if self.socket.isConnected {
//                self.socket.write(string: message)
//            }
//        }catch{
//            print(error)
//        }
    }
    
    private func sendCandidate(iceCandidate: RTCIceCandidate){
        //TODO: No se que pasa aqui
//        let candidate = Candidate.init(sdp: iceCandidate.sdp, sdpMLineIndex: iceCandidate.sdpMLineIndex, sdpMid: iceCandidate.sdpMid!)
//        let signalingMessage = SignalingMessage.init(type: "candidate", sessionDescription: nil, candidate: candidate)
//        do {
//            let data = try JSONEncoder().encode(signalingMessage)
//            let message = String(data: data, encoding: String.Encoding.utf8)!
//
//            if self.socket.isConnected {
//                self.socket.write(string: message)
//            }
//        }catch{
//            print(error)
//        }
    }

}

// MARK: - WebSocket Delegate
extension FaceTimeViewController: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            print(error)
        }
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("-- websocket did connect --")
        wsStatusLabel.text = wsStatusMessageBase + "connected"
        wsStatusLabel.textColor = .green
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("-- websocket did disconnect --")
        wsStatusLabel.text = wsStatusMessageBase + "disconnected"
        wsStatusLabel.textColor = .red
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) { }
}

// MARK: - WebRTCClient Delegate
extension FaceTimeViewController: WebRTCClientDelegate {
    func didGenerateCandidate(iceCandidate: RTCIceCandidate) {
        self.sendCandidate(iceCandidate: iceCandidate)
    }
    
    func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState) {
        var state = ""
        
        switch iceConnectionState {
        case .checking:
            state = "checking..."
        case .closed:
            state = "closed"
        case .completed:
            state = "completed"
        case .connected:
            state = "connected"
        case .count:
            state = "count..."
        case .disconnected:
            state = "disconnected"
        case .failed:
            state = "failed"
        case .new:
            state = "new..."
        }
        self.webRTCStatusLabel.text = self.webRTCStatusMesasgeBase + state
    }
    
    func didConnectWebRTC() {
        self.webRTCStatusLabel.textColor = .green
        // MARK: Disconnect websocket
        self.socket.disconnect()
    }
    
    func didDisconnectWebRTC() {
        self.webRTCStatusLabel.textColor = .red
    }
    
    func didOpenDataChannel() {
        print("did open data channel")
    }
    
    func didReceiveData(data: Data) {
        print(data)
    }
    
    func didReceiveMessage(message: String) {
        self.webRTCMessageLabel.text = message
    }
}

// MARK: - CameraSessionDelegate
extension FaceTimeViewController: CameraSessionDelegate {
    func didOutput(_ sampleBuffer: CMSampleBuffer) {
        self.webRTCClient.captureCurrentFrame(sampleBuffer: sampleBuffer)
        //TODO No se que pasa aqui
//        if self.useCustomCapturer {
//            if let cvpixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer){
//                if let buffer = self.cameraFilter?.apply(cvpixelBuffer){
//                    self.webRTCClient.captureCurrentFrame(sampleBuffer: buffer)
//                }else{
//                    print("no applied image")
//                }
//            }else{
//                print("no pixelbuffer")
//            }
//            //            self.webRTCClient.captureCurrentFrame(sampleBuffer: buffer)
//        }
    }
}
