
import Foundation

extension AIEActivation : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendStandardCode(context: context) {
            try context.write("layers.Activation(")
            if (type == .relu) {
                try context.write("'relu'")
            } else if (type == .sigmoid){
                try context.write("'sigmoid'")
            } else {
                try context.write("'tanh'")
            }
            try context.write(", name='\(variableName)')")
        }
        try progressToChild(context: context)
        
        return true
    }
}
