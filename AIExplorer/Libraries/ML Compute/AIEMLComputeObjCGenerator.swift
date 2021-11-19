//
//  AIEMLComputeObjCGenerator.swift
//  AIExplorer
//
//  Created by AJ Raftis on 11/15/21.
//

import Cocoa

@objcMembers
open class AIEMLComputeObjCGenerator: AIECodeGenerator {

    open func generateInterface(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        try outputStream.write("//\n")
        try outputStream.write("// \(info[.codeName] ?? "Anonymous").h\n")
        try outputStream.write("//\n")
        try outputStream.write("// Created by \(NSFullUserName()) on \(Self.simpleDateFormatter.string(from:Date()))\n")
        try outputStream.write("//\n")
        try outputStream.write("\n")
        try outputStream.write("#import <MLCompute/MLCompute.h>\n")
        try outputStream.write("\n")
        try outputStream.write("@interface \(info[.codeName] ?? "Anonymous") : NSObject\n")
        try outputStream.write("\n")
        try outputStream.write("@end\n")
        try outputStream.write("\n")
    }
    
    open func generateImplementation(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        try outputStream.write("//\n")
        try outputStream.write("// \(info[.codeName] ?? "Anonymous").m\n")
        try outputStream.write("//\n")
        try outputStream.write("// Created by \(NSFullUserName()) on \(Self.simpleDateFormatter.string(from:Date()))\n")
        try outputStream.write("//\n")
        try outputStream.write("\n")
        try outputStream.write("#import <MLCompute/MLCompute.h>\n")
        try outputStream.write("\n")
        try outputStream.write("@implementation \(info[.codeName] ?? "Anonymous") : NSObject\n")
        try outputStream.write("\n")
        try outputStream.write("@end\n")
        try outputStream.write("\n")
    }
    
    override open func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        try generateInterface(to: outputStream, accumulatingMessages: &messages)
        try generateImplementation(to: outputStream, accumulatingMessages: &messages)
        
        // Add a message, just because we want a message to test with.
        messages.append(AIEMessage(type: .info, message: "Test info. This is a really long message, because we want to make sure that the text is wrapping correctly, and also that it stops growing in height after wrapping three lines tall. To manage that, I need to write a whole bunch of text.", on: root))
        messages.append(AIEMessage(type: .warning, message: "Test warning", on: root))
        messages.append(AIEMessage(type: .error, message: "Test error", on: root))
    }

}
