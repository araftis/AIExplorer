//
//  AIELossSigmoidCrossentropy+TensorFlow.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/9/23.
//

import Foundation

extension AIELossSigmoidCrossentropy : AIETensorFlowLossCodeWriter {

    internal func generateLossCode(context: AIETensorFlowContext) throws -> Bool {
        context.add(message: AIEMessage(type: .warning, message: "TensorFlow doesn't support correctly writing \(localizedName ?? "\(type(of:self))")", on: self))
        try context.writeFunction(name: "losses.MeanSquaredError") {
            try context.writeArgument(reductionType != .none, "reduction=\(reductionType.tensorFlowDescription)")
        }
        return true
    }

}
