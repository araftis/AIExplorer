//
//  AIEMLComputeCodeWriter.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/5/23.
//

import Foundation

public protocol AIEMLComputeSwiftCodeWriter {
    
    func createMLComputeSwiftCodeWriter() -> AIECodeWriter
    
}

public protocol AIEMLComputeObjCCodeWriter {
    
    func createMLComputeObjCCodeWriter() -> AIECodeWriter
    
}

public protocol AIEMLComputeCodeWriter : AIEMLComputeSwiftCodeWriter, AIEMLComputeObjCCodeWriter {
    
}
