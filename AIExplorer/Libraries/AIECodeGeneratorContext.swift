/*
 AIECodeGeneratorContext.swift
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

/**
 Provides a code generator context for tracking information about the code generation.
 
 This also provides a number of useful utilities for generating code. Generally speaking, you'll subclass this in your library and use it when doing your code generation.
 
 Generally speaking, you use the context by initializing one with the provided output stream, and then you make calls through it, rather than to the output stream itself. The context will then deal with things like progressing to through the neural network graph, allowing you to write out the generated code without having to working about things like indented or specific formatting issues nearly as much.
 */
@objcMembers
open class AIECodeGeneratorContext : NSObject {

    /**
     Describes what phase of code generation we're doing. Not all code generators will use all phases. For example, Swift and Python wouldn't need to do `interfaceHeader`.
     
     The stages can be executed in any order, and, in fact, the order will depend on what language is writing. Stages can also appear more than once.
     */
    public enum Stage {
        /// Writing the header at the top of the class's interface. In Obj-C and C++, this would be at the top of the `.h` file.
        case interfaceHeader
        /// Writing the file header at the top of the class's implementation.
        case implementationHeader
        /// We're writing the licenses used by the network. These may appear due to using things like predefined data sources.
        case licenses
        /// Writing the include/import statements for the class's interace. For C++ and Obj-C this would be in the `.h` file. There's not interface for Swift or Python, so this phase would be skipped.
        case interfaceIncludes
        /// Writing include/import statements as part of the class's implementation. For C++ this woudl be the `.cpp` file, for Obj-C, the `.m`, for Python the `.py`, and for Swift `.swift`.
        case implementationIncludes
        /// We're declaring any properties used by the neural network. These may not be necessary for all languages. Likewise, different languages might call this at different points during writing.
        case propertyDeclarations
        /// Writing arguments to the init method. This phase can happening when writing the interface, implementation, or even when calling the init method.
        case initArguments
        /// Writing the body of the init method.
        case initialization
        /// Writing method declarations for the methods. Not all languages will include this phase. Likewise, even if the method would be written in the `implementationMethods` stage, they don't all have to be written here.
        case interfaceMethods
        /// Writing the class's method as part of the implementation. As such, these will have the method declaration as well as the method body.
        case implementationMethods
        /// Writing the `build` method of the neural network. This is really the main workhorse, which is why it gets its own stage.
        case build
        
    }

    /// The current stage of generation. Setting this resets `generatedCode` to `false`.
    public var stage : Stage = .initialization
    /// Where the output is being generated. Note that this is a stack, because sometimes we'll generated to a substream, and if that substream generates code, when popping the stack, we'll append the output to the previous output stream.
    internal var outputStreams : [OutputStream]
    /// The current path to the neural network node being processed.
    internal var path : [AIECodeWriter]
    /// Messages that are generated during code writing. These should be appended to the document when complete.
    public var messages : [AIEMessage]
    /// The current indentation level of the output.
    public private(set) var indent : Int
    /// The size of the indent. By default this will be four.
    public var indentWidth : Int = 4
    /// If, when traversing the tree, we generate code, this will be set to `true`.
    public var generatedCode : Bool = false

    /**
     Initializes a new context with the given output stream and indent.
     
     - parameter outputStream Where output should be written. Note that output will mostly be done through the context, which nows how to properly format for the given language.
     - parameter indent The initial indent of the context.
     */
    init(outputStream: OutputStream, indent: Int = 0) {
        self.indent = indent
        self.outputStreams = [outputStream]
        self.path = [AIECodeWriter]()
        self.messages = [AIEMessage]()
    }
    
    // MARK: - Output
    
    /**
     Refers to the current output stream on the output stream stack.
     */
    var output : OutputStream {
        assert(outputStreams.count >= 1, "The code writer over popped the output stream, which is fatal.")
        return outputStreams.last!
    }
    
    /**
     Creates a temporary new output stream and pushes it on the output stack.
     
     This is potentially useful if you need to follow a path in the neural net, but you're not sure if it's going to generate any output. You can call this method, descend into the children, and if output is generated, you can then append it when popping the output. The new output stream will generate to memory. When popped, the its output, if any, will be appended to the previous output stream.
     
     - returns The created output stream. You can ignore this, as it can easily be accessed via `output`.
     */
    @discardableResult
    func pushOutput() -> OutputStream {
        let newOutput = OutputStream.toMemory()
        newOutput.open()
        outputStreams.append(newOutput)
        return newOutput
    }
    
    /**
     Pops the last output stream and returns its content as a String.
     
     - parameter append: If `true` then any generated content is appended to the output of the previous output stream.
     
     - returns The string generated from the output.
     */
    func popOutput(append: Bool = false) -> String {
        // This is an assert, because if this happens, somethings gone serious wrong, and we can't really continue.
        assert(outputStreams.count > 1, "There's only one remaining output stream, and you're trying to pop it, which is going to cause all kinds of havoc.")
        let outputStream = outputStreams.removeLast()
        guard let string = outputStream.dataAsString(using: .utf8) else {
            // Just a warning, because we might otherwise be able to get useful data down the line.
            AJRLog.warning("Output stream failed to produce a valid string. You should make sure that anything your code generator writes to the string should be encodable as UTF-8")
            return ""
        }
        
        if append {
            output.write(string: string)
        }
        
        return string
    }

    // MARK: - Stack

    /**
     Many of the stages work by recursing through the neural network node. When doing so, you should call this method when you progress to a new node. This allows the context to track the path of the we've taken to get to the current node, which is sometimes necessary to know.
     
     - parameter current The node we're going to start working on.
     */
    func pushNode(_ current: AIECodeWriter) -> Void {
        path.append(current)
    }
    
    /**
     When done with a node, we pop it. This returns the popped node. If there are no nodes to pop, this returns `nil`
     
     - returns The node popped, or `nil` if no nodes exist.
     */
    @discardableResult
    func popNode() -> AIECodeWriter? {
        let last = path.last
        path.removeLast()
        return last
    }

    /**
     Returns the current node, or `nil` if there is no current node.
     
     - returns The current node.
     */
    open var currentNode : AIECodeWriter? {
        return path.last
    }
    
    /**
     Returns the "parent" object on the current path.
     
     This reverse enumerates the current path and returns the first (last?) object that is of `kind` `.neuralNetwork`. Other types are ignored. This basically means that we'd skip something like `AIEBranch`, but return most other nodes.
     */
    open var parent : AIECodeWriter? {
        for (index, ancestor) in path.reversed().enumerated() {
            if index == path.count {
                // Skip the current object, since we want it's parent.
                continue
            }
            if ancestor.object.kind == .neuralNetwork {
                return ancestor
            }
        }
        return nil
    }
    
    // MARK: - Messages

    /**
     Appends some sort of message that needs to be presented to the user. The context gathers these up, and when you're done, you'll probably need to pass these along to some other object.
     */
    func add(message: AIEMessage) -> Void {
        messages.append(message)
    }
    
    // MARK: - Indentation

    /**
     Increments the indent level. You'll normally not call this method directly. Instead, you should call `indent()` instead, as it'll protect against the call to `incrementIndent()` and `decrementIndent()` remain balanced.
     */
    func incrementIndent() -> Void {
        indent += 1
    }

    /**
     Decrements the curent indent level. You'll normally not call this method directly. Instead, you should call `indent()` instead, as it'll protect against the call to `incrementIndent()` and `decrementIndent()` remain balanced.
     */
    func decrementIndent() -> Void {
        if indent > 0 {
            indent -= 1
        }
    }
    
    /**
     Increments the indent level, calls `indentedBlock` and then decrements the indent level. You'll use this method as you enter deeper levels of code, like when defining the method body or the block of an `if`/`else` statement.
     
     Here's a typical example:
     
     ```Swift
     try context.writeIndented("if someConditional {\n")
     try context.indent {
         try context.writeIndent("// Some indented code\n
     }
     try context.writeIndented("}\n")
     ```
     
     - parameter indentedBlock A block of code that writes more output. The output will be indented one level deeper.
     */
    func indent(_ indentedBlock: () throws -> Void) rethrows -> Void {
        incrementIndent()
        defer {
            decrementIndent()
        }
        try indentedBlock()
    }
    
