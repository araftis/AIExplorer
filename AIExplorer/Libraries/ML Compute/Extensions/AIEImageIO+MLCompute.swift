//
//  AIEImageIO+MLCompute.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/5/23.
//

import Foundation

extension AIEImageIO : AIEMLComputeCodeWriter {

    public func createMLComputeSwiftCodeWriter() -> AIECodeWriter {
        return ObjCImageIOCodeWriter(object: self)
    }
    
    public func createMLComputeObjCCodeWriter() -> AIECodeWriter {
        return SwiftImageIOCodeWriter(object: self)
    }
    
    class ObjCImageIOCodeWriter : AIETypedCodeWriter<AIEImageIO> {
        
        override func generateBuildCode(in context: AIECodeGeneratorContext) throws -> Bool {
            try progressToChild(in: context)
            // IO nodes don't actually become part of the graph, they just define our input.
            return context.generatedCode
        }
        
    }
    
    class SwiftImageIOCodeWriter : AIETypedCodeWriter<AIEImageIO> {
        
        override func generateBuildCode(in context: AIECodeGeneratorContext) throws -> Bool {
            try progressToChild(in: context)
            // IO nodes don't actually become part of the graph, they just define our input.
            return context.generatedCode
        }
        
   }

}
