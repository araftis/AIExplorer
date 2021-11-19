//
//  AIEMLComputeSwiftGenerator.swift
//  AIExplorer
//
//  Created by AJ Raftis on 11/15/21.
//

import Cocoa

@objcMembers
open class AIEMLComputeSwiftGenerator: AIECodeGenerator {

    override open func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        try outputStream.write("//\n")
        try outputStream.write("// \(info[.codeName] ?? "Anonymous").h\n")
        try outputStream.write("//\n")
        try outputStream.write("// Created by \(NSFullUserName()) on \(Self.simpleDateFormatter.string(from:Date()))\n")
        try outputStream.write("//\n")
        try outputStream.write("\n")
        try outputStream.write("import MLCompute\n")
        try outputStream.write("\n")
        try outputStream.write("public class \(info[.codeName] ?? "Anonymous") {\n")
        try outputStream.write("\n")
        try outputStream.write("}\n")
        try outputStream.write("\n")
    }

}
