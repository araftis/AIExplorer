//
//  AIELossMeanAbsoluteError+TensorFlow.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/9/23.
//

import Foundation

extension AIELossMeanAbsoluteError : AIETensorFlowLossCodeWriter {

    internal func generateLossCode(context: AIETensorFlowContext) throws -> Bool {
        try context.writeFunction(name: "losses.MeanAbsoluteError") {
            try context.writeArgument(reductionType != .none, "reduction=\(reductionType.tensorFlowDescription)")
        }
        return true
    }

}
