//
//  AIEActivationTool.swift
//  AIExplorer
//
//  Created by AJ Raftis on 1/19/21.
//

import Cocoa
import Draw

public enum AIEActivationTag : Int {
    case activation = 0
    case multiheadAttention = 1
    case softmax = 2
}

@objcMembers
open class AIEActivationTool: AIETool {

    open override func fillColor(for graphic: AIEGraphic) -> NSColor {
        return NSColor(displayP3Red: 0.25, green: 0.770, blue: 0.0, alpha: 0.75)
    }

}
