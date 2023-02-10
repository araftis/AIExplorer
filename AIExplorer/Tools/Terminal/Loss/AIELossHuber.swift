//
//  AIELossHuber.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/9/23.
//

import Cocoa

@objcMembers
open class AIELossHuber: AIELoss {

    open var delta : Float = 0.001

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)
        coder.decodeFloat(forKey: "delta") { value in
            self.delta = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        coder.encode(delta, forKey: "delta")
    }

}
