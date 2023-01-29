
import Foundation

extension AIEFullyConnected : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendShapes(context: context)
        try context.output.indent(context.indent).write("\(variableName) = layers.Dense(\(outputFeatureChannels))")
        if let parent = context.parent {
            try context.output.write("(Flatten()(\(parent.variableName)))")
        }
        try context.output.write("\n")
        try progressToChild(context: context)
        
        return true
    }
}
