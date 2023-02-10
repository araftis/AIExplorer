//
//  AIELossLog.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/9/23.
//

import Cocoa

@objcMembers
open class AIELossLog: AIELoss {

    open var epsilon : Float = 0.001

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)
        coder.decodeFloat(forKey: "epsilon") { value in
            self.epsilon = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        coder.encode(epsilon, forKey: "epsilon")
    }

}
