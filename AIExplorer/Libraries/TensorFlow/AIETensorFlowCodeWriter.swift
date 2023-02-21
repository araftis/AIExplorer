/*
 AIETensorFlowCodeWriter.swift
 AIExplorer

 Copyright © 2023, AJ Raftis and AIExplorer authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this 
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the documentation 
   and/or other materials provided with the distribution.
 * Neither the name of AIExplorer nor the names of its contributors may be 
   used to endorse or promote products derived from this software without 
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Draw

internal protocol AIETensorFlowCodeWriter : AIEMessageObject {

    @discardableResult
    func generateCode(context: AIETensorFlowContext) throws -> Bool
    /**
     Allows the object to generate code that appears in the init() method of the neural network generator class. Objects to not need to do this unless they need to include some sort of code, like creating an ivar in the NN class.
     
     If the receiver doesn't generate code, it should return `false`, otherwise `true`.
     
     There is a default implementation of this function that always returns `false`, so you only need to implement this if you plan to actually do something.

     - parameter context: The generation context with the current state of generation.
     
     - returns If you write any code, you should return `true`.
     */
    @discardableResult
    func generateInitializationCode(context: AIETensorFlowContext) throws -> Bool

    /**
     When called, the context will be writing a function, so this allows you to add an argument to the init() method.
     
     Note that the context will be in the code for generating a function call, so the only valid call you can make on the context is `writeArgument()`.
     
     There is a default implementation of this function that always returns `false`, so you only need to implement this if you plan to actually do something.
     
     - parameter context: The context we're writing into.
     
     - returns If you actually write any code, you should return `true`.
     */
    @discardableResult
    func generateInitArguments(context: AIETensorFlowContext) throws -> Bool
    
    /**
     Allows the node to generate additional methods on the NN class.
     
     This method is useful if you're node type needs to generate additional methods. For example, if we hit an input node, and it has a data source, then we could generate code to create and load the dataSource object.

     - parameter context: The context we're writing into.
     
     - returns If you actually write any code, you should return `true`.
     */
    @discardableResult
    func generateMethodsCode(context: AIETensorFlowContext) throws -> Bool
    
    /**
     If something in your node has a special license, this allows you to return it.
     */
    var license : String? { get }

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
    
    func generateInitializationCode(context: AIETensorFlowContext) throws -> Bool {
        try progressToChild(context: context)
        return context.generatedCode
    }
    
    func generateInitArguments(context: AIETensorFlowContext) throws -> Bool {
        try progressToChild(context: context)
        return context.generatedCode
    }
    
    func generateMethodsCode(context: AIETensorFlowContext) throws -> Bool {
        try progressToChild(context: context)
        return context.generatedCode
    }
    
    var license : String? { return nil }
    
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
                case .header:
                    generatedCode = false
                case .licenses:
                    generatedCode = false
                case .imports:
                    generatedCode = false
                case .initArguments:
                    generatedCode = try child.generateInitArguments(context: context)
                case .initialization:
                    generatedCode = try child.generateInitializationCode(context: context)
                case .methods:
                    generatedCode = try child.generateMethodsCode(context: context)
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

