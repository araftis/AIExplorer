//
//  AIELossSoftmaxCrossentropy.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/9/23.
//

import Cocoa

public extension AIELossIndentifier {
    static var softmaxCrossentropy = AIELossIndentifier("softmaxCrossentropy")
}

@objcMembers
open class AIELossSoftmaxCrossentropy: AIELoss {

    open var labelSmoothing : Float = 0.001
    open var classCount : Int = 1

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)
        coder.decodeFloat(forKey: "labelSmoothing") { value in
            self.labelSmoothing = value
        }
        coder.decodeInteger(forKey: "classCount") { value in
            self.classCount = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        coder.encode(labelSmoothing, forKey: "labelSmoothing")
        coder.encode(classCount, forKey: "classCount")
    }

}
