//
//  AIEIOTool.swift
//  NN Explorer
//
//  Created by AJ Raftis on 1/3/21.
//

import Draw

public enum AIEIOTag : Int {
    case image = 0
    case audio = 1
    case text = 2
    case knowledgeGraph = 3
}

@objcMembers
open class AIEIOTool: AIETool {

    open override func fillColor(for graphic: AIEGraphic) -> NSColor {
        return NSColor(displayP3Red: 1.0, green: 0.502, blue: 0.0, alpha: 0.75)
    }

}
