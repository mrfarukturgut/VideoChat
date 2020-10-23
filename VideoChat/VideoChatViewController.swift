//
//  VideoChatViewController.swift
//  VideoChat
//
//  Created by hemenisapp on 21.06.2020.
//  Copyright © 2020 hemenisapp. All rights reserved.
//


//When I copied this, I had no freaking idea what was this about.
//I still don't but it now works.

import Foundation
import UIKit
import WebRTC

class VideoChatViewController: UIViewController {
    
    var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var targetIdentifer: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var targetDescription: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "hemenis Call"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var callDuration: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "09:05"
        label.alpha = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var endButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .red
        button.layer.cornerRadius = 28
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        let symbol = UIImage(named: "phone.down.fill")
        button.setImage(symbol, for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.tintColor = .white
        return button
    }()
    
    var audioOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        let symbol = UIImage(named: "mic.fill")
        button.setImage(symbol, for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.tintColor = .black
        return button
    }()
    
    var videoOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        let symbol = UIImage(named: "video.fill")
        button.setImage(symbol, for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.tintColor = .black
        return button
    }()
    
    //WebRTC requires different view types respect to devices architecture. Below is OpenGSL, other is Metal.
    
    #if arch(arm64)
    var incomingVideoStreamView : RTCMTLVideoView = {
        let view = RTCMTLVideoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.videoContentMode = .scaleAspectFill
        return view
    }()
    
