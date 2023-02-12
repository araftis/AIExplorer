/*
 AIELoss+TensorFlow.swift
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

internal protocol AIETensorFlowLossCodeWriter : AIEMessageObject {
    
    func generateLossCode(context: AIETensorFlowContext) throws -> Bool
    var variableName : String { get }
    
}

extension AIETensorFlowLossCodeWriter {
    
    func generateLossCode(context: AIETensorFlowContext) throws -> Bool {
        return false
    }
    
    var variableName : String { return "loss" }

}

internal extension AIELoss.ReductionType {
    
    var tensorFlowDescription : String {
        switch self {
        case .all: return "auto"
        case .any: return "auto"
        case .argMax: return "-"
        case .argMin: return "-"
        case .max: return "-"
        case .mean: return "-"
        case .min: return "-"
        case .none: return "none"
        case .sum: return "sum"
        case .l1Norm: return "-"
        }
    }
    
}

//extension AIELoss : AIETensorFlowLossCodeWriter {
//
//    internal func generateLossCode(context: AIETensorFlowContext) throws -> Bool {
//        try context.writeIndented("\(variableName) = ")
//        switch type {
//        case .categoricalCrossEntropy:
//            try generateCategoricalCrossentropy(context: context)
//        case .cosineDistance:
//            try context.write("losses.CosineSimilarity()")
//        case .hinge:
//            try context.write("losses.Hinge()")
//        case .huber:
//            try context.write("losses.Huber()")
//        case .log:
//            try context.write("losses.LogCosh()")
//        case .meanAbsoluteError:
//            try context.write("losses.MeanAbsoluteError()")
//        case .meanSquaredError:
//            try context.write("losses.MeanSquaredError()")
//        case .sigmoidCrossEntropy:
//            try context.write("losses.CategoricalCrossentropy()")
//        case .softmaxCrossEntropy:
//            try context.write("losses.CategoricalCrossentropy()")
//        }
//        try context.write("\n")
//
//        return true
//    }
//    
//}
