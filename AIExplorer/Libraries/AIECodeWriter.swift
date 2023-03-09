/*
 AIECodeWriter.swift
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

import Foundation

@objc
public protocol AIEWritableObject : AIEMessageObject {

    var kind : AIEGraphic.Kind { get }
    var destinationObjects : [AIEGraphic] { get }
    var variableName : String { get }
    var inputShape : [Int]? { get }
    var outputShape : [Int] { get }
    
}

extension AIEGraphic : AIEWritableObject {
}

@objcMembers
open class AIECodeWriter : NSObject {

    /// The object being written.
    open var object : AIEWritableObject

    /// Create a new code writer for `object`.
    public init(object: AIEWritableObject) {
        self.object = object
    }

    /**
    This method is simply a dispatch method which will call the appropriate generate method based on the context's stage.

     - parameter context The code generation context.

     - returns `true` if code is written.
     */
    @discardableResult
    open func generateCode(in context: AIECodeGeneratorContext) throws -> Bool {
        var generatedCode : Bool = false
        
        switch context.stage {
        case .interfaceHeader:
            generatedCode = try generateInterfaceHeaderCode(in: context)
        case .implementationHeader:
            generatedCode = try generateImplementationHeaderCode(in: context)
        case .licenses:
            generatedCode = try generateLicenseCode(in: context)
        case .interfaceIncludes:
            generatedCode = try generateInterfaceIncludeCode(in: context)
        case .interfaceMethods:
            generatedCode = try generateInterfaceMethodDeclarationCode(in: context)
        case .propertyDeclarations:
            generatedCode = try generatePropertyDeclarationCode(in: context)
        case .implementationIncludes:
            generatedCode = try generateImplementationIncludeCode(in: context)
        case .initArguments:
            generatedCode = try generateInitArguments(in: context)
        case .initialization:
            generatedCode = try generateInitializationCode(in: context)
        case .implementationMethods:
            generatedCode = try generateImplementationMethodsCode(in: context)
        case .build:
            generatedCode = try generateBuildCode(in: context)
        }
        
        return generatedCode
    }

    /**
     This method generates code for build the actual neural network model.

     The is by far the most important method. All the other methods are just for supporting this method. In fact, many libraries may not even need to override anything else What you write will be heavily dependent on what library you're supporting.

     - parameter context The code generation context.

     - returns `true` if code is written.
     */
    @discardableResult
    open func generateBuildCode(in context: AIECodeGeneratorContext) throws -> Bool {
        context.add(message: AIEMessage(type: .error, message: "\(type(of:object)) does not yet support code writing for \(context.library?.name ?? "Unknown").", on: object))
        try progressToChild(in: context)
        return context.generatedCode
    }

    /**
     Generates code that will appear in the file's interface header, which is the comment block at the top of the interface file. Note that many languages do not have an interface file, in which case this method is likely to do nothing.

     - parameter context The code generation context.

     - returns `true` if code is written.
     */
    @discardableResult
    open func generateInterfaceHeaderCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(in: context)
        return context.generatedCode
    }

    /**
     Generates code that appears at the top of the implementation file, in the introductory comment block.

     - parameter context The code generation context.

     - returns `true` if code is written.
     */
    @discardableResult
    open func generateImplementationHeaderCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(in: context)
        return context.generatedCode
    }

    /**
     Generates a license for the node.

     Most nodes don't have a license, but some may. For example, the I/O nodes might have a license depending on the data source being used.

     - parameter context The code generation context.

     - returns `true` if code is written.
     */
    @discardableResult
    open func generateLicenseCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(in: context)
        return context.generatedCode
    }

    /**
     Generates "import" statements used by the library.

     Default import statements will already be written, but you object might need to do something specific or special. For example, you migth need make sure you import image handling libraries.

     - parameter context The code generation context.

     - returns `true` if code is written.
     */
    @discardableResult
    open func generateInterfaceIncludeCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(in: context)
        return context.generatedCode
    }

    /**
     Generates code that declare method interfaces.

     Not all languages require this method, like Python or Swift, but other languages do, like C++ or Obj-C. This is called while a class interface is being generated.

     - parameter context The code generation context.

     - returns `true` if code is written.
     */
    @discardableResult
    open func generateInterfaceMethodDeclarationCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(in: context)
        return context.generatedCode
    }

    /**
     Generates property declarations.

     These are often the instance variables of your class. This code can be called at different points. For example, Python and Swift will call this while generating the implementation, since they have to interface. On the other hand, Obj-C and C++ will call this during the generation of the class interface.

     - parameter context The code generation context.

     - returns `true` if code is written.
     */
    @discardableResult
    open func generatePropertyDeclarationCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(in: context)
        return context.generatedCode
    }

    /**
     This works like the interface method, but generates imports for the implementation.

     - parameter context The code generation context.

     - returns `true` if code is written.
     */
    @discardableResult
    open func generateImplementationIncludeCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(in: context)
        return context.generatedCode
    }
    

    /**
     Allows the object to generate code that appears in the init() method of the neural network generator class. Objects to not need to do this unless they need to include some sort of code, like creating an ivar in the NN class.
     
     If the receiver doesn't generate code, it should return `false`, otherwise `true`.
     
     There is a default implementation of this function that always returns `false`, so you only need to implement this if you plan to actually do something.

     - parameter context: The generation context with the current state of generation.
     
     - returns If you write any code, you should return `true`.
     */
    @discardableResult
    open func generateInitializationCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(in: context)
        return context.generatedCode
    }

    /**
     When called, the context will be writing a function, so this allows you to add an argument to the init() method.
     
     Note that the context will be in the code for generating a function call, so the only valid call you can make on the context is `writeArgument()`.
     
     There is a default implementation of this function that always returns `false`, so you only need to implement this if you plan to actually do something.
     
     - parameter context: The context we're writing into.
     
     - returns If you actually write any code, you should return `true`.
     */
    @discardableResult
    open func generateInitArguments(in context: AIECodeGeneratorContext) throws -> Bool {
        return try progressToChild(in: context)
    }
    
    /**
     Allows the node to generate additional methods on the NN class.
     
     This method is useful if you're node type needs to generate additional methods. For example, if we hit an input node, and it has a data source, then we could generate code to create and load the dataSource object.

     - parameter context: The context we're writing into.
     
     - returns If you actually write any code, you should return `true`.
     */
    @discardableResult
    open func generateImplementationMethodsCode(in context: AIECodeGeneratorContext) throws -> Bool {
        return try progressToChild(in: context)
    }
    
    /**
     Progressing to the next node in the graph.

     This is generally called at the end of the various "generate" methods. For the vast majority of nodes, which can only have a single child, this method moves to that child. However, some number of nodes may actually have multiple children. When this happens, special care must be taken. In those cases, you'll need to override this method in order to decide how to proceed, which code be visit no children, some children, or all children.

     - parameter context The code generation context.

     - returns `true` if code is written.
     */
    @discardableResult
    open func progressToChild(in context: AIECodeGeneratorContext) throws -> Bool {
        var generatedCode = false
        let children = object.destinationObjects

        if children.count == 0 {
            // We're done?
            return context.generatedCode
        }

        validateSingleChild(in:context)

        if children.count == 1 {
            // We have one child, so let's do our thing.
            if let child = children.first {
                context.pushNode(self)
                if let writer = context.codeWriter(for: child) {
                    generatedCode = try writer.generateCode(in: context)
                    if generatedCode {
                        context.generatedCode = true
                    }
                }
                context.popNode()
            }
        }
        
        return generatedCode
    }

    /**
     Simply checks to see if `object` has more than one child, and if it does, this generates a warning.
     */
    open func validateSingleChild(in context: AIECodeGeneratorContext) -> Void {
        if object.destinationObjects.count != 1 {
            context.add(message: AIEMessage(type:.warning, message: "The node \(type(of:self)) should only have one child.", on: object))
        }
    }
    
    open func appendShapes(in context: AIECodeGeneratorContext) throws -> Void {
        if let inputShape = object.inputShape {
            try context.writeComment("Shape: \(inputShape) -> \(object.outputShape)")
        }
    }

    open func appendStandardCode(in context: AIECodeGeneratorContext, _ block: () throws -> Void) throws -> Void {
        try self.appendShapes(in: context)
        try context.write("\(object.variableName) = ")
        try block()
        try context.write("\n")
        try context.writeFunction(name: "add", type: .call, receiver: "model") {
            try context.writeArgument(value: object.variableName)
        }
    }

}

/**
 This is a simple subclass that adds one property to type `object`. This is useful, because it allows you to avoid having to write a bunch of type casting code in your own code writers.
 */
open class AIETypedCodeWriter<T: AIEWritableObject> : AIECodeWriter {

    /**
     This is a simply a re-casting of `object` as `T`. Note that if `object` isn't a kind of `T`, this method will crash.
     */
    open var node: T {
        get {
            assert(object is T, "object is not of the expected type.")
            return object as! T
        }
        set {
            object = newValue
        }
    }
    
}
