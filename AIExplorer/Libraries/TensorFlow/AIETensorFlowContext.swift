//
//  AIETensorFlowContext.swift
//  AIExplorer
//
//  Created by AJ Raftis on 1/26/23.
//

import Cocoa

internal enum AIEStage {
    
    case initialization
    case build
    
}

// Class, because we need this to be mutable without hassle.
internal class AIETensorFlowContext {
    
    /// The current stage of generation. Setting this resets `generatedCode` to `false`.
    var stage : AIEStage = .initialization {
        didSet {
            generatedCode = false
        }
    }
    var outputStreams : [OutputStream]
    var path : [AIETensorFlowCodeWriter]
    var messages : [AIEMessage]
    var indent : Int
    /// If, when traversing the tree, we generate code, this will be set to true.
    var generatedCode : Bool = false

    init(outputStream: OutputStream, indent: Int = 0) {
        self.indent = indent
        self.outputStreams = [outputStream]
        self.path = [AIETensorFlowCodeWriter]()
        self.messages = [AIEMessage]()
    }
    
    // MARK: - Output
    
    var output : OutputStream {
        assert(outputStreams.count >= 1, "The code write over popped the output stream, which is fatal.")
        return outputStreams.last!
    }
    
    /**
     Creates a temporary new output stream and pushes it on the output stack.
     
     This is potentially useful if you need to follow a path in the neural net, but you're not sure if it's going to generate any output. You can call this method, descend into the children, and if output is generated, you can then append it when popping the output.
     
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

    func push(_ current: AIETensorFlowCodeWriter) -> Void {
        path.append(current)
    }
    
    @discardableResult
    func pop() -> AIETensorFlowCodeWriter? {
        let last = path.last
        path.removeLast()
        return last
    }

    open var currentNode : AIETensorFlowCodeWriter? {
        return path.last
    }
    
    /**
     Returns the "parent" object on the current path.
     
     This reverse enumerates the current path and returns the first (last?) object that is of `kind` `.neuralNetwork`. Other types are ignored. This basically means that we'd skip something like `AIEBranch`, but return most other nodes.
     */
    open var parent : AIETensorFlowCodeWriter? {
        for (index, ancestor) in path.reversed().enumerated() {
            if index == path.count {
                // Skip the current object, since we want it's parent.
                continue
            }
            if ancestor.kind == .neuralNetwork {
                return ancestor
            }
        }
        return nil
    }
    
    // MARK: - Messages

    func add(message: AIEMessage) -> Void {
        messages.append(message)
    }
    
    // MARK: - Indentation

    func incrementIndent() -> Void {
        indent += 1
    }

    func decrementIndent() -> Void {
        if indent > 0 {
            indent -= 1
        }
    }
    
    // MARK: - Writing Conveniences
    
    func write(_ string: String) throws -> Void {
        try output.write(string)
    }
    
    func writeIndented(_ string: String) throws -> Void {
        try output.indent(indent).write(string)
    }
    
}
