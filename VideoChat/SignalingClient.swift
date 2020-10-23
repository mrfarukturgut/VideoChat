//
//  SignalingClient.swift
//  VideoChat
//
//  Created by hemenisapp on 22.06.2020.
//  Copyright © 2020 hemenisapp. All rights reserved.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: class {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}

final class SignalingClient {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: WebSocketProvider
    weak var delegate: SignalClientDelegate?
    
    init(webSocket: WebSocketProvider) {
        self.webSocket = webSocket
    }
    
    func connect() {
        self.webSocket.delegate = self
        print("Connecting")
        self.webSocket.connect()
    }
    
    func disconnect() {
        self.webSocket.disconnect()
    }
    
    func send(sdp rtcSdp: RTCSessionDescription, source: String, destination: String) {
        let message = Message.offer(type: .OFFER, source: source, destination: destination, payload: SessionDescription(from: rtcSdp))
        do {
            let dataMessage = try self.encoder.encode(message)
            print("sending offer")
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate, source: String, destination: String) {
        let message = Message.candidate(type: .CANDIDATE, source: source, destination: destination, payload: IceCandidate(from: rtcIceCandidate))
        //let message = Message.candidate(IceCandidate(from: rtcIceCandidate))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
}


extension SignalingClient: WebSocketProviderDelegate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidDisconnect(self)
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            self.webSocket.connect()
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        let message: Message
        print(String(data: data, encoding: .utf8)!)
        do {
            message = try self.decoder.decode(Message.self, from: data)
        }
        catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
            webSocket.connect()
            return
        }
        
        switch message {
        case .candidate(type: _, source: _, destination: _, payload: let ice):
            self.delegate?.signalClient(self, didReceiveCandidate: ice.rtcIceCandidate)
        case .offer(type: _, source: _, destination: _, payload: let sdp):
            self.delegate?.signalClient(self, didReceiveRemoteSdp: sdp.rtcSessionDescription)
        case .open(type: let type):
            debugPrint("Other type came \(type.rawValue)")
        }
    }
}
