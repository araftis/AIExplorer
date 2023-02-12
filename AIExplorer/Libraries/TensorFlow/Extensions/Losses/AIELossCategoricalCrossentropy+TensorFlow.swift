//
//  AIELossCategoricalCrossentropy.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/9/23.
//

import Foundation

extension AIELossCategoricalCrossentropy : AIETensorFlowLossCodeWriter {

    internal func generateLossCode(context: AIETensorFlowContext) throws -> Bool {
        try context.writeFunction(name: "losses.CategoricalCrossentropy") {
            try context.writeArgument(reductionType != .none, "reduction=\(reductionType.tensorFlowDescription)")
            try context.writeArgument(labelSmoothing != 0.0, "label_smoothing=\(labelSmoothing)")
        }
        return true
    }

}

