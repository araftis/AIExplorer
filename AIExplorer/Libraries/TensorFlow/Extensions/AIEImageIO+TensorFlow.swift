
import Foundation

extension AIEImageIO : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        if batchSize <= 0 {
            context.add(message: AIEMessage(type: .warning, message: "The input node should define a batch size.", on: self))
        }
        if let inputShape {
            try context.output.indent(context.indent).write("# Input Shape: \(inputShape)\n")
        }
        try context.output.indent(2).write("\(variableName) = layers.Input(shape=(\(height), \(width), \(depth)), name='\(variableName)')\n")
        try context.writeIndented("model.add(\(variableName))\n")
        try progressToChild(context: context)
        
        return true
    }
}

