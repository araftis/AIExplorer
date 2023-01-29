
import Foundation

extension AIEDropout : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendShapes(context: context)
        try context.output.indent(context.indent).write("\(variableName) = layers.Dropout(rate=\(rate)")
        if seed != 0 {
            try context.output.write(", seed=\(seed)")
        }
        try context.output.write(")")
        try appendParent(context: context)
        try context.output.write("\n")
        try progressToChild(context: context)
        
        return true
    }
}
