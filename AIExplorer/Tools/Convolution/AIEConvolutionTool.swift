//
//  AIEConvolutionTool.swift
//  NN Explorer
//
//  Created by AJ Raftis on 12/31/20.
//

import Draw

public enum AIEConvolutionTag : Int {
    case convolution = 0
    case lstm = 1
    case pooling = 2
    case upsample = 3
}


@objcMembers
open class AIEConvolutionTool: AIETool {

    open override func fillColor(for graphic: AIEGraphic) -> NSColor {
        return NSColor(displayP3Red: 0.233, green: 0.492, blue: 0.949, alpha: 0.75)
    }

}


