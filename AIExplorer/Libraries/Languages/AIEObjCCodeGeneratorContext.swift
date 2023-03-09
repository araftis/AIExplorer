/*
 AIEObjCCodeGeneratorContext.swift
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

open class AIEObjCCodeGeneratorContext: AIECodeGeneratorContext {

    open override func block(_ indentedBlock: () throws -> Void) throws {
        try write(" {\n")
        try super.indent(indentedBlock)
        try write("}\n")
    }

    open override func writingFunctionStart() throws -> Void {
        switch functionContext.type {
        case .prototype:
            fallthrough
        case .implementation:
            try write("- (\(functionContext.returnType ?? "id"))\(functionContext.name)")
        case .call:
            try write("[\(functionContext.receiver ?? "**ERROR**") \(functionContext.name)")
        }
    }

    open override func writeArgument(_ condition : @autoclosure () -> Bool, name: String? = nil, value valueIn: String? = nil, type: String? = nil) throws -> Void {
        if condition() {
            let value = valueIn ?? name
            if functionContext.argumentsWritten > 0 {
                if functionContext.separateArgumentsWithNewlines {
                    try write("\n")
                } else {
                    try write(" ")
                }
            }
            if let name, let value {
                try write(functionContext.argumentsWritten == 0 ? name.firstLetterCapitalized : name)
                try write(":")
                if functionContext.type != .call {
                    if let type {
                        try write("(\(type))")
                    } else {
                        try write("(id)")
                    }
                }
                try write(value)
            } else if let value {
                try write(value)
            }
            functionContext.argumentsWritten += 1
        }
    }

    open override func writeFunctionArgumentsStop() throws -> Void {
        functionContext.argumentsWritten = 0
        switch functionContext.type {
        case .call:
            try write("]")
        case .prototype:
            try write(";\n")
        case .implementation:
            break
        }
    }

    // MARK: - Classes

    open override func writeClassInterfaceBegin(name: String,
                                                scope: AIECodeGeneratorContext.Scope = .public,
                                                superclass: String? = nil,
                                                protocols: [String] = []) throws {
        try write("@interface \(name)")
        if let superclass {
            try write(" : \(superclass)")
        }
        if protocols.count > 0 {
            try write(" <")
            for (index, proto) in protocols.enumerated() {
                if index > 0 {
                    try write(", ")
                }
                try write(proto)
            }
            try write(">")
        }
        try write("\n")
    }

    open override func writeClassInterfaceEnd(name: String) throws {
        try write("@end\n")
    }

    open override func writeClassImplementationBegin(name: String,
                                                scope: AIECodeGeneratorContext.Scope = .public,
                                                superclass: String? = nil,
                                                protocols: [String] = []) throws {
        try write("@implementation \(name)")
        try write("\n")
    }

    open override func writeClassImplementationEnd(name: String) throws {
        try write("@end\n")
    }

}
