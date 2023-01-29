
import Foundation

extension AIEPooling : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendShapes(context: context)
        try context.output.indent(context.indent).write("\(variableName) = layers.MaxPool2D((\(size.height), \(size.width)), \(stride.width))")
        try appendParent(context: context)
        try context.output.write("\n")
        try progressToChild(context: context)
        
        return true
    }
}
