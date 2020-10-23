//
//  ViewController.swift
//  VideoChat
//
//  Created by hemenisapp on 21.06.2020.
//  Copyright © 2020 hemenisapp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var sourceField: UITextField = {
        let field = UITextField()
        field.placeholder = "Your ID"
        field.translatesAutoresizingMaskIntoConstraints = false
        field.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        field.leftViewMode = .always
        field.rightViewMode = .always
        field.keyboardType = .decimalPad
        field.layer.cornerRadius = 6
        return field
    }()
    
    var targetField: UITextField = {
        let field = UITextField()
        field.placeholder = "Target ID"
        field.translatesAutoresizingMaskIntoConstraints = false
        field.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        field.leftViewMode = .always
        field.rightViewMode = .always
        field.keyboardType = .decimalPad
        field.layer.cornerRadius = 6
        return field
    }()
    
    var startVideoChatButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Video Chat", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 6
        return button
    }()
    
    var waitForCallButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Wait For Call", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 6
        return button
    }()
    
    fileprivate let defaultSignalingServerUrl = "wss://peer.aiocareer.net/peerjs/peerjs?key=peerjs&"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.tintColor = .white
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.sourceField)
        self.view.addSubview(self.targetField)
        self.view.addSubview(self.startVideoChatButton)
        self.view.addSubview(self.waitForCallButton)
        
        NSLayoutConstraint.activate([
            self.sourceField.heightAnchor.constraint(equalToConstant: 44),
            self.sourceField.widthAnchor.constraint(equalToConstant: 300),
            self.sourceField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            self.sourceField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200),
            self.targetField.heightAnchor.constraint(equalToConstant: 44),
            self.targetField.widthAnchor.constraint(equalToConstant: 300),
            self.targetField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            self.targetField.topAnchor.constraint(equalTo: self.sourceField.bottomAnchor, constant: 12),
            self.startVideoChatButton.heightAnchor.constraint(equalToConstant: 44),
            self.startVideoChatButton.widthAnchor.constraint(equalToConstant: 300),
            self.startVideoChatButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            self.startVideoChatButton.topAnchor.constraint(equalTo: self.targetField.bottomAnchor, constant: 12),
            self.waitForCallButton.heightAnchor.constraint(equalToConstant: 44),
            self.waitForCallButton.widthAnchor.constraint(equalToConstant: 300),
            self.waitForCallButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            self.waitForCallButton.topAnchor.constraint(equalTo: self.startVideoChatButton.bottomAnchor, constant: 12)
        ])
        self.view.layoutSubviews()
        
        self.startVideoChatButton.addTarget(self, action: #selector(self.startVideoChat(_:)), for: .touchUpInside)
        self.waitForCallButton.addTarget(self, action: #selector(self.startVideoChat(_:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func startVideoChat(_ sender: UIButton) {
        
        guard
            let sourceID = self.sourceField.text, !sourceID.isEmpty,
            let destinationID = self.targetField.text, !destinationID.isEmpty else {
                
                let alert = UIAlertController(
                    title: "Warning",
                    message: "ID's for both source and destination are required.",
                    preferredStyle: .alert
                )
                alert.addAction(
                    UIAlertAction(
                        title: "OK",
                        style: .cancel
                    )
                )
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        let webRTCClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
        self.view.endEditing(true)
        let url = URL(string: "wss://peer.aiocareer.net/peerjs/peerjs?key=peerjs&id=\(self.sourceField.text!)&token=\(self.targetField.text!)")
        let websocketProvider = StarscreamWebSocket(url: url!)
        let signalingClient = SignalingClient(webSocket: websocketProvider)
        
        
        
        let vc = VideoChatViewController(src: self.sourceField.text!, dst: self.targetField.text!, webRTCClient: webRTCClient, signalingClient: signalingClient)
        
        if sender.titleLabel?.text == "Wait For Call" {
            print("asdasd")
            vc.peerIsCalling = false
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

