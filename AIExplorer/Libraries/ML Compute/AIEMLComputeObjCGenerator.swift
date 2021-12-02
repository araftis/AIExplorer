//
//  AIEMLComputeObjCGenerator.swift
//  AIExplorer
//
//  Created by AJ Raftis on 11/15/21.
//

import Cocoa

private protocol AIEMLComputeObjCWriter {

    // Allows nodes that should generate a public property to do so.
    func generatePublicInterfaceDefinition(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void

    // Allows nodes that should generate a private ivar to do so.
    func generatePrivateInterfaceDefinition(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void

    // Allows nodes that should generate a private ivar to do so.
    func generateCreationInsideInit(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void

}

private extension AIEMLComputeObjCWriter {

    func generatePublicInterfaceDefinition(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
    }

    func generatePrivateInterfaceDefinition(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
    }

    func generateCreationInsideInit(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
    }

}

@objcMembers
open class AIEMLComputeObjCGenerator: AIECodeGenerator {
    
    open var type : AIEIO.Kind?

    open func iterateNode(in node: AIEGraphic, using block: (_ node: AIEGraphic) throws -> Void) rethrows -> Void {
        var iterator = node.makeIterator()

        while let node = iterator.next() {
            try block(node as! AIEGraphic)
        }
    }

    open func iterateRoots(using block: (_ root: AIEGraphic) throws -> Void) rethrows -> Void {
        for root in roots {
            try block(root)
        }
    }

    open func iterateAllNodes(using block: (_ node: AIEGraphic) throws -> Void) rethrows -> Void {
        try iterateRoots { node in
            try iterateNode(in: node, using: block)
        }
    }

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
        try outputStream.write("@end\n")
        try outputStream.write("\n")
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
        if let variableName = self.variableName {
            try outputStream.indent(1).write("MLCConvolutionDescriptor *_\(variableName)Weights;\n")
        }
    }

    func generateCreationInsideInit(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        if let variableName = self.variableName {

            // Let's do some generally error checking, first.
            if stride < 1 {
                messages.append(AIEMessage(type: .warning, message: "Stride must be at least 1.", on: self))
            }
            if width < 2 {
                messages.append(AIEMessage(type: .warning, message: "Width must be at least 2, defaulting to 3.", on: self))
            }
            if height < 2 {
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
            try outputStream.indent(2).write("_\(variableName)Weights = [MLCConvolutionDescriptor descriptorWithType: \(type)\n")
            if depth > 0 {
                try outputStream.indent(2).write("                       kernelSizes: @[@\(width >= 2 ? width : 3), @\(height >= 2 ? height : 3), @\(depth)]\n")
            } else {
                try outputStream.indent(2).write("                       kernelSizes: @[@\(width >= 2 ? width : 3), @\(height >= 2 ? height : 3)]\n")
            }
            try outputStream.indent(2).write("          inputFeatureChannelCount: \(inputFeatureChannels)\n")
            try outputStream.indent(2).write("         outputFeatureChannelCount: \(outputFeatureChannels)\n")
            try outputStream.indent(2).write("                        groupCount: 1 /* ? */\n")
            try outputStream.indent(2).write("                           strides: @[@\(stride > 0 ? stride : 1), @\(stride > 0 ? stride : 1)]\n")
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
    }

}

extension AIEFullyConnected : AIEMLComputeObjCWriter {

    func generatePrivateInterfaceDefinition(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws {
        if let variableName = self.variableName {
            try outputStream.indent(1).write("MLCConvolutionDescriptor *_\(variableName)Weights;\n")
        }
    }

    func generateCreationInsideInit(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        if let variableName = self.variableName {
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

            try outputStream.indent(2).write("_\(variableName)Weights = [MLCConvolutionDescriptor descriptorWithKernelWidth: \(width)\n")
            try outputStream.indent(2).write("                      kernelHeight: \(height)\n")
            try outputStream.indent(2).write("          inputFeatureChannelCount: \(inputFeatureChannels)\n")
            try outputStream.indent(2).write("         outputFeatureChannelCount: \(outputFeatureChannels)];\n")
        }
    }

}
