
import Foundation

extension AIERMSPropOptimizer : AIETensorFlowOptimizerCodeWriter {
    
    func generateOptimizerCode(context: AIETensorFlowContext) throws -> Bool {
        try context.writeIndented("\(variableName) = ")
        try context.writeFunction(name: "optimizers.RMSProp") {
            try context.writeArgument(learningRate != 0.001, "learning_rate=\(learningRate)")
            try context.writeArgument(alpha != 0.9, "rho=\(alpha)")
            try context.writeArgument(momentumScale != 0.0, "momentum=\(momentumScale)")
            try context.writeArgument(epsilon != 1e-07, "epsilon=\(epsilon)")
            try context.writeArgument(isCentered, "centered=True")
        }
        return true
    }
    
    var variableName: String { return "optimizer" }
    
}
