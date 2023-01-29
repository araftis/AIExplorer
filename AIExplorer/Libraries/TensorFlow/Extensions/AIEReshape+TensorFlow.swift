
import Foundation

extension AIEReshape : AIETensorFlowCodeWriter {
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendShapes(context: context)
        try context.output.write("layers.Flatten()")
        
        context.add(message: AIEMessage(type: .warning, message: "AIEReshape does not yet generate correct code for TensorFlow", on: self))
        
        return true
    }
}
