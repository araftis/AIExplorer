/*
 AIEBranch+TensorFlow.swift
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

import Draw

extension AIEBranch : AIETensorFlowCodeWriter {

    func createTensorFlowCodeWriter() -> AIECodeWriter {
        return AIETensorFlowBranchWriter(object: self)
    }
    
    internal class AIETensorFlowBranchWriter : AIETypedCodeWriter<AIEBranch> {
        
        var exitLinks : [DrawLink] {
            return node.exitLinks
        }
        
        override func generateInitArguments(context: AIECodeGeneratorContext) throws -> Bool {
            return try generateCode(for: exitLinks, context: context, using: { child in
                if let writer = context.codeWriter(for: child) {
                    return try writer.generateInitArguments(context: context)
                }
                return false
            })
        }
        
        override func generateInitializationCode(context: AIECodeGeneratorContext) throws -> Bool {
            return try generateCode(for: exitLinks, context: context, using: { (child) in
                if let writer = context.codeWriter(for: child) {
                    return try writer.generateInitializationCode(context: context)
                }
                return false
            })
        }
        
        override func generateImplementationMethodsCode(in context: AIECodeGeneratorContext) throws -> Bool {
            return try generateCode(for: exitLinks, context: context, using: { (child) in
                if let writer = context.codeWriter(for: child) {
                    return try writer.generateImplementationMethodsCode(in: context)
                }
                return false
            })
        }
        
        override func generateBuildCode(in context: AIECodeGeneratorContext) throws -> Bool {
            return try generateCode(for: exitLinks, context: context)
        }
        
        func generateCode(for links : [DrawLink], context: AIECodeGeneratorContext, using block: (_ writer: AIECodeWriter) throws -> Bool) throws -> Bool {
            var wroteCode = false
            for link in links {
                if let writer = context.codeWriter(for: link.destination) {
                    context.pushNode(self)
                    if try block(writer) {
                        wroteCode = true
                    }
                    context.popNode()
                } else {
                    context.add(message: AIEMessage(type: .error, message: "\(type(of: object)) does not support TensorFlow code generation.", on: object))
                }
            }
            return wroteCode
        }
        
        func generateCode(for links : [DrawLink], context: AIECodeGeneratorContext) throws -> Bool {
            var wroteCode = false
            
            for (index, link) in links.enumerated() {
                if let child = link.destination as? AIEGraphic {
                    // We'll quietly ignore any exit links that aren't NN objects.
                    context.pushNode(self)
                    let condition = link.extendedProperties["condition"] as? AJREvaluation
                    if let condition {
                        if index == 0 {
                            try context.write("if \(condition):\n")
                        } else {
                            try context.write(" elif \(condition):\n")
                        }
                    } else {
                        try context.write("else:\n")
                    }
                    context.incrementIndent()
                    let generatedCode : Bool
                    if let writer = context.codeWriter(for: child) {
                        generatedCode = try writer.generateBuildCode(in: context)
                    } else {
                        context.add(message: AIEMessage(type: .error, message: "\(type(of: child)) does not support TensorFlow code generation.", on: child))
                        generatedCode = false
                    }
                    if  generatedCode {
                        context.generatedCode = true
                    } else {
                        try context.write("pass\n")
                    }
                    context.decrementIndent()
                    context.popNode()
                    wroteCode = true
                }
            }
            
            return wroteCode
        }
        
    }

}
