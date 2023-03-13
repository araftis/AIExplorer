/*
 AIETerminus+TensorFlow.swift
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

extension AIETerminus : AIETensorFlowCodeWriter {
    
    func createTensorFlowCodeWriter() -> AIECodeWriter {
        return AIETensorFlowTerminusWriter(object: self)
    }
    
    internal class AIETensorFlowTerminusWriter : AIETypedCodeWriter<AIETerminus> {
        
        func generateOptimizerCode(context: AIECodeGeneratorContext) throws -> Void {
            try context.write("# We don't generate real optimizer code yet.\n")
            try context.write("optimizer = optimizers.CategoricalCrossentropy()\n")
        }
        
        override func generateBuildCode(in context: AIECodeGeneratorContext) throws -> Bool {
            if object.destinationObjects.count > 0 {
                context.add(message: AIEMessage(type: .error, message: "The loss layer should have no children, and they will not be visited.", on: object))
            }
            
            // Work out the Loss function
            // Note: This will always generate code, so ignore.
            var lossName : String? = nil
            var metricsName : String? = nil
            if let loss = node.loss as? AIETensorFlowLossCodeWriter {
                try context.write("\(loss.variableName) = ")
                _ = try loss.generateLossCode(context: context, for: node)
                lossName = loss.variableName
                context.pushOutput()
                _ = try loss.generateMetricsCode(context: context, for: node)
                let string = context.popOutput()
                if !string.isEmpty {
                    try context.write("metrics = \(string.trimmingCharacters(in: .whitespaces))")
                    metricsName = "metrics"
                }
            } else {
                context.add(message: AIEMessage(type: .error, message: "\(type(of:node.loss)) does not support code generation for TensorFlow.", on: object))
            }
            
            // Now workout the optimizer function
            var optimizerName : String? = nil
            if let optimizer = node.optimizer as? AIETensorFlowOptimizerCodeWriter {
                try context.write("\(optimizer.variableName) = ")
                _ = try optimizer.generateOptimizerCode(context: context)
                optimizerName = optimizer.variableName
            } else {
                context.add(message: AIEMessage(type: .error, message: "\(type(of:node.optimizer)) does not support code generation for TensorFlow.", on: object))
            }
            
            // Finally, write the compile line.
            try context.writeFunction(name: "model.compile") {
                try context.writeArgument(lossName != nil, name: "loss", value: "\(lossName ?? "")")
                try context.writeArgument(optimizerName != nil, name: "optimizer", value: "\(optimizerName ?? "")")
                try context.writeArgument(metricsName != nil, name: "metrics", value: "\(metricsName ?? "")")
            }

            return true
        }
        
    }
    
}
