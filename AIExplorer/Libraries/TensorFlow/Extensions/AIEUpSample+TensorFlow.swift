
import Foundation

extension AIEUpsample : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendShapes(context: context)
        try context.output.write("layers.Conv2DTranspose(\(depth), (\(height), \(width)), \(step))")
        
        context.add(message: AIEMessage(type: .warning, message: "AIEUpsample does not yet generate correct code for TensorFlow", on: self))
        
        return true
    }
}
