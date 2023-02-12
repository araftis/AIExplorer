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
    
    func generateCode(context: AIETensorFlowContext) throws -> Bool {
        let children = exitLinks
        
        // We need to take two approaches here depending on if we're generating code for the init or generation method.
        switch context.stage {
        case .initialization:
            try generateInitCode(for: children, context: context)
        case .build:
            try generateCode(for: children, context: context)
        }

        return true 
    }

    func generateInitCode(for links : [DrawLink], context: AIETensorFlowContext) throws -> Void {
        for link in links {
            if let child = link.destination as? AIEGraphic {
                context.push(self)
                if let child = child as? AIETensorFlowCodeWriter {
                    try child.generateCreationInsideInit(context: context)
                } else {
                    context.add(message: AIEMessage(type: .error, message: "\(type(of: child)) does not support TensorFlow code generation.", on: child))
                }
                context.pop()
            }
        }
    }
    
    func generateCode(for links : [DrawLink], context: AIETensorFlowContext) throws -> Void {
        for (index, link) in links.enumerated() {
            if let child = link.destination as? AIEGraphic {
                // We'll quietly ignore any exit links that aren't NN objects.
                context.push(self)
                let condition = link.extendedProperties["condition"] as? AJREvaluation
                if let condition {
                    if index == 0 {
                        try context.writeIndented("if \(condition):\n")
                    } else {
                        try context.write(" elif \(condition):\n")
                    }
                } else {
                    try context.writeIndented("else:\n")
                }
                context.incrementIndent()
                let generatedCode : Bool
                if let child = child as? AIETensorFlowCodeWriter {
                    generatedCode = try child.generateCode(context: context)
                } else {
                    context.add(message: AIEMessage(type: .error, message: "\(type(of: child)) does not support TensorFlow code generation.", on: child))
                    generatedCode = false
                }
                if  generatedCode {
                    context.generatedCode = true
                } else {
                    try context.writeIndented("pass\n")
                }
                context.decrementIndent()
                context.pop()
            }
        }
    }

}
