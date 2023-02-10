
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

extension AIELoss : AIETensorFlowLossCodeWriter {
    
    internal func generateCategoricalCrossentropy(context: AIETensorFlowContext) throws -> Void {
        try context.writeFunction(name: "losses.CategoricalCrossentropy") {
            try context.writeArgument(reductionType != .none, "reduction=\(reductionType.tensorFlowDescription)")
            //try context.writeArgument(labelSmoothing != 0.0, "label_smoothing=\(labelSmoothing)")
        }
    }
    
    internal func generateLossCode(context: AIETensorFlowContext) throws -> Bool {
        try context.writeIndented("\(variableName) = ")
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
        try context.write("\n")
        
        return true
    }
    
}
