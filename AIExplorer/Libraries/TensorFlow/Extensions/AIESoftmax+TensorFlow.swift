
import Foundation

extension AIESoftmax : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        if let inputShape = inputShape {
            if inputShape.count > 2 {
                context.add(message: AIEMessage(type: .error, message: "The input shape \(inputShape) to the soft max layer has too many dimension. It should have just two, [<batch_size>, <dimension>].", on: self))
            }
            try appendStandardCode(context: context) {
                try context.write("layers.Softmax()")
            }
            try progressToChild(context: context)
        }

        return true
    }
}
