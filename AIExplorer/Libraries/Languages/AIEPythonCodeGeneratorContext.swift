//
//  AIEPythonCodeGeneratorContext.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/6/23.
//

import Draw

open class AIEPythonCodeGeneratorContext: AIECodeGeneratorContext {

    open override var defaultDocumentationPosition : DocumentationPosition {
        return .afterDeclaration
    }

    open override func block(_ body: () throws -> Void) throws {
        try write(":\n")
        try indent(body)
    }

    open override func writingFunctionStart() throws -> Void {
        switch functionContext.type {
        case .prototype:
            break
        case .implementation:
            try write("def \(functionContext.name)(")
        case .call:
            try write("\(functionContext.name)(")
        }
    }

    open override func writeFunctionArgumentsStop() throws -> Void {
        functionContext.argumentsWritten = 0
        try write(")")
    }

    open override func writeComment(_ comment: String, type: CommentType = .singleLine) throws -> Void {
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

    // MARK: - Classes

    open override var classMethodsIndent: Bool { return true }
    open override var classPropertiesIndent: Bool { return true }

    open override func writeClassInterface(name: String, scope: AIECodeGeneratorContext.Scope = .public, superclass: String? = nil, protocols: [String] = [], documentation: String? = nil, properties: (() throws -> Void)? = nil, methods: (() throws -> Void)? = nil) throws {
        // Do nothing. Just override to actually do nothing, since Pyhton doesn't have interfaces.
    }

    open override func writeClassImplementationBegin(name: String, scope: AIECodeGeneratorContext.Scope = .public, superclass: String? = nil, protocols: [String] = []) throws {
        try write("class \(name):\n")
    }

    open override func writeClassImplementationEnd(name: String) throws {
        // Don't do much for Python
        try write("\n")
    }

}
