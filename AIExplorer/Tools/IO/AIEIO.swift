//
//  AIEIO.swift
//  AIExplorer
//
//  Created by AJ Raftis on 11/19/21.
//

import Cocoa

@objcMembers
open class AIEIO: AIEGraphic {

    public enum Kind : Int {
        case unknown
        case image
        case audio
        case text
        case video
        case knowledgeGraph
    }
    
    open var type : AIEIO.Kind { return .unknown }

}