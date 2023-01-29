
import Foundation

import Draw

extension AIEBranch : AIETensorFlowCodeWriter {
    
    func generateCode(context: AIETensorFlowContext) throws -> Bool {
        let children = exitLinks
        
        // We need to take two approaches here depending on if we're generating code for the init or generation method.
        switch context.stage {
        case .initialization:
            try generateInitCode(for: children, context: context)
        case .build:
            try generateCode(for: children, context: context)
        }

        return true 
    }

    func generateInitCode(for links : [DrawLink], context: AIETensorFlowContext) throws -> Void {
        for link in links {
            if let child = link.destination as? AIEGraphic {
                context.push(self)
                if let child = child as? AIETensorFlowCodeWriter {
                    try child.generateCreationInsideInit(context: context)
                } else {
                    context.add(message: AIEMessage(type: .error, message: "\(type(of: child)) does not support TensorFlow code generation.", on: child))
                }
                context.pop()
            }
        }
    }
    
    func generateCode(for links : [DrawLink], context: AIETensorFlowContext) throws -> Void {
        for link in links {
            if let child = link.destination as? AIEGraphic {
                // We'll quietly ignore any exit links that aren't NN objects.
                context.push(self)
                context.incrementIndent()
                if let child = child as? AIETensorFlowCodeWriter {
                    let generatedCode : Bool
                    generatedCode = try child.generateCode(context: context)
                    if generatedCode {
                        context.generatedCode = true
                    }
                } else {
                    context.add(message: AIEMessage(type: .error, message: "\(type(of: child)) does not support TensorFlow code generation.", on: child))
                }
                context.decrementIndent()
                context.pop()
            }
        }
    }

}
