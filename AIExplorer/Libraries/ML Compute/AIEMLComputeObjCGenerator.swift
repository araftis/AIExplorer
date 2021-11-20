//
//  AIEMLComputeObjCGenerator.swift
//  AIExplorer
//
//  Created by AJ Raftis on 11/15/21.
//

import Cocoa

@objcMembers
open class AIEMLComputeObjCGenerator: AIECodeGenerator {
    
    open var type : AIEIO.Kind?

    open func generateInterface(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        try outputStream.write("//\n")
        try outputStream.write("// \(info[.codeName] ?? "Anonymous").h\n")
        try outputStream.write("//\n")
        try outputStream.write("// Created by \(NSFullUserName()) on \(Self.simpleDateFormatter.string(from:Date()))\n")
        try outputStream.write("//\n")
        try outputStream.write("\n")
        try outputStream.write("#import <MLCompute/MLCompute.h>\n")
        try outputStream.write("\n")
        try outputStream.write("NS_ASSUME_NONNULL_BEGIN\n")
        try outputStream.write("\n")
        try outputStream.write("@interface \(info[.codeName] ?? "Anonymous") : NSObject\n")
        try outputStream.write("\n")
        try outputStream.write("@property (nonatomic,strong) MLCDevice *device;\n")
        if info[.role].canInfer {
            try outputStream.write("@property (nonatomic,strong) MLCInferenceGraph *inferenceGraph;\n")
        }
        if info[.role].canTrain {
            try outputStream.write("@property (nonatomic,strong) MLCTrainingGraph *trainingGraph;\n")
        }
        try outputStream.write("\n")
        try outputStream.write("- (instancetype)initWithDevice:(MLCDevice *)device;\n")
        try outputStream.write("\n")
        if info[.role].canInferAndTrain {
            try outputStream.write("- (MLCLayer *)createNodeForTraining:(BOOL)flag;\n")
        } else {
            try outputStream.write("- (MLCLayer *)createNode;\n")
        }
        try outputStream.write("\n")
        try outputStream.write("@end\n")
        try outputStream.write("\n")
        try outputStream.write("NS_ASSUME_NONNULL_END\n")
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
        
        try outputStream.indent(0).write("- (instancetype)initWithDevice:(MLCDevice *)device {\n")
        try outputStream.indent(1).write("if ((self == [super init])) {\n")
        try outputStream.indent(2).write("// we should do something.\n")
        try outputStream.indent(1).write("}\n")
        try outputStream.indent(0).write("\n")
        try outputStream.indent(1).write("return self\n")
        try outputStream.indent(0).write("}\n")
        try outputStream.write("\n")

        for root in roots {
            if root is AIEIO {
                var iterator = root.makeIterator()
                
                while let node = iterator.next() {
                    if let node = node as? AIEIO {
                        type = node.type
                    } else {
                        try outputStream.write("// \(node)\n")
                    }
                }
            } else {
                messages.append(AIEMessage(type: .error, message: "Network roots must begin on an IO node.", on: root))
            }
        }
        
        try outputStream.write("@end\n")
        try outputStream.write("\n")
    }
    
    override open func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        try generateInterface(to: outputStream, accumulatingMessages: &messages)
        try generateImplementation(to: outputStream, accumulatingMessages: &messages)
        
//        // Add a message, just because we want a message to test with.
//        messages.append(AIEMessage(type: .info, message: "Test info. This is a really long message, because we want to make sure that the text is wrapping correctly, and also that it stops growing in height after wrapping three lines tall. To manage that, I need to write a whole bunch of text.", on: root))
//        messages.append(AIEMessage(type: .warning, message: "Test warning", on: root))
//        messages.append(AIEMessage(type: .error, message: "Test error", on: root))
    }

}
