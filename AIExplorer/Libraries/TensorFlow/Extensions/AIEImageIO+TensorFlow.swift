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
    
    internal func generateInitArguments(context: AIETensorFlowContext) throws -> Bool {
        try context.writeArgument("dataSource=None")
        try progressToChild(context: context)
        return true
    }

    internal func generateInitializationCode(context: AIETensorFlowContext) throws -> Bool {
        if let dataSource = dataSource as? AIETensorFlowCodeWriter {
            if try dataSource.generateInitializationCode(context: context) {
                context.generatedCode = true
            }
        } else {
            context.add(message: AIEMessage(type: .warning, message: "\(Swift.type(of:dataSource)) doesn't support generating code for TensorFlow.", on: dataSource))
        }
        try progressToChild(context: context)
        return context.generatedCode
    }
    
    internal func generateMethodsCode(context: AIETensorFlowContext) throws -> Bool {
        if let dataSource = dataSource as? AIETensorFlowCodeWriter {
            if try dataSource.generateMethodsCode(context: context) {
                context.generatedCode = true
            }
        } else {
            context.add(message: AIEMessage(type: .warning, message: "\(Swift.type(of:dataSource)) doesn't support generating code for TensorFlow.", on: dataSource))
        }
        try progressToChild(context: context)
        return context.generatedCode
    }
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        if batchSize <= 0 {
            context.add(message: AIEMessage(type: .warning, message: "The input node should define a batch size.", on: self))
        }
        if let inputShape {
            try context.output.indent(context.indent).write("# Input Shape: \(inputShape)\n")
        }
        if let shape = inputShape {
            try context.output.indent(2).write("\(variableName) = layers.Input(shape=(\(shape[1]), \(shape[2]), \(shape[3])), name='\(variableName)')\n")
            if shape[1] == 0 || shape[2] == 0 || shape[3] == 0 {
                context.add(message: AIEMessage(type: .warning, message: "The input shape must define a width, height, and depth.", on: self))
            }
        }
        try context.writeIndented("model.add(\(variableName))\n")
        try progressToChild(context: context)
        
        return true
    }
    
    internal var license: String? {
        if let dataSource = dataSource as? AIETensorFlowCodeWriter {
            return dataSource.license
        }
        return nil
    }
    
}