    var outgoingVideoStreamView: RTCMTLVideoView = {
        let view = RTCMTLVideoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.videoContentMode = .scaleAspectFill
        return view
    }()
    #else
    var incomingVideoStreamView : RTCEAGLVideoView = {
        let view = RTCEAGLVideoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var outgoingVideoStreamView: RTCEAGLVideoView = {
        let view = RTCEAGLVideoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    #endif
    
    
    private var webRTCClient: WebRTCClient
    private var signalingClient: SignalingClient
    private var src: String
    private var dst: String
    
    var peerIsCalling: Bool = true
    
    private var isMuted: Bool = false {
        didSet {
            self.updateUI()
        }
    }
    private var onVideo: Bool = true {
        didSet {
            self.updateUI()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(src: String, dst: String, webRTCClient: WebRTCClient, signalingClient: SignalingClient) {
        self.src = src
        self.dst = dst
        self.targetIdentifer.text = dst
        self.webRTCClient = webRTCClient
        self.signalingClient = signalingClient
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webRTCClient.delegate = self
        self.signalingClient.delegate = self
        self.signalingClient.connect()
    
        self.webRTCClient.startCaptureLocalVideo(renderer: outgoingVideoStreamView)
        self.webRTCClient.renderRemoteVideo(to: self.incomingVideoStreamView)
        
        
        // -- MARK: UI
        
        self.view.backgroundColor = .black
    
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        self.view.addSubview(incomingVideoStreamView)
        self.view.addSubview(outgoingVideoStreamView)
        
        
        
        self.view.addSubview(bottomView)
        
        self.bottomView.addSubview(targetIdentifer)
        self.bottomView.addSubview(targetDescription)
        self.bottomView.addSubview(callDuration)
        self.bottomView.addSubview(endButton)
        self.bottomView.addSubview(audioOptionButton)
        self.bottomView.addSubview(videoOptionButton)
        
        self.endButton.addTarget(self, action: #selector(self.end(_:)), for: .touchUpInside)
        self.audioOptionButton.addTarget(self, action: #selector(self.mute(_:)), for: .touchUpInside)
        self.videoOptionButton.addTarget(self, action: #selector(self.close(_:)), for: .touchUpInside)

        
        NSLayoutConstraint.activate([
            
            self.bottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            self.bottomView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.bottomView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            self.bottomView.heightAnchor.constraint(equalToConstant: 208),
            
            
            self.targetIdentifer.leadingAnchor.constraint(equalTo: self.bottomView.leadingAnchor, constant: 20),
            self.targetIdentifer.trailingAnchor.constraint(equalTo: self.bottomView.trailingAnchor, constant: -20),
            self.targetIdentifer.topAnchor.constraint(equalTo: self.bottomView.topAnchor, constant: 16),
            self.targetIdentifer.heightAnchor.constraint(equalToConstant: 24),
            self.targetDescription.leadingAnchor.constraint(equalTo: self.bottomView.leadingAnchor, constant: 20),
            self.targetDescription.trailingAnchor.constraint(equalTo: self.bottomView.trailingAnchor, constant: -20),
            self.targetDescription.topAnchor.constraint(equalTo: self.targetIdentifer.bottomAnchor, constant: 8),
            self.targetDescription.heightAnchor.constraint(equalToConstant: 20),
            self.callDuration.leadingAnchor.constraint(equalTo: self.bottomView.leadingAnchor, constant: 20),
            self.callDuration.trailingAnchor.constraint(equalTo: self.bottomView.trailingAnchor, constant: -20),
            self.callDuration.topAnchor.constraint(equalTo: self.targetDescription.bottomAnchor, constant: 8),
            self.callDuration.heightAnchor.constraint(equalToConstant: 20),
            
            self.endButton.topAnchor.constraint(equalTo: self.callDuration.bottomAnchor, constant: 24),
            self.endButton.centerXAnchor.constraint(equalTo: self.bottomView.centerXAnchor, constant: 0),
            self.endButton.heightAnchor.constraint(equalToConstant: 56),
            self.endButton.widthAnchor.constraint(equalToConstant: 56),
            
            self.audioOptionButton.trailingAnchor.constraint(equalTo: self.endButton.leadingAnchor, constant: -40),
            self.audioOptionButton.centerYAnchor.constraint(equalTo: self.endButton.centerYAnchor, constant: 0),
            self.audioOptionButton.heightAnchor.constraint(equalToConstant: 40),
            self.audioOptionButton.widthAnchor.constraint(equalToConstant: 40),
            
            self.videoOptionButton.leadingAnchor.constraint(equalTo: self.endButton.trailingAnchor, constant: 40),
            self.videoOptionButton.centerYAnchor.constraint(equalTo: self.endButton.centerYAnchor, constant: 0),
            self.videoOptionButton.heightAnchor.constraint(equalToConstant: 40),
            self.videoOptionButton.widthAnchor.constraint(equalToConstant: 40),
            
            self.incomingVideoStreamView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.incomingVideoStreamView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            self.incomingVideoStreamView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.incomingVideoStreamView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            
            self.outgoingVideoStreamView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 24),
            self.outgoingVideoStreamView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            self.outgoingVideoStreamView.heightAnchor.constraint(equalToConstant: 120),
            self.outgoingVideoStreamView.widthAnchor.constraint(equalToConstant: 90),

        ])
        
        self.view.layoutIfNeeded()
        self.updateUI()
    
    }
    
    @objc func end(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func mute(_ sender: UIButton) {
        
        self.isMuted.toggle()
        print("is muted : \(self.isMuted)")
        if self.isMuted {
            print("muting")
            self.webRTCClient.muteAudio()
        } else {
            print("unmuting")
            self.webRTCClient.unmuteAudio()
        }
    }
    
    @objc func close(_ sender: UIButton) {
        self.onVideo.toggle()
        print("on Video \(self.onVideo)")
        if self.onVideo {
            print("starting to outgoing render")
            self.webRTCClient.unpauseVideo()
        } else {
            print("stopping outgoing")
            self.webRTCClient.pauseVideo()
        }
    }
    
    private func updateUI(){
        DispatchQueue.main.async {
            self.outgoingVideoStreamView.alpha = self.onVideo ? 1 : 0
            //self.audioOptionButton.tintColor = self.isMuted ? .blue : .black
            self.audioOptionButton.setImage(self.isMuted ? UIImage(named: "mic.slash.fill") : UIImage(named: "mic.fill"), for: .normal)
            //self.videoOptionButton.tintColor = self.onVideo ? .black : .blue
            self.videoOptionButton.setImage(self.onVideo ? UIImage(named: "video.fill") : UIImage(named: "video.slash.fill"), for: .normal)
        }
    }
    
}

extension VideoChatViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        print("signal client connected")
        
        if self.peerIsCalling {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.webRTCClient.offer { (sdp) in
                    self.signalingClient.send(sdp: sdp, source: self.src, destination: self.dst)
                }
            }
        }
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        print("signal client disconnected")
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp")
        self.webRTCClient.set(remoteSdp: sdp) { (error) in
            print("setting remote sdp failure \(String(describing: error?.localizedDescription))")
            self.webRTCClient.answer { (localSdp) in
                print("answered it with local sdp")
                self.signalingClient.send(sdp: localSdp, source: self.src, destination: self.dst)
            }
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("Received remote candidate")
        self.webRTCClient.set(remoteCandidate: candidate)
    }
}


extension VideoChatViewController: WebRTCClientDelegate {

    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.signalingClient.send(candidate: candidate, source: self.src, destination: self.dst)
    }

    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        print("webrtc connection state changed to: \(state.description)")
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

