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

private protocol AIEMLComputeObjCWriter {

    // Allows nodes that should generate a public property to do so.
    func generatePublicInterfaceDefinition(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void

    // Allows nodes that should generate a private ivar to do so.
    func generatePrivateInterfaceDefinition(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void

    // Allows nodes that should generate a private ivar to do so.
    func generateCreationInsideInit(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void

    // Allows nodes that should generate a private ivar to do so.
    func generateCreationInsideBuild(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void

}

private extension AIEMLComputeObjCWriter {

    func generatePublicInterfaceDefinition(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
    }

    func generatePrivateInterfaceDefinition(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
    }

    func generateCreationInsideInit(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
    }

    func generateCreationInsideBuild(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        try outputStream.indent(1).write("// We should output the creation of node: \(self)\n")
    }

}

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
        try iterateAllNodes { node in
            if let node = node as? AIEMLComputeObjCWriter {
                try node.generatePublicInterfaceDefinition(to: outputStream, accumulatingMessages: &messages)
            }
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
        try outputStream.indent(0).write("//\n")
        try outputStream.indent(0).write("// \(info[.codeName] ?? "Anonymous").m\n")
        try outputStream.indent(0).write("//\n")
        try outputStream.indent(0).write("// Created by \(NSFullUserName()) on \(Self.simpleDateFormatter.string(from:Date()))\n")
        try outputStream.indent(0).write("//\n")
        try outputStream.indent(0).write("\n")
        try outputStream.indent(0).write("#import <MLCompute/MLCompute.h>\n")
        try outputStream.indent(0).write("\n")
        try outputStream.indent(0).write("@implementation \(info[.codeName] ?? "Anonymous") : NSObject {\n")
        try iterateAllNodes { node in
            if let node = node as? AIEMLComputeObjCWriter {
                try node.generatePrivateInterfaceDefinition(to: outputStream, accumulatingMessages: &messages)
            }
        }
        try outputStream.indent(0).write("}\n")
        try outputStream.indent(0).write("\n")

        try outputStream.indent(0).write("- (instancetype)initWithDevice:(MLCDevice *)device {\n")
        try outputStream.indent(1).write("if ((self == [super init])) {\n")
        try outputStream.indent(2).write("_device = device;\n")
        // Allow any nodes to initialize their ivar values if they declared an ivar (private or public) above. The don't necessarily need to do this.
        var didGenerateOne = false
        try iterateAllNodes { node in
            if let node = node as? AIEMLComputeObjCWriter {
                if !didGenerateOne {
                    try outputStream.indent(0).write("\n")
                    try outputStream.indent(2).write("// Initialize our descriptors\n")
                    didGenerateOne = true
                }
                try node.generateCreationInsideInit(to: outputStream, accumulatingMessages: &messages)
            }
        }
        try outputStream.indent(1).write("}\n")
        try outputStream.indent(0).write("\n")
        try outputStream.indent(1).write("return self;\n")
        try outputStream.indent(0).write("}\n")
        try outputStream.indent(0).write("\n")
        try outputStream.indent(0).write("- (MLCGraph *)buildGraph {\n")
        try iterateAllNodes(using: { node in
            if let node = node as? AIEMLComputeObjCWriter {
                try node.generateCreationInsideBuild(to: outputStream, accumulatingMessages: &messages)
            } else {
                try outputStream.indent(1).write("// \(Swift.type(of:node)) does not yet conform to AIEMLComputeObjCWriter.\n")
            }
        })
        try outputStream.indent(0).write("}\n")
        try outputStream.indent(0).write("\n")
        try outputStream.indent(0).write("@end\n")
        try outputStream.indent(0).write("\n")
    }
    
    override open func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        // First, we're going to look over our roots. All roots must be an IO node of some sort.
        iterateRoots { root in
            if let root = root as? AIEIO {
                self.type = root.type
            } else {
                if info[.extension] == "m" {
                    // Be careful to only add a message once.
                    messages.append(AIEMessage(type: .error, message: "Network roots must begin on an IO node.", on: root))
                }
            }
        }

        if info[.extension] == "h" {
            try generateInterface(to: outputStream, accumulatingMessages: &messages)
        } else if info[.extension] == "m" {
            try generateImplementation(to: outputStream, accumulatingMessages: &messages)
        }
        
        // Add a message, just because we want a message to test with.
        if let root = roots.first,
           info[.extension] == "m" {
            messages.append(AIEMessage(type: .info, message: "Test info. This is a really long message, because we want to make sure that the text is wrapping correctly, and also that it stops growing in height after wrapping three lines tall. To manage that, I need to write a whole bunch of text.", on: root))
            messages.append(AIEMessage(type: .warning, message: "Test warning", on: root))
            messages.append(AIEMessage(type: .error, message: "Test error", on: root))
        }
    }

}

extension AIEConvolution : AIEMLComputeObjCWriter {

    func generatePrivateInterfaceDefinition(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws {
        try outputStream.indent(1).write("MLCConvolutionDescriptor *_\(variableName)Descriptor;\n")
    }

    func generateCreationInsideInit(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        // Let's do some generally error checking, first.
        if stride.width < 1 {
            messages.append(AIEMessage(type: .warning, message: "Stride must be at least 1.", on: self))
        }
        if size.width < 2 {
            messages.append(AIEMessage(type: .warning, message: "Width must be at least 2, defaulting to 3.", on: self))
        }
        if size.height < 2 {
            messages.append(AIEMessage(type: .warning, message: "Height must be at least 2, defaulting to 3.", on: self))
        }
        if inputFeatureChannels < 1 {
            messages.append(AIEMessage(type: .warning, message: "Input feature channels must be at least 1.", on: self))
        }
        if outputFeatureChannels < 1 {
            messages.append(AIEMessage(type: .warning, message: "Output feature channels must be at least 1.", on: self))
        }
        // NOTE: Depth can be 0, because when it is we'll just depend on the depth of the input images.

        var type : String = "MLCConvolutionTypeStandard"
        switch self.type {
        case .standard: type = "MLCConvolutionTypeStandard"
        case .depthwise: type = "MLCConvolutionTypeDepthwise"
        case .transposed: type = "MLCConvolutionTypeTransposed"
        @unknown default:
            messages.append(AIEMessage(type: .warning, message: "Encountered an unknown convolution layer type that cannot be handled by the Obj-C code generator: \(self.type). Using \"\(type)\" instead.", on: self))
        }
        try outputStream.indent(2).write("_\(variableName)Descriptor = [MLCConvolutionDescriptor descriptorWithType: \(type)\n")
        if depth > 0 {
            try outputStream.indent(2).write("                       kernelSizes: @[@\(size.width >= 2 ? size.width : 3), @\(size.height >= 2 ? size.height : 3), @\(depth)]\n")
        } else {
            try outputStream.indent(2).write("                       kernelSizes: @[@\(size.width >= 2 ? size.width : 3), @\(size.height >= 2 ? size.height : 3)]\n")
        }
        try outputStream.indent(2).write("          inputFeatureChannelCount: \(inputFeatureChannels)\n")
        try outputStream.indent(2).write("         outputFeatureChannelCount: \(outputFeatureChannels)\n")
        try outputStream.indent(2).write("                        groupCount: 1 /* ? */\n")
        try outputStream.indent(2).write("                           strides: @[@\(stride.width > 0 ? stride.width : 1), @\(stride.height > 0 ? stride.height : 1)]\n")
        try outputStream.indent(2).write("                     dilationRates: @[@\(dilation), @\(dilation)]\n")
        var paddingPolicy = "MLCPaddingPolicySame"
        switch self.paddingPolicy {
        case .same: paddingPolicy = "MLCPaddingPolicySame"
        case .valid: paddingPolicy = "MLCPaddingPolicyValid"
        case .usePaddingSize: paddingPolicy = "MLCPaddingPolicyUsePaddingSize"
        @unknown default:
            messages.append(AIEMessage(type: .warning, message: "Encountered an unknown padding policy type that cannot be handled by the Obj-C code generator: \(self.type). Using \"\(paddingPolicy)\" instead.", on: self))
        }
        try outputStream.indent(2).write("                     paddingPolicy: \(paddingPolicy)\n")
        try outputStream.indent(2).write("                      paddingSizes: @[@\(paddingSize), @\(paddingSize)]];\n")
    }

    func generateCreationInsideBuild(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        try outputStream.indent(1).write("MLCConvolutionLayer *\(variableName) = [MLCConvolutionLayer layerWithWeights: /* ???? */\n")
        try outputStream.indent(2).write("biases: /* ???? */\n")
        try outputStream.indent(2).write("descriptor: _\(variableName)Descriptor];\n")
    }

}

extension AIEFullyConnected : AIEMLComputeObjCWriter {

    func generatePrivateInterfaceDefinition(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws {
        try outputStream.indent(1).write("MLCConvolutionDescriptor *_\(variableName)Descriptor;\n")
    }

    func generateCreationInsideInit(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        // Let's do some generally error checking, first.
        if stride < 1 {
            messages.append(AIEMessage(type: .warning, message: "Stride must be at least 1.", on: self))
        }
        if width < 1 {
            messages.append(AIEMessage(type: .warning, message: "Width must be at least 2, defaulting to 3.", on: self))
        }
        if height < 1 {
            messages.append(AIEMessage(type: .warning, message: "Height must be at least 2, defaulting to 3.", on: self))
        }
        if inputFeatureChannels < 1 {
            messages.append(AIEMessage(type: .warning, message: "Input feature channels must be at least 1.", on: self))
        }
        if outputFeatureChannels < 1 {
            messages.append(AIEMessage(type: .warning, message: "Output feature channels must be at least 1.", on: self))
        }
        // NOTE: Depth can be 0, because when it is we'll just depend on the depth of the input images.

        try outputStream.indent(2).write("_\(variableName)Descriptor = [MLCConvolutionDescriptor descriptorWithKernelWidth: \(width)\n")
        try outputStream.indent(2).write("                      kernelHeight: \(height)\n")
        try outputStream.indent(2).write("          inputFeatureChannelCount: \(inputFeatureChannels)\n")
        try outputStream.indent(2).write("         outputFeatureChannelCount: \(outputFeatureChannels)];\n")
    }

}

extension AIEImageIO : AIEMLComputeObjCWriter {

    func generateCreationInsideBuild(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        // IO nodes don't actually become part of the graph, they just define our input.
    }

}
