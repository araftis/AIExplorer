
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
        _ = try loss.generateLossCode(context: context)
        let lossName = loss.variableName
        
        // Now workout the optimizer function
        var optimizerName : String? = nil
        if let optimizer = optimizer as? AIETensorFlowOptimizerCodeWriter {
            _ = try optimizer.generateOptimizerCode(context: context)
            optimizerName = optimizer.variableName
        } else {
            context.add(message: AIEMessage(type: .error, message: "\(type(of:self)) does not support code generation for TensorFlow.", on: self))
        }
        
        // Finally, write the compile line.
        try context.write("\n")
        try context.writeIndented("model.compile(")
        try context.write("loss=\(lossName)")
        if let optimizerName {
            try context.write(", optimizer=\(optimizerName)")
        }
        try context.write(")\n")
        
        return true
//        //try outputStream.write("# Loss layer")
//
//        //would need to compile the model to add loss
//        try prePrint(to: outputStream)
//
//        var loss_s: String
//        if (self.loss_type == 0){
//            loss_s = "losses.BinaryCrossentropy(from_logits=True)"
//        }
//        else if (self.loss_type == 1){
//            loss_s = "losses.CategoricalCrossentropy(from_logits=False)"
//        }
//        else {
//            loss_s = "losses.MeanSquaredError()"
//        }
//
//
//        var optimizer : String
//
//        if (self.optimization_type == 0){
//            optimizer = "optimizers.SGD(learning_rate=\(self.learning_rate))"
//        }
//        else if (self.optimization_type == 1){
//            optimizer = "optimizers.Adam(learning_rate=\(self.learning_rate))"
//        }
//        else {
//            optimizer = "optimizers.RMSprop(learning_rate=\(self.learning_rate))"
//        }
//
//
//        try outputStream.write("model.compile(loss=\(loss_s), optimizer=\(optimizer))")
//
//        try outputStream.write("# Loss type number: \(self.loss_type)")
//        try postPrint(to: outputStream)
    }
}
