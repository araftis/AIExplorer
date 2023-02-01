
import Foundation

extension AIEDropout : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendStandardCode(context: context) {
            try context.write("layers.Dropout(rate=\(rate)")
            if seed != 0 {
                try context.output.write(", seed=\(seed)")
            }
            try context.output.write(")")
        }
        try progressToChild(context: context)
        
        return true
    }
}
