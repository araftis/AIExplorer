
import Foundation

extension AIEFullyConnected : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendStandardCode(context: context) {
            try context.write("models.Sequential([layers.Flatten(), layers.Dense(\(outputFeatureChannels))], name='\(variableName)')")
        }
        try progressToChild(context: context)
        
        return true
    }
}
