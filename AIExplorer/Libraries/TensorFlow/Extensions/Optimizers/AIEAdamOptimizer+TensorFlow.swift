
import Foundation

extension AIEAdamOptimizer : AIETensorFlowOptimizerCodeWriter {

    func generateOptimizerCode(context: AIETensorFlowContext) throws -> Bool {
        var name = "Adam"
        if type(of: self) == AIEAdamWOptimizer.self {
            name = "AdamW"
        }
        try context.writeIndented("\(variableName) = ")
        try context.writeFunction(name: "optimizers.\(name)") {
            try context.writeArgument(learningRate != 0.001, "learning_rate=\(learningRate)")
            try context.writeArgument(beta1 != 0.9, "beta_1=\(beta1)")
            try context.writeArgument(beta2 != 0.999, "beta_2=\(beta2)")
            try context.writeArgument(epsilon != 1e-07, "epsilon=\(epsilon)")
            try context.writeArgument(usesAMSGrad, "amsgrad=True")
        }
        return true
    }
    
    var variableName: String { return "optimizer" }
    
}
