/*
 AIELossCategoricalCrossentropy+TensorFlow.swift
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

extension AIELossCategoricalCrossentropy : AIETensorFlowLossCodeWriter {

    internal func useSparse(for object: AIEGraphic) -> Bool {
        if let inputShape = object.inputShape,
           inputShape.count == 2,
           inputShape[1] > 2 {
            return true
        }
        return false
    }
    
    internal func generateLossCode(context: AIECodeGeneratorContext, for object: AIEGraphic) throws -> Bool {
        if useSparse(for: object) {
            // TensorFlow wants us to use SparseCategoricalCrossentropy when there's more than two label classes.
            try context.writeFunction(name: "SparseCategoricalCrossentropy", receiver: "losses") {
                try context.writeArgument(reductionType != .none, name: "reduction", value: "\(reductionType.tensorFlowDescription)")
                try context.writeArgument(name: "from_logits", value: "True")
            }
        } else {
            try context.writeFunction(name: "CategoricalCrossentropy", receiver: "losses") {
                try context.writeArgument(reductionType != .none, name: "reduction", value: "\(reductionType.tensorFlowDescription)")
                try context.writeArgument(labelSmoothing != 0.0, name: "label_smoothing", value: "\(labelSmoothing)")
                try context.writeArgument(name: "from_logits", value: "True")
            }
        }
        return true
    }
    
    internal func generateMetricsCode(context: AIECodeGeneratorContext, for object: AIEGraphic) throws -> Bool {
        if useSparse(for: object) {
            try context.writeFunction(name: "SparseCategoricalAccuracy", receiver: "tf.keras.metrics") {
            }
        } else {
            try context.writeFunction(name: "CategoricalAccuracy", receiver: "tf.keras.metrics") {
            }
        }
        return true
    }

}

