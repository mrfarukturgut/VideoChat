//
//  Message.swift
//  VideoChat
//
//  Created by hemenisapp on 29.06.2020.
//  Copyright © 2020 hemenisapp. All rights reserved.
//

import Foundation

enum MessageType: String, Codable {
    case OPEN, OFFER, CANDIDATE
}

enum Message {
    case open(type: MessageType)
    case offer(type: MessageType, source: String, destination: String, payload: SessionDescription)
    case candidate(type: MessageType, source: String, destination: String, payload: IceCandidate)
}

extension Message: Codable {
    
    enum CodingKeys: CodingKey {
        case type, src, dst, payload
    }
    
    enum DecoderError: Error {
        case unknownType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)
        
        switch type {
        case .OPEN:
            self = .open(
                type: type
            )
        case .OFFER:
            self = .offer(
                type: type,
                source: try container.decode(String.self, forKey: .src),
                destination: try container.decode(String.self, forKey: .dst),
                payload: try container.decode(SessionDescription.self, forKey: .payload)
            )
        case .CANDIDATE:
            self = .candidate(
                type: type,
                source: try container.decode(String.self, forKey: .src),
                destination: try container.decode(String.self, forKey: .dst),
                payload: try container.decode(IceCandidate.self, forKey: .payload)
            )
        }
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .open(let type):
            try container.encode(type, forKey: .type)
        case .offer(type: let type, source: let source, destination: let dest, payload: let sdp):
            try container.encode(type, forKey: .type)
            try container.encode(source, forKey: .src)
            try container.encode(dest, forKey: .dst)
            try container.encode(sdp, forKey: .payload)
        case .candidate(type: let type, source: let source, destination: let dest, payload: let ice):
            try container.encode(type, forKey: .type)
            try container.encode(source, forKey: .src)
            try container.encode(dest, forKey: .dst)
            try container.encode(ice, forKey: .payload)
        }
    }
}
