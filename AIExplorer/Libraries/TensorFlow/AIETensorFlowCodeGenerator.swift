//
//  AIETensorFlowCodeGenerator.swift
//  AIExplorer
//
//  Created by AJ Raftis on 1/31/21.
//

import Cocoa

public protocol AIETensorFlowCodeWriter {

    func generateCode(to outputStream: OutputStream) throws -> Void

}

extension AIEConvolution : AIETensorFlowCodeWriter {

    public func generateCode(to outputStream: OutputStream) throws {
        try outputStream.write("# We're writing a convolution layer.")
    }

}


extension AIEImageIO : AIETensorFlowCodeWriter {

    public func generateCode(to outputStream: OutputStream) throws {
        try outputStream.write("# Image IO Layer")
        //try outputStream.write("# Width: \(self.width ?? "<any>"), height: \(self.height ?? "<any>"), depth: \(self.depth ?? "<any>")")
    }

}


@objcMembers
open class AIETensorFlowCodeGenerator: AIECodeGenerator {

    open func generateCode(for object: AIEGraphic, visited: inout Set<AIEGraphic>, to outputStream: OutputStream) throws -> Void {
        if !visited.contains(object) {
            visited.insert(object)

            try outputStream.write("\n")

            if let object = object as? AIETensorFlowCodeWriter {
                try object.generateCode(to: outputStream)
            } else {
                try outputStream.write("# Generating: \(object.title)\n")
            }

            for child in object.destinationObjects {
                try generateCode(for: child, visited: &visited, to: outputStream)
            }
        }
    }

    open override func generate(to outputStream: OutputStream) throws {
        var visited = Set<AIEGraphic>()

        try outputStream.write("# Look ma! We're generating code.\n")
        try outputStream.write("# Application: \(ProcessInfo.processInfo.processName)\n")
        try outputStream.write("# Creator: \(NSUserName())\n")
        try outputStream.write("# Date: \(Date())\n")
        try generateCode(for: root, visited: &visited, to: outputStream)
        try outputStream.write("\n# Code generation complete.\n")
    }

}
