//
//  AIETensorFlowCodeWriter.swift
//  AIExplorer
//
//  Created by AJ Raftis on 1/26/23.
//

import Draw

internal protocol AIETensorFlowCodeWriter : AIEMessageObject {

    @discardableResult
    func generateCode(context: AIETensorFlowContext) throws -> Bool
    /**
     Allows the object to generate code that appears in the init() method of the neural network generator class. Objects to not need to do this unless they need to include some sort of code, like creating an ivar in the NN class.
     
     If the receiver doesn't generate code, it should return `false`, otherwise `true`.
     
     There's a default implementation of this method that simply returns `false`.
     
     - parameter context: The generation context with the current state of generation.
     */
    @discardableResult
    func generateCreationInsideInit(context: AIETensorFlowContext) throws -> Bool
    
    func appendParent(context: AIETensorFlowContext) throws -> Void
    func progressToChild(context: AIETensorFlowContext) throws -> Void
    var destinationObjects : [AIEGraphic] { get }
    var variableName : String { get }
    var inputShape : [Int]? { get }
    var outputShape : [Int] { get }
    var kind : AIEGraphic.Kind { get }
    func validateSingleChild(context: AIETensorFlowContext) -> Void
    func appendShapes(context: AIETensorFlowContext) throws -> Void

    func appendStandardCode(context: AIETensorFlowContext, _ block: () throws -> Void) throws -> Void

}

extension AIETensorFlowCodeWriter {

    func generateCreationInsideInit(context: AIETensorFlowContext) throws -> Bool {
        return false
    }
    
    func appendParent(context: AIETensorFlowContext) throws -> Void {
        if let parent = context.parent {
            try context.write("\(parent.variableName))")
        }
    }

    func progressToChild(context: AIETensorFlowContext) throws -> Void {
        let children = destinationObjects

        if children.count == 0 {
            // We're done?
            return
        }

        validateSingleChild(context: context)

        if children.count == 1 {
            // We have one child, so let's do our thing.
            if let child = children.first as? AIETensorFlowCodeWriter {
                context.push(self)
                let generatedCode : Bool
                switch context.stage {
                case .initialization:
                    generatedCode = try child.generateCreationInsideInit(context: context)
                case .build:
                    generatedCode = try child.generateCode(context: context)
                }
                if generatedCode {
                    context.generatedCode = true
                }
                context.pop()
            } else if let child = children.first {
                context.add(message: AIEMessage(type: .error, message: "\(type(of: child)) does not support TensorFlow code generation.", on: child))
            }
        }
    }

    func validateSingleChild(context: AIETensorFlowContext) -> Void {
        if destinationObjects.count != 1 {
            context.add(message: AIEMessage(type:.warning, message: "The node \(type(of:self)) should only have one child.", on: self as? AIEGraphic))
        }
    }

    func appendShapes(context: AIETensorFlowContext) throws -> Void {
        if let inputShape {
            try context.output.indent(context.indent).write("# Input Shape: \(inputShape) -> \(outputShape)\n")
        }
    }

    func appendStandardCode(context: AIETensorFlowContext, _ block: () throws -> Void) throws -> Void {
        try self.appendShapes(context: context)
        try context.writeIndented("\(variableName) = ")
        try block()
        try context.write("\n")
        try context.writeIndented("model.add(\(variableName))\n")
    }
    
}

