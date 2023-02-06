
import Foundation

extension AIELSTM : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendShapes(context: context)
        try context.output.write("layers.LTSM(units = \(self.units), name='\(variableName)')")
        
        context.add(message: AIEMessage(type: .warning, message: "AIELSTM does not yet generate correct code for TensorFlow", on: self))
        
        return true
    }
}