    // MARK: - Writing Conveniences
    
    internal var nextWriteIndent = true
    
    /**
     Writes a string to the output. The string must be encodable to UTF-8.
     
     - parameter string The string to write.
     */
    internal func _write(_ string: String) throws -> Void {
        if nextWriteIndent {
            try output.writeIndent(indent, width: indentWidth)
        }
        try output.write(string)
        // So, the idea here is that if the line ends in a newline, then the next line is indented.
        nextWriteIndent = string.hasSuffix("\n")
    }
    
    /**
     Writes a string to the output, but first writes an indent. Currently all indents are written as spaces. You can change the width of the indent by setting `indentWidth`.
     
     - parameter string The string to write.
     */
    open func write(_ string: String) throws -> Void {
        var foundError : Error? = nil
        var lineIndex : Int = 0
        
        string.enumerateLines { line, stop in
            do {
                if lineIndex > 0 {
                    try self._write("\n")
                }
                try self._write(line)
            } catch {
                foundError = error
                stop = true
            }
            lineIndex += 1
        }
        if let foundError {
            throw foundError
        }
        if string.hasSuffix("\n") {
            try _write("\n")
        }
    }
    
    // MARK: - Writing Arguments and Functions
    
    /**
     Defines where the documentation for classes and methods are to appear.
     */
    public enum DocumentationPosition {
        /**
         The documentation appears before the declaration. This would be typical for C, C++, Obj-C, and Swift.
         */
        case beforeDeclaration
        /**
         The documenation appears after the declaration. This would be typical for Python.
         */
        case afterDeclaration
    }
    
    /**
     Defines the type of function we're writing.
     */
    public enum FunctionType {
        /// The function as it appears in the interface. For Obj-C and C++, this would be as it appears in the header file. For Swift and Python, this would be nothing.
        case interface
        /// The function as it appears in the implementation of the class.
        case implementation
        /// The function when being called.
        case call
    }

    public class FunctionContext {
        var argumentsWritten: Int

        var name: String
        var type: FunctionType
        var initialIndent: Bool
        var separateArgumentsWithNewlines: Bool
        var documentationPosition: DocumentationPosition
        var documentation: String?
        var returnType: String?
        
        init(name: String,
             type: FunctionType = .call,
             initialIndent: Bool = false,
             separateArgumentsWithNewlines: Bool = false,
             documentationPosition: DocumentationPosition = .beforeDeclaration,
             documentation: String? = nil,
             returnType: String? = nil) {
            self.argumentsWritten = 0
            self.name = name
            self.type = type
            self.initialIndent = initialIndent
            self.separateArgumentsWithNewlines = separateArgumentsWithNewlines
            self.documentationPosition = documentationPosition
            self.documentation = documentation
            self.returnType = returnType
        }
    }
    
    open var functionStack = [FunctionContext]()
    open var functionContext : FunctionContext {
        assert(functionStack.count != 0, "You attempted to access a function writing method without having started a function!")
        return functionStack.last!
    }
    
    func writingFunctionStart() throws -> Void {
        switch functionContext.type {
        case .interface:
            break
        case .implementation:
            try write("def \(functionContext.name)(")
        case .call:
            if functionContext.initialIndent {
                try write("\(functionContext.name)(")
            } else {
                try write("\(functionContext.name)(")
            }
        }
    }
    
    func writeFunctionDocumentation() throws -> Void {
        if let documentation = functionContext.documentation {
            try indent {
                try writeComment(documentation, type: .methodDocumentation)
            }
        }
    }
    
    func writeArgument(_ condition : @autoclosure () -> Bool, _ string: String, type: String? = nil) throws -> Void {
        if condition() {
            if functionContext.argumentsWritten > 0 {
                try write(", ")
            }
            if functionContext.separateArgumentsWithNewlines {
                try write("\n")
                try write("")
            }
            try write(string)
            functionContext.argumentsWritten += 1
        }
    }
    
