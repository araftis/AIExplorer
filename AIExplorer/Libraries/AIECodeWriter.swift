//
//  AIECodeWriter.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/2/23.
//

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
    
    open var object : AIEWritableObject
    
    public init(object: AIEWritableObject) {
        self.object = object
    }
    
    @discardableResult
    func generateCode(in context: AIECodeGeneratorContext) throws -> Bool {
        var generatedCode : Bool = false
        
        switch context.stage {
        case .interfaceHeader:
            generatedCode = try generateInterfaceHeaderCode(in: context)
        case .implementationHeader:
            generatedCode = try generateImplementatinoHeaderCode(in: context)
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
            generatedCode = try generateInitArguments(context: context)
        case .initialization:
            generatedCode = try generateInitializationCode(context: context)
        case .implementationMethods:
            generatedCode = try generateImplementationMethodsCode(in: context)
        case .build:
            generatedCode = try generateBuildCode(in: context)
        }
        
        return generatedCode
    }
    
    @discardableResult
    open func generateBuildCode(in context: AIECodeGeneratorContext) throws -> Bool {
        context.add(message: AIEMessage(type: .error, message: "\(type(of:object)) does not yet support code writing for \(context.library?.name ?? "Unknown").", on: object))
        try progressToChild(context: context)
        return context.generatedCode
    }

    @discardableResult
    open func generateInterfaceHeaderCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(context: context)
        return context.generatedCode
    }
    
    @discardableResult
    open func generateImplementatinoHeaderCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(context: context)
        return context.generatedCode
    }
    
    @discardableResult
    open func generateLicenseCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(context: context)
        return context.generatedCode
    }
    
    @discardableResult
    open func generateInterfaceIncludeCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(context: context)
        return context.generatedCode
    }
    
    @discardableResult
    open func generateInterfaceMethodDeclarationCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(context: context)
        return context.generatedCode
    }
    
    @discardableResult
    open func generatePropertyDeclarationCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(context: context)
        return context.generatedCode
    }
    
    @discardableResult
    open func generateImplementationIncludeCode(in context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(context: context)
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
    func generateInitializationCode(context: AIECodeGeneratorContext) throws -> Bool {
        try progressToChild(context: context)
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
    func generateInitArguments(context: AIECodeGeneratorContext) throws -> Bool {
        return try progressToChild(context: context)
    }
    
    /**
     Allows the node to generate additional methods on the NN class.
     
     This method is useful if you're node type needs to generate additional methods. For example, if we hit an input node, and it has a data source, then we could generate code to create and load the dataSource object.

     - parameter context: The context we're writing into.
     
     - returns If you actually write any code, you should return `true`.
     */
    @discardableResult
    func generateImplementationMethodsCode(in context: AIECodeGeneratorContext) throws -> Bool {
        return try progressToChild(context: context)
    }
    
    /**
     If something in your node has a special license, this allows you to return it.
     */
    func license(context: AIECodeGeneratorContext) -> String? {
        return nil
    }

    /**
     Returns a list of required imports.

     Note that we'll have a general set already imported, but in case you need to import more, you can return them here. The set will be uniqued, so import statements will only happen once.
     */
    func imports(context: AIECodeGeneratorContext) -> [String] {
        return []
    }

    @discardableResult
    func progressToChild(context: AIECodeGeneratorContext) throws -> Bool {
        var generatedCode = false
        let children = object.destinationObjects

        if children.count == 0 {
            // We're done?
            return context.generatedCode
        }

        validateSingleChild(context: context)

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
    
    func validateSingleChild(context: AIECodeGeneratorContext) -> Void {
        if object.destinationObjects.count != 1 {
            context.add(message: AIEMessage(type:.warning, message: "The node \(type(of:self)) should only have one child.", on: object))
        }
    }
    
    func appendShapes(context: AIECodeGeneratorContext) throws -> Void {
        if let inputShape = object.inputShape {
            try context.output.indent(context.indent).write("# Input Shape: \(inputShape) -> \(object.outputShape)\n")
        }
    }

    func appendStandardCode(context: AIECodeGeneratorContext, _ block: () throws -> Void) throws -> Void {
        try self.appendShapes(context: context)
        try context.write("\(object.variableName) = ")
        try block()
        try context.write("\n")
        try context.write("model.add(\(object.variableName))\n")
    }

}

open class AIETypedCodeWriter<T: AIEWritableObject> : AIECodeWriter {

    open var node: T {
        get {
            return object as! T
        }
        set {
            object = newValue
        }
    }
    
}
