
import Foundation

extension AIEReshape : AIETensorFlowCodeWriter {
    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try self.appendStandardCode(context: context) {
            try context.output.write("layers.Flatten(name='\(variableName)')")
        }
        try progressToChild(context: context)

        return true
    }
}
