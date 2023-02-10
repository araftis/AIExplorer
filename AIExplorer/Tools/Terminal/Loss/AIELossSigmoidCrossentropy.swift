//
//  AIELossSigmoidCrossentropy.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/9/23.
//

import Cocoa

@objcMembers
open class AIELossSigmoidCrossentropy: AIELoss {

    open var labelSmoothing : Float = 0.001

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)
        coder.decodeFloat(forKey: "labelSmoothing") { value in
            self.labelSmoothing = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        coder.encode(labelSmoothing, forKey: "labelSmoothing")
    }

}
