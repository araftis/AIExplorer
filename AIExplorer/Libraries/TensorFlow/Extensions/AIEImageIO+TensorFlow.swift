/*
 AIEImageIO+TensorFlow.swift
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

extension AIEImageIO : AIETensorFlowCodeWriter {
    
    func createTensorFlowCodeWriter() -> AIECodeWriter {
        return AIETensorFlowImageIOWriter(object: self)
    }
    
    internal class AIETensorFlowImageIOWriter : AIETypedCodeWriter<AIEImageIO> {
        
        override func generateInitArguments(context: AIECodeGeneratorContext) throws -> Bool {
            try context.writeArgument("dataSource=None")
            try progressToChild(context: context)
            return true
        }
        
        override func generateInitializationCode(context: AIECodeGeneratorContext) throws -> Bool {
            if let writer = context.codeWriter(for: node.dataSource) {
                if try writer.generateInitializationCode(context: context) {
                    context.generatedCode = true
                }
            } else {
                context.add(message: AIEMessage(type: .warning, message: "\(Swift.type(of: node.dataSource)) doesn't support generating code for TensorFlow.", on: object))
            }
            try progressToChild(context: context)
            return context.generatedCode
        }
        
        override func generateImplementationMethodsCode(in context: AIECodeGeneratorContext) throws -> Bool {
            if let writer = context.codeWriter(for: node.dataSource) {
                if try writer.generateImplementationMethodsCode(in: context) {
                    context.generatedCode = true
                }
            } else {
                context.add(message: AIEMessage(type: .warning, message: "\(Swift.type(of: node.dataSource)) doesn't support generating code for TensorFlow.", on: object))
            }
            try progressToChild(context: context)
            return context.generatedCode
        }
        
        override func generateBuildCode(context: AIECodeGeneratorContext) throws -> Bool {
            if node.batchSize <= 0 {
                context.add(message: AIEMessage(type: .warning, message: "The input node should define a batch size.", on: object))
            }
            if let shape = object.inputShape {
                try context.write("# Input Shape: \(shape)\n")
            }
            if let shape = object.inputShape {
                try context.write("\(object.variableName) = layers.Input(shape=(\(shape[1]), \(shape[2]), \(shape[3])), name='\(object.variableName)')\n")
                if shape[1] == 0 || shape[2] == 0 || shape[3] == 0 {
                    context.add(message: AIEMessage(type: .warning, message: "The input shape must define a width, height, and depth.", on: object))
                }
            }
            try context.write("model.add(\(object.variableName))\n")
            try progressToChild(context: context)
            
            return true
        }

        override func license(context: AIECodeGeneratorContext) -> String? {
            if let writer = context.codeWriter(for: node.dataSource) {
                return writer.license(context: context)
            }
            return nil
        }
        
        override func imports(context: AIECodeGeneratorContext) -> [String] {
            guard let writer = context.codeWriter(for: node.dataSource) else { return [] }
            return writer.imports(context: context)
        }
        
    }
        
}

