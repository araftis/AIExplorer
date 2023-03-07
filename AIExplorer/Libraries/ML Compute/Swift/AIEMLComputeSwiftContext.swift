//
//  AIEMLComputeSwiftContext.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/5/23.
//

import Cocoa

open class AIEMLComputeSwiftContext: AIESwiftCodeGeneratorContext {

    open override func codeWriter(for object: Any?) -> AIECodeWriter? {
        if let object = object as? AIEMLComputeSwiftCodeWriter {
            return object.createMLComputeSwiftCodeWriter()
        }
        return super.codeWriter(for: object)
    }

}
