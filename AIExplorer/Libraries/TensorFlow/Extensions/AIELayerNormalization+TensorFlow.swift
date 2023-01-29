
import Foundation

extension AIELayerNormalization : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendShapes(context: context)
        try context.output.write("layers.LayerNormalization(epsilon = \(self.epsilon))")
        
        context.add(message: AIEMessage(type: .warning, message: "AIELayerNormalization does not yet generate correct code for TensorFlow", on: self))
        
        return true
    }
}
