/*
 AIEMLComputeObjCGenerator.swift
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

import Cocoa

@objcMembers
open class AIEMLComputeObjCGenerator: AIEMLComputeCodeGenerator {
    
    open func generateInterface(in context: AIECodeGeneratorContext) throws -> Void {
        try context.write("//\n")
        try context.write("// \(info[.codeName] ?? "Anonymous").h\n")
        try context.write("//\n")
        try context.write("// Created by \(NSFullUserName()) on \(Self.simpleDateFormatter.string(from:Date()))\n")
        try context.write("//\n")
        try context.write("\n")
        try context.write("#import <MLCompute/MLCompute.h>\n")
        try context.write("\n")
        try context.write("NS_ASSUME_NONNULL_BEGIN\n")
        try context.write("\n")

        try context.writeClassInterface(name: info[.codeName] ?? "Anonymous",
                                        superclass: "NSObject") {
            try context.write("@property (nonatomic,strong) MLCDevice *device;\n")
            if self.info[.role].canInfer {
                try context.write("@property (nonatomic,strong) MLCInferenceGraph *inferenceGraph;\n")
            }
            if self.info[.role].canTrain {
                try context.write("@property (nonatomic,strong) MLCTrainingGraph *trainingGraph;\n")
            }
            try self.iterateRoots { root in
                try context.generateCode(for: root, in: .propertyDeclarations, scope: .public)
            }
        } methods: {
            try context.writeFunction(name: "initWith", type: .prototype, returnType: "instancetype") {
                try context.writeArgument(name: "device", type: "MLCDevice *")
            }
            try context.writeFunction(name: "buildGraph", type: .prototype, returnType: "MLCGraph *") {
            }
            try self.iterateRoots { root in
                try context.generateCode(for: root, in: .interfaceMethods, scope: .public)
            }
        }
        try context.write("\n")
        try context.write("NS_ASSUME_NONNULL_END\n")
        try context.write("\n")
    }
    
    open func generateImplementation(in context: AIECodeGeneratorContext) throws -> Void {
        try context.write("//\n")
        try context.write("// \(info[.codeName] ?? "Anonymous").m\n")
        try context.write("//\n")
        try context.write("// Created by \(NSFullUserName()) on \(Self.simpleDateFormatter.string(from:Date()))\n")
        try context.write("//\n")
        try context.write("\n")
        try context.write("#import <MLCompute/MLCompute.h>\n")
        try context.write("\n")

        try context.writeClassImplementation(name: info[.codeName] ?? "Anonymous",
                                             superclass: "NSObject") {
            try context.block {
                try self.iterateRoots { root in
                    try context.generateCode(for: root, in: .propertyDeclarations, scope: .public)
                }
            }
        } methods: {
            try context.writeFunction(name: "initWith", type: .implementation, returnType: "instancetype") {
                try context.writeArgument(name: "device", type: "MLCDevice *")
            } body: {
                try context.write("if ((self == [super init]))")
                try context.block {
                    try context.write("_device = device;\n")
                    // Allow any nodes to initialize their ivar values if they declared an ivar (private or public) above. The don't necessarily need to do this.
                    try self.iterateRoots { root in
                        try context.generateCode(for: root, in: .initialization)
                    }
                }
                try context.write("\n")
                try context.write("return self;\n")
            }
            try context.write("\n")

            try context.writeFunction(name: "buildGraph", type: .implementation, returnType: "MLCGraph *") {
                // We don't have any arguments
            } body: {
                try self.iterateRoots { root in
                    try context.generateCode(for: root, in: .build)
                }
            }

            try self.iterateRoots { root in
                try context.generateCode(for: root, in: .implementationMethods, scope: .public
                )
            }
        }
        try context.write("\n")
    }
    
    override open func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        // First, create our generation context.
        let context = AIEMLComputeObjCContext(outputStream: outputStream, library: library, codeGenerator: self)
        
        // Next, we're going to look over our roots. All roots must be an IO node of some sort.
        validateRootNodes(in: context)

        if fileType == .objCInterface {
            try generateInterface(in: context)
        } else if fileType == .objCImplementation {
            try generateImplementation(in: context)
        }
        
        messages.append(contentsOf: context.messages)
        
//        // Add a message, just because we want a message to test with.
//        if let root = roots.first,
//           info[.extension] == "m" {
//            messages.append(AIEMessage(type: .info, message: "Test info. This is a really long message, because we want to make sure that the text is wrapping correctly, and also that it stops growing in height after wrapping three lines tall. To manage that, I need to write a whole bunch of text.", on: root))
//            messages.append(AIEMessage(type: .warning, message: "Test warning", on: root))
//            messages.append(AIEMessage(type: .error, message: "Test error", on: root))
//        }
    }

}
