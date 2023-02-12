
import Foundation

extension AIETerminus : AIETensorFlowCodeWriter {
    
    internal func generateOptimizerCode(context: AIETensorFlowContext) throws -> Void {
        try context.writeIndented("# We don't generate real optimizer code yet.\n")
        try context.writeIndented("optimizer = optimizers.CategoricalCrossentropy()\n")
    }
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        if destinationObjects.count > 0 {
            context.add(message: AIEMessage(type: .error, message: "The loss layer should have no children, and they will not be visited.", on: self))
        }

        // Work out the Loss function
        // Note: This will always generate code, so ignore.
        var lossName : String? = nil
        if let loss = loss as? AIETensorFlowLossCodeWriter {
            try context.writeIndented("\(loss.variableName) = ")
            _ = try loss.generateLossCode(context: context)
            try context.write("\n")
            lossName = loss.variableName
        } else {
            context.add(message: AIEMessage(type: .error, message: "\(type(of:loss)) does not support code generation for TensorFlow.", on: self))
        }

        // Now workout the optimizer function
        var optimizerName : String? = nil
        if let optimizer = optimizer as? AIETensorFlowOptimizerCodeWriter {
            try context.writeIndented("\(optimizer.variableName) = ")
            _ = try optimizer.generateOptimizerCode(context: context)
            try context.write("\n")
            optimizerName = optimizer.variableName
        } else {
            context.add(message: AIEMessage(type: .error, message: "\(type(of:optimizer)) does not support code generation for TensorFlow.", on: self))
        }
        
        // Finally, write the compile line.
        try context.write("")
        try context.writeIndented("")
        try context.writeFunction(name: "model.compile") {
            try context.writeArgument(lossName != nil, "loss=\(lossName ?? "")")
            try context.writeArgument(optimizerName != nil, "optimizer=\(optimizerName ?? "")")
        }
        try context.write("\n")
        
        return true
    }
}
