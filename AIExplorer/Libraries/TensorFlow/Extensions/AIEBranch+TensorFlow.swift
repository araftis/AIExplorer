
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
        for (index, link) in links.enumerated() {
            if let child = link.destination as? AIEGraphic {
                // We'll quietly ignore any exit links that aren't NN objects.
                context.push(self)
                if let child = child as? AIETensorFlowCodeWriter {
                    let condition = link.extendedProperties["condition"] as? AJREvaluation
                    if let condition {
                        if index == 0 {
                            try context.writeIndented("if \(condition):\n")
                        } else {
                            try context.write(" elif \(condition):\n")
                        }
                    } else {
                        try context.writeIndented("else:\n")
                    }
                    context.incrementIndent()
                    let generatedCode = try child.generateCode(context: context)
                    if  generatedCode {
                        context.generatedCode = true
                    } else {
                        try context.writeIndented("pass\n")
                    }
                    context.decrementIndent()
                } else {
                    context.add(message: AIEMessage(type: .error, message: "\(type(of: child)) does not support TensorFlow code generation.", on: child))
                }
                context.pop()
            }
        }
    }

}
