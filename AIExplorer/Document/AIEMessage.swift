/*
 AIEMessage.swift
 AIExplorer

 Copyright © 2021, AJ Raftis and AIExplorer authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this 
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the documentation 
   and/or other materials provided with the distribution.
 * Neither the name of AIExplorer nor the names of its contributors may be 
   used to endorse or promote products derived from this software without 
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Cocoa
import AJRFoundation
import Draw

@objc
public protocol AIEMessageObject : AJRXMLCoding {
    
    var messagesTitle : String { get }
    var messagesImage : NSImage? { get }

}

/**
 Defines a "message" to the user, whether that's an error, warning, or info.
 */
@objcMembers
open class AIEMessage: NSObject, AJRXMLCoding {

    public enum Intent : CaseIterable {
        case info
        case warning
        case error

        init?(string: String) {
            if let found = Self.allCases.first(where: { string == "\($0)" }) {
                self = found
            } else {
                return nil
            }
        }
    }

    open var message : String
    open var type : Intent
    open var object : AIEMessageObject?
    
    required public override init() {
        self.message = ""
        self.type = .info
        self.object = nil
    }

    public init(type: Intent, message: String, on object: AIEMessageObject?) {
        self.message = message
        self.type = type
        self.object = object
    }

    // MARK: - AJRXMLCoding

    open func encode(with coder: AJRXMLCoder) {
        coder.encode(message, forKey: "message")
        coder.encode(String(describing: type), forKey: "type")
        coder.encode(object, forKey: "object")
    }

    open func decode(with coder: AJRXMLCoder) {
        coder.decodeString(forKey: "message") { message in
            self.message = message
        }
        coder.decodeString(forKey: "type") { rawType in
            self.type = Intent(string: rawType) ?? .info
        }
        coder.decodeObject(forKey: "object") { object in
            self.object = object as? AIEMessageObject
        }
    }

    open override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? AIEMessage {
            return (message == object.message
                    && type == object.type
                    && object === object.object)
        }
        return false
    }
}