    func writeArgument(_ string: String, type: String? = nil) throws -> Void {
        try writeArgument(true, string, type: type)
    }
    
    func writeFunctionArgumentsStop() throws -> Void {
        functionContext.argumentsWritten = 0
        try write(")")
        if functionContext.type == .implementation {
            try write(":\n")
        }
    }
    
    open var defaultDocumentationPosition : DocumentationPosition {
        return .beforeDeclaration
    }
    
    func writeFunction(name: String,
                       type: FunctionType = .call,
                       indented: Bool = false,
                       documentation: String? = nil,
                       documentationPosition: DocumentationPosition? = nil,
                       argumentsIndented: Bool = false,
                       arguments block : () throws -> Void,
                       returnType: String? = nil,
                       body: (() throws -> Void)? = nil) throws -> Void {
        do {
            let functionContext = FunctionContext(name: name,
                                                  type: type,
                                                  initialIndent: indented,
                                                  separateArgumentsWithNewlines: argumentsIndented,
                                                  documentationPosition: documentationPosition ?? defaultDocumentationPosition,
                                                  documentation: documentation,
                                                  returnType: returnType)
            functionStack.append(functionContext)
            if functionContext.documentationPosition == .beforeDeclaration {
                try writeFunctionDocumentation()
            }
            try writingFunctionStart()
            if functionContext.separateArgumentsWithNewlines {
                incrementIndent()
            }
            try block()
            if functionContext.separateArgumentsWithNewlines {
                try write("\n")
                decrementIndent()
                try write("")
            }
            try writeFunctionArgumentsStop()
            if let body {
                if functionContext.documentationPosition == .afterDeclaration {
                    try writeFunctionDocumentation()
                }
                try indent {
                    try body()
                }
            }
        } catch {
            functionStack.removeLast()
            throw error
        }
    }

    // MARK: - Writing Comments

    public enum CommentType {
        /// The comment found at the top of a document.
        case header
        /// The comment found at before a class declaration
        case classDocumentation
        /// The documenation comment for a method.
        case methodDocumentation
        /// A single line comment. These may be multiline, but should wrap using the single line format.
        case singleLine
        /// A multiilne comment.
        case multiline
    }
    
    func writeComment(_ comment: String, type: CommentType = .singleLine) throws -> Void {
        switch type {
        case .header:
            break
        case .classDocumentation:
            break
        case .methodDocumentation:
            try write("\"\"\"\n")
            let prefix = String(indent: indent)
            let wrapped = comment.byWrapping(to: 80 - prefix.count, prefix: prefix, lineSeparator: "\n")
            try output.write(wrapped)
            try write("\n\"\"\"\n\n")
        case .singleLine:
            let prefix = String(indent: indent) + "# "
            let wrapped = comment.byWrapping(to: 80 - prefix.count, prefix: prefix, lineSeparator: "\n")
            try output.write(wrapped)
        case .multiline:
            try write("\"\"\"\n")
            let prefix = String(indent: indent)
            let wrapped = comment.byWrapping(to: 80 - prefix.count, prefix: prefix, lineSeparator: "\n")
            try output.write(wrapped)
            try write("\n\"\"\"\n")
        }
    }

    // MARK: - Type Casting
    
    open func codeWriter(for object: Any?) -> AIECodeWriter? {
        if let object = object as? AIEWritableObject {
            return AIECodeWriter(object: object)
        }
        return nil
    }
    
    @discardableResult
    open func generateCode(for object: Any?, in stage: Stage) throws -> Bool {
        self.stage = stage
        return try codeWriter(for: object)?.generateCode(in: self) ?? false
    }
    
    open func license(for object: Any?) -> String? {
        return codeWriter(for: object)?.license(context: self)
    }
    
    open func imports(for object: Any?) -> [String] {
        return codeWriter(for: object)?.imports(context: self) ?? []
    }
    
}
