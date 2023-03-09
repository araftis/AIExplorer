/*
 AIEFullyConnected+MLCompute.swift
 AIExplorer

 Copyright © 2023, AJ Raftis and AIExplorer authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this 
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the documentation 
   and/or other materials provided with the distribution.
 * Neither the name of AIExplorer nor the names of its contributors may be 
   used to endorse or promote products derived from this software without 
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

extension AIEFullyConnected : AIEMLComputeCodeWriter {

    public func createMLComputeObjCCodeWriter() -> AIECodeWriter {
        return ObjCFullyConnectedCodeWriter(object: self)
    }
    
    public func createMLComputeSwiftCodeWriter() -> AIECodeWriter {
        return SwiftFullyConnectedCodeWriter(object: self)
    }
    
    class ObjCFullyConnectedCodeWriter : AIETypedCodeWriter<AIEFullyConnected> {
        
        open override func generatePropertyDeclarationCode(in context: AIECodeGeneratorContext) throws -> Bool {
            var wrote = false
            if context.scope == .private {
                try context.write("MLCConvolutionDescriptor *_\(object.variableName)Descriptor;\n")
                wrote = true
            }
            try progressToChild(in: context)
            return wrote
        }

        open override func generateInitializationCode(in context: AIECodeGeneratorContext) throws -> Bool {
            // Let's do some generally error checking, first.
            if node.stride < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Stride must be at least 1.", on: node))
            }
            if node.width < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Width must be at least 2, defaulting to 3.", on: node))
            }
            if node.height < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Height must be at least 2, defaulting to 3.", on: node))
            }
            if node.inputFeatureChannels < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Input feature channels must be at least 1.", on: node))
            }
            if node.outputFeatureChannels < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Output feature channels must be at least 1.", on: node))
            }
            // NOTE: Depth can be 0, because when it is we'll just depend on the depth of the input images.
            try context.write("\(node.variableName)Descriptor = ")
            try context.writeFunction(name: "descriptionWith", type: .call, receiver: "MLCConvolutionDescriptor", argumentsIndented: true) {
                try context.writeArgument(name: "kernelWidth", value: "\(node.height)")
                try context.writeArgument(name: "kernelHeight", value: "\(node.height)")
                try context.writeArgument(name: "inputFeatureChannelCount", value: "\(node.inputFeatureChannels)")
                try context.writeArgument(name: "outputFeatureChannelCount", value: "\(node.outputFeatureChannels)")
            }
            
            try progressToChild(in: context)
            
            return true
        }
        
    }

    class SwiftFullyConnectedCodeWriter : AIETypedCodeWriter<AIEFullyConnected> {
    }
    
}

