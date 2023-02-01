
import Foundation

extension AIEFullyConnected : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendStandardCode(context: context) {
            try context.write("[layers.Flatten(), layers.Dense(\(outputFeatureChannels))]")
        }
        try progressToChild(context: context)
        
        return true
    }
}
