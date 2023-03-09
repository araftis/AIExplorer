/*
 AIEPythonCodeGeneratorContext.swift
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

open class AIEPythonCodeGeneratorContext: AIECodeGeneratorContext {

    open override var documentationPosition : DocumentationPosition {
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
            if let receiver = functionContext.receiver {
                try write("\(receiver).")
            }
            try write("\(functionContext.name)(")
        }
    }

    open override func writeFunctionArgumentsStop() throws -> Void {
        functionContext.argumentsWritten = 0
        try write(")")
    }

    open override var singleLineCommentStart : String {
        return "#"
    }

    open override var multilineCommentStart : String {
        return "\"\"\""
    }

    open override var multilineCommentEnd : String {
        return "\"\"\""
    }

    open override var documentationCommentStart : String {
        return "\"\"\""
    }

    open override var documentationCommentEnd : String {
        return "\"\"\"\n"
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
