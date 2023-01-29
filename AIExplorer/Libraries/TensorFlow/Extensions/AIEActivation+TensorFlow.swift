
import Foundation

extension AIEActivation : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendShapes(context: context)
        try context.output.indent(context.indent).write("\(variableName) = ")
        if (type == .relu){
            try context.output.write("layers.Activation('relu')")
        } else if (type == .sigmoid){
            try context.output.write("layers.Activation('sigmoid')")
        } else {
            try context.output.write("layers.Activation('tanh')")
        }
        try appendParent(context: context)
        try context.output.write("\n")

        try progressToChild(context: context)
        
        return true
    }
}
