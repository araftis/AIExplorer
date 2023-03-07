//
//  AIEObjCCodeGeneratorContext.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/6/23.
//

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
