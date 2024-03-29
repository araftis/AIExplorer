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

    public private(set) weak var library : AIELibrary? = nil
    public private(set) weak var codeGenerator : AIECodeGenerator? = nil
    /// The current stage of generation. Setting this resets `generatedCode` to `false`.
    public private(set) var stage : Stage = .initialization
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
    /// Some stages allow a "scope". This may be irrelevant in some languages, and can be ignored in those cases.
    public private(set) var scope : Scope = .public
    /// If, when traversing the tree, we generate code, this will be set to `true`.
    public var generatedCode : Bool = false

    /**
     Initializes a new context with the given output stream and indent.
     
     - parameter outputStream Where output should be written. Note that output will mostly be done through the context, which nows how to properly format for the given language.
     - parameter indent The initial indent of the context.
     */
    init(outputStream: OutputStream, library: AIELibrary?, codeGenerator: AIECodeGenerator, indent: Int = 0) {
        self.library = library
        self.codeGenerator = codeGenerator
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
    open func indent(_ indentedBlock: () throws -> Void) throws -> Void {
        incrementIndent()
        defer {
            decrementIndent()
        }
        try indentedBlock()
    }
    
    /**
     In the base class, this just calls `indent`, but subclasses can override to add additional ornimatation for blocks of code.
     
     For example, an Obj-C subclass might add the `{` and `}` about the block.
     */
    open func block(_ body: () throws -> Void) throws {
        try write(" BEGIN\n")
        try indent(body)
        try write("END\n")
    }

    // MARK: - Writing Conveniences
    
    internal var nextWriteIndent = true
    
    /**
     Writes a string to the output. The string must be encodable to UTF-8.
     
     This is basically private, because callers should use the public `write()` method.
     
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
     
     This method is actually somewhat more robust than it seems at first glance, as it does things like handles multiple lines in a one string. It works by enumerating lines in the string. For each line, it indents the output and then writes the line. The method does not currently deal with line wrapping, although that's a possibility in the future.
     
     - parameter string The string to write. The string my be multi-line.
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

    // MARK: - Write Headers

    open func writeFileHeader(for stage: Stage, info: [String:Any], _ body: (() throws -> Void)? = nil) throws -> Void {
        // Start
        begin(stage: stage)

        // Just writes a standard header
        try writeComment("")
        if let fileExtension = info[.extension] {
            try writeComment("\(info[.codeName] ?? "Anonymous").\(fileExtension)")
        } else {
            try writeComment("\(info[.codeName] ?? "Anonymous")")
        }
        try writeComment("")
        try writeComment("Created by \(NSFullUserName()) on \(AIECodeGenerator.simpleDateFormatter.string(from:Date()))")
        try writeComment("Copyright © \(AIECodeGenerator.yearDateFormatter.string(from:Date())), All rights reserved.")
        try writeComment("")

        // Handle Licenses
        try codeGenerator?.iterateRoots { root in
            try generateCode(for: root, in: .licenses)
        }
        try write("\n")

        // This is changed by generating the licenses. I'm thinking I should change the stage to a stack, but I don't want to do that just yet.
        self.stage = stage
        if let body {
            try body()
        }
    }

    // MARK: - Writing Imports

    open func writeImport(_ importStatement: String) throws -> Void {
        try write("\(importStatement)\n")
        generatedCode = true
    }

    @discardableResult
    open func writeImports(for stage: Stage, _ statements: () throws -> Void) throws -> Bool {
        // Start the stage
        begin(stage:stage)
        // Push a new output stream
        pushOutput()
        // Call to allow the caller to add any imports.
        try statements()
        // Let any parts of the neural graph include additional imports.
        try codeGenerator?.iterateRoots { root in
            try generateCode(for: root, in: .implementationIncludes)
        }
        // Pop the output and get all the import statement lines.
        let string = popOutput()
        // Unique the lines written, since we only need to import once.
        var imports = OrderedSet<String>()
        string.enumerateLines { line, stop in
            imports.append(line)
        }
        // Now that we've uniques the lines, let's append them.
        for line in imports {
            try write("\(line)\n")
        }

        return string.count > 0
    }

    // MARK: - Writing Licenses

    open func writeLicense(_ license: String, prefix: String = "# ") throws -> Void {
        try write(license.byWrapping(to: 75, prefix: prefix, lineSeparator: "\n", splitURLs: false))
        try write("\n")
        generatedCode = true
    }

    // MARK: - Writing Arguments and Functions

    open var defaultFunctionProtocolTerminal : String { return "\n" }
    open var defaultFunctionImplementationTerminal : String { return "\n" }
    open var defaultFunctionCallTerminal : String { return "\n" }
    
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
        case prototype
        /// The function as it appears in the implementation of the class.
        case implementation
        /// The function when being called.
        case call
    }

    /**
     Defines a context for the function we're writing.
     
     This basically captures the paremeters to the `writeFunction()` method, since writing functions can be nested. In otherwords, things about writing a function with its body. The function may obviously call other functions, so you'd be re-entering into the code. As such, we want to track the state of the function accross calls to multiple other method calls.
     */
    public class FunctionContext {
        var argumentsWritten: Int

        var name: String
        var type: FunctionType
        var receiver: String?
        var separateArgumentsWithNewlines: Bool
        var documentation: String?
        var returnType: String?
        
        init(name: String,
             type: FunctionType = .call,
             receiver: String? = nil,
             separateArgumentsWithNewlines: Bool = false,
             documentation: String? = nil,
             returnType: String? = nil) {
            self.argumentsWritten = 0
            self.name = name
            self.type = type
            self.receiver = receiver
            self.separateArgumentsWithNewlines = separateArgumentsWithNewlines
            self.documentation = documentation
            self.returnType = returnType
        }
    }
    
    /// Tracks the current stack of function calls.
    internal var functionStack = [FunctionContext]()
    
    /// Returns the current function context.
    open var functionContext : FunctionContext {
        assert(functionStack.count != 0, "You attempted to access a function writing method without having started a function!")
        return functionStack.last!
    }

    /**
     Writes the start of the function.
     
     This does multiple things based on the `type` of the function. You implementation should be able to write out whatever is appropriate for the type. For example, here's what code generation for Python might look like:
     
     ```Swift
     switch functionContext.type {
     case .interface:
         break
     case .implementation:
         try write("def \(functionContext.name)(")
     case .call:
         try write("\(functionContext.name)(")
     }
     ```
     */
    open func writingFunctionStart() throws -> Void {
        switch functionContext.type {
        case .prototype:
            break
        case .implementation:
            try write("FUNCTION \(functionContext.name)(")
        case .call:
            try write("\(functionContext.name)(")
        }
    }
    
    /**
     Writes the function's documentation, as appropriate for the given language.
     */
    open func writeFunctionDocumentation() throws -> Void {
        if let documentation = functionContext.documentation {
            try writeComment(documentation, type: .methodDocumentation)
        }
    }
    
    /**
     Writes an argument of the function.
     
     This method is slightly complex. It basically does the following:
     
     1. Evaluate `condition`, and if `true`, then we'll write the argument.
         1. If `functionContext.argumentsWritten` is non-zero, then write an appropriate argument separator.
         2. If `name` and `value` are both not `nil`, then write them. Something like `name=value`.
         3. If `name` is not `nil` and `value` is `nil`, then write name.
         4. If `name` is `nil`, and `value` is not `nil`, then write value.
         5. Increment `functionContext.argumentsWritten`.
     
     The parameters may have different meanings depending on the function call type.
     
     For `interface` and `implementation` the most important parameter is `name`, as that must always be provided. For some languages, `type` may also be recorded. Likewise, for some languages, a default value can be provided for a function's argument. If that's the case, this should be passed in `value`.
     
     For `call`, the value parameter is the most important. However, some languages support "named" parameters, in which case you may also provide `name`.
     
     - parameter condition An autoclosure that is evalutate to determine if the argument should be written. For example, the library may have a default parameter for an argument. If the current value is equal to the default value, the we don't want to write argument.
     - parameter name The name of the parameter. In the case of a declaration, this is just the name. If `name` and `value` are provided for a declaration, then a "default" value is provided using `value`.
     - parameter value The value of the parameter. In the case of a call, this is just the value.
     - parameter type The type of the parameter. This may be `nil` if the language doesn't support parameters.
     */
    open func writeArgument(_ condition : @autoclosure () -> Bool, name: String? = nil, value: CustomStringConvertible? = nil, type: String? = nil) throws -> Void {
        if condition() {
            if functionContext.argumentsWritten > 0 {
                try write(", ")
            }
            if functionContext.separateArgumentsWithNewlines {
                try write("\n")
            }
            if let name, let value {
                try write(name)
                try write("=")
                try write(value.description)
            } else if let name {
                try write(name)
            } else if let value {
                try write(value.description)
            }
            functionContext.argumentsWritten += 1
        }
    }
    
    /**
     Just calls `writeArgument(_:name:value:type:)` where `condition` is always `true`.
     */
    open func writeArgument(name: String? = nil, value: CustomStringConvertible? = nil, type: String? = nil) throws -> Void {
        try writeArgument(true, name: name, value: value, type: type)
    }
    
    /**
     Terminates the function call. For `call`, this should just close the function call, but not include a newline. For the others, this will likely include a newline.
     */
    open func writeFunctionArgumentsStop() throws -> Void {
        functionContext.argumentsWritten = 0
        try write(")")
    }
    
    /**
     The default position of documentation for the language. While overridable at the call site, that's usually not necessary, because languages tend to be self-consistent with this.
     */
    open var documentationPosition : DocumentationPosition {
        return .beforeDeclaration
    }
    
    /**
     Writes a function, as defined by `type`, which generally means a function prototype, implementation, or call. This method is useful when generating your code, as it will do a lot of repetitive work for you, and the while keeping things formatted correctly.
     
     You can generate code for three kinds of function, as defined by `type`:
     
     1. **prototype** The function prototype. Not all languages need this, like Swift or Python, but some do, like C++ and Obj-C. This should not include `body`. Other valid parameters are `documentation`, `documentationPosition`, `argumentsIndented`, `arguments`, and `returnType`.
     2. **implementation** The implementation of the function. When doing this, you should generally include a `body` as well. All parameters are value, although you don't necessarily need to provide documentation for the implementation, depending on language.
     3. **call** Use this when you're calling a function. This should not include `body`. On the `name`, `type`, and `arguments` parameters are valid.
     
     When you call this, a new `FunctionContext` is created and pushed on a stack. This allows you to call this method a second time from within the `body` code provided.
     
     - parameter name The name of the function. You can also think of this as the function's "prefix", so while "my_function" would be fine, so woudl "my_object.my_function".
     - parameter type The type of function call being made.
     - parameter documentation The documentation for the function. May not be necessary.
     - parameter documentationPosition The position of the documentation. This is generally defined by default via the `defaultDocumentationPosition` property, so you'll rarely, if ever, need to provide this.
     - parameter argumentsIndented If `true`, each argument will be on a new line and indented. This can be useful for functions with a lot of parameters.
     - parameter arguments A block of code providing the arguments. The block should really only include calls to `writeArgument()` from within this block, although you could, in theory, also call back into `writeFunction()` to start an embedded function call.
     - parameter returnType The return type of the function. This may not be necessary, depending on the language.
     - parameter body A code block that writes the body of the function. This may certainly call back into `writeFunction()` to make additional function calls. You don't need to provide this parameter for `prototype` or `call` types. This is really just a short hand for calling `indent()` after writing the initial function declaration.
     */
    open func writeFunction(name: String,
                            type: FunctionType = .call,
                            returnType: String? = nil,
                            receiver: String? = nil,
                            documentation: String? = nil,
                            terminal: String? = nil,
                            argumentsIndented: Bool = false,
                            arguments argumentsBlock : () throws -> Void,
                            body: (() throws -> Void)? = nil) throws -> Void {
        do {
            let functionContext = FunctionContext(name: name,
                                                  type: type,
                                                  receiver: receiver,
                                                  separateArgumentsWithNewlines: argumentsIndented,
                                                  documentation: documentation,
                                                  returnType: returnType)
            functionStack.append(functionContext)
            if documentationPosition == .beforeDeclaration {
                try writeFunctionDocumentation()
            }
            try writingFunctionStart()
            if functionContext.separateArgumentsWithNewlines {
                incrementIndent()
            }
            try argumentsBlock()
            if functionContext.separateArgumentsWithNewlines {
                try write("\n")
                decrementIndent()
            }
            try writeFunctionArgumentsStop()
            if let body {
                try block {
                    if documentationPosition == .afterDeclaration {
                        try writeFunctionDocumentation()
                    }
                    try body()
                }
            }
            if let terminal {
                try write(terminal)
            } else {
                switch type {
                case .call: try write(defaultFunctionCallTerminal)
                case .prototype: try write(defaultFunctionProtocolTerminal)
                case .implementation: try write(defaultFunctionImplementationTerminal)
                }
            }
        } catch {
            functionStack.removeLast()
            throw error
        }
    }

    // MARK: - Writing Comments

    /**
     Defines the type of the comment, so that it can be written appropriately.
     */
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

    open var singleLineCommentStart : String {
        return "//"
    }

    open var multilineCommentStart : String {
        return "/*"
    }

    open var multilineCommentEnd : String {
        return "*/"
    }

    open var documentationCommentStart : String {
        return "/**"
    }

    open var documentationCommentEnd : String {
        return "*/"
    }

    /**
     Writes a comment.
     */
    open func writeComment(_ comment: String, type: CommentType = .singleLine) throws -> Void {
        switch type {
        case .header:
            break
        case .classDocumentation:
            break
        case .methodDocumentation:
            try write("\(documentationCommentStart)\n")
            let prefix = String(indent: indent)
            let wrapped = comment.byWrapping(to: 80 - prefix.count, prefix: prefix, lineSeparator: "\n")
            try output.write(wrapped)
            try write("\n\(documentationCommentEnd)\n")
        case .singleLine:
            if comment.isEmpty {
                try output.write("\(singleLineCommentStart)\n")
            } else {
                let prefix = String(indent: indent) + "\(singleLineCommentStart) "
                let wrapped = comment.byWrapping(to: 80 - prefix.count, prefix: prefix, lineSeparator: "\n")
                try output.write(wrapped)
                try output.write("\n")
            }
        case .multiline:
            try write("\(multilineCommentStart)\n")
            let prefix = String(indent: indent)
            let wrapped = comment.byWrapping(to: 80 - prefix.count, prefix: prefix, lineSeparator: "\n")
            try output.write(wrapped)
            try write("\n\(multilineCommentEnd)\n")
        }
    }

    // MARK: - Classes

    open var classPropertiesIndent : Bool { return false }
    open var classMethodsIndent : Bool { return false }

    open func writeClassInterfaceBegin(name: String,
                                       scope: Scope = .public,
                                       superclass: String? = nil,
                                       protocols: [String] = []) throws -> Void {
        try write("CLASS \(name)")
        if let superclass {
            try write(" : \(superclass)")
        }
        if protocols.count > 0 {
            for (index, proto) in protocols.enumerated() {
                if index > 0 || superclass != nil {
                    try write(", ")
                }
                try write(proto)
            }
        }
        try write("\n")
    }

    open func writeClassInterfaceEnd(name: String) throws -> Void {
        try write("\n")
        try write("ENDCLASS\n")
    }

    open func writeClassInterface(name: String,
                                  scope: Scope = .public,
                                  superclass: String? = nil,
                                  protocols: [String] = [],
                                  documentation: String? = nil,
                                  properties: (() throws -> Void)? = nil,
                                  methods: (() throws -> Void)? = nil) throws -> Void {
        if documentationPosition == .beforeDeclaration, let documentation {
            try writeComment(documentation, type: .classDocumentation)
        }
        try writeClassInterfaceBegin(name: name, scope: scope, superclass: superclass, protocols: protocols)
        if documentationPosition == .afterDeclaration, let documentation {
            try writeComment(documentation, type: .classDocumentation)
        }
        if let properties {
            try write("\n")
            if classPropertiesIndent {
                try indent {
                    try properties()
                }
            } else {
                try properties()
            }
        }
        if let methods {
            try write("\n")
            if classMethodsIndent {
                try indent {
                    try methods()
                }
            } else {
                try methods()
            }
        }
        try write("\n")
        try writeClassInterfaceEnd(name: name)
    }

    open func writeClassImplementationBegin(name: String,
                                            scope: Scope = .public,
                                            superclass: String? = nil,
                                            protocols: [String] = []) throws -> Void {
        try write("CLASS \(name)")
        if let superclass {
            try write(" : \(superclass)")
        }
        if protocols.count > 0 {
            for (index, proto) in protocols.enumerated() {
                if index > 0 || superclass != nil {
                    try write(", ")
                }
                try write(proto)
            }
        }
        try write("\n")
    }

    open func writeClassImplementationEnd(name: String) throws -> Void {
        try write("\n")
        try write("ENDCLASS\n")
    }

    open func writeClassImplementation(name: String,
                                       scope: Scope = .public,
                                       superclass: String? = nil,
                                       protocols: [String] = [],
                                       documentation: String? = nil,
                                       properties: (() throws -> Void)? = nil,
                                       methods: (() throws -> Void)? = nil) throws -> Void {
        if documentationPosition == .beforeDeclaration, let documentation {
            try writeComment(documentation, type: .classDocumentation)
        }
        try writeClassImplementationBegin(name: name, scope: scope, superclass: superclass, protocols: protocols)
        if documentationPosition == .afterDeclaration, let documentation {
            try writeComment(documentation, type: .classDocumentation)
        }
        if let properties {
            pushOutput()
            if classPropertiesIndent {
                try indent {
                    try properties()
                }
            } else {
                try properties()
            }
            let writtenProperties = popOutput()
            if writtenProperties.count > 0 {
                try write("\n")
                try write(writtenProperties)
            }
        }
        if let methods {
            try write("\n")
            if classMethodsIndent {
                try indent {
                    try methods()
                }
            } else {
                try methods()
            }
        }
        try write("\n")
        try writeClassImplementationEnd(name: name)
    }


    // MARK: - Type Casting
    
    /**
     Creates a code writer for the passed in object.
     
     You'll almost certainly override this method for you language, so that you can produce appropriate code writers. You'll usually do something like check and see if the object reponds to a particular protocol or is of a particular type, and if it is, then you'll produce the code writer.
     
     For example:
     
     ```Swift
     if let object = object as? AIEWritableObject {
         return AIECodeWriter(object: object)
     }
     return nil
     ```
     
     - parameter object The object to create code writer for.
     
     - returns A code writer or `nil` if none can be produced.
     */
    open func codeWriter(for object: Any?) -> AIECodeWriter? {
        if let object = object as? AIEWritableObject {
            return AIECodeWriter(object: object)
        }
        return nil
    }

    // MARK: - Code Generation

    /**
     Defines the scope of things like properties and methods. Usually defaults to public.
     */
    public enum Scope {
        /// Methods or properties are public and can be overridden.
        case `open`
        /// Methods or properties are public. May be the same as `open` in many languages.
        case `public`
        /// Methods or properties are protected.
        case `protected`
        /// Methods or properties are private.
        case `private`
    }
    
    /**
     Flags to the context what stage we're about to begin.
     
     
     */
    open func begin(stage: Stage, scope: Scope = .public) -> Void {
        self.stage = stage
        self.scope = scope
    }
    
    /**
     Use this method to initiate writing code.
     
     For some stages, this will cause the entire neural network graph to be traversed. For others, it will simply exit after processing one node. In all cases, the context's stage will be set to the `stage`.
     
     - parameter object The object to generate code for.
     - parameter stage The stage of the code generation.
     */
    @discardableResult
    open func generateCode(for object: Any?, in stage: Stage, scope: Scope = .public) throws -> Bool {
        if self.stage != stage {
            begin(stage: stage, scope: scope)
        }
        return try codeWriter(for: object)?.generateCode(in: self) ?? false
    }
    
}
