//
//  AIEMessage.swift
//  AIExplorer
//
//  Created by AJ Raftis on 10/14/21.
//

import Cocoa
import AJRFoundation
import Draw

public typealias AIEMessageObject = AJRXMLCoding & NSObject

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
                    && object == object.object)
        }
        return false
    }
}
