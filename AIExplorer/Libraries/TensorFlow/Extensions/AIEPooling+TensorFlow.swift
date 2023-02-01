
import Foundation

extension AIEPooling : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendStandardCode(context: context) {
            try context.write("layers.MaxPool2D((\(size.height), \(size.width)), \(stride.width))")
        }
        try progressToChild(context: context)
        
        return true
    }
}
