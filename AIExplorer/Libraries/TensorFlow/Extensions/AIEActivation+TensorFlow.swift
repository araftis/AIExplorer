
import Foundation

extension AIEActivation : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendStandardCode(context: context) {
            if (type == .relu){
                try context.write("layers.Activation('relu')")
            } else if (type == .sigmoid){
                try context.write("layers.Activation('sigmoid')")
            } else {
                try context.write("layers.Activation('tanh')")
            }
        }
        try progressToChild(context: context)
        
        return true
    }
}
