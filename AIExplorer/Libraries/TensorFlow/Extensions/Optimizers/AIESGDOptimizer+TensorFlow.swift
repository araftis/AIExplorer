
import Foundation

extension AIESGDOptimizer : AIETensorFlowOptimizerCodeWriter {
    
    func generateOptimizerCode(context: AIETensorFlowContext) throws -> Bool {
        try context.writeIndented("\(variableName) = ")
        try context.writeFunction(name: "optimizers.SGD") {
            try context.writeArgument(learningRate != 0.001, "learning_rate=\(learningRate)")
            try context.writeArgument(momentumScale != 0.0, "momentum=\(momentumScale)")
            try context.writeArgument(usesNesterovMomentum, "nesterov=True")
        }
        return true
    }
    
    var variableName: String { return "optimizer" }
    
}
