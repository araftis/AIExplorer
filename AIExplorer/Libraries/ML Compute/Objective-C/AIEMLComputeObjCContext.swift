//
//  AIEMLComputeObjCContext.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/5/23.
//

import Cocoa

open class AIEMLComputeObjCContext: AIEObjCCodeGeneratorContext {
    
    open override func codeWriter(for object: Any?) -> AIECodeWriter? {
        if let object = object as? AIEMLComputeObjCCodeWriter {
            return object.createMLComputeObjCCodeWriter()
        }
        return super.codeWriter(for: object)
    }

}
