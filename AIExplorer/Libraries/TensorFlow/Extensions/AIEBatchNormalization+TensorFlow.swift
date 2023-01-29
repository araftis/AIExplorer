
import Foundation

extension AIEBatchNormalization : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendShapes(context: context)
        try context.output.write("layers.BatchNormalization(momentum = \(self.momentum), epsilon = \(self.epsilon))")
        
        context.add(message: AIEMessage(type: .warning, message: "AIEBatchNormalization does not yet generate correct code for TensorFlow", on: self))
        
        return true
    }
}
