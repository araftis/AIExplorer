//
//  AIEConvolution+MLCompute.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/5/23.
//

import Foundation

extension AIEConvolution : AIEMLComputeCodeWriter {

    public func createMLComputeObjCCodeWriter() -> AIECodeWriter {
        return ConvolutionObjCCodeWriter(object: self)
    }
    
    public func createMLComputeSwiftCodeWriter() -> AIECodeWriter {
        return ConvolutionSwiftCodeWriter(object: self)
    }
    

    internal class ConvolutionObjCCodeWriter : AIETypedCodeWriter<AIEConvolution> {
        
        override func generatePropertyDeclarationCode(in context: AIECodeGeneratorContext) throws -> Bool {
            var wroteCode = false
            
            if context.scope == .private {
                try context.write("MLCConvolutionDescriptor *_\(node.variableName)Descriptor;\n")
                wroteCode = true
            }
            try progressToChild(in: context)
            return wroteCode
        }
        
        override func generateInitializationCode(context: AIECodeGeneratorContext) throws -> Bool {
            // Let's do some generally error checking, first.
            if node.stride.width < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Stride must be at least 1.", on: node))
            }
            if node.size.width < 2 {
                context.add(message: AIEMessage(type: .warning, message: "Width must be at least 2, defaulting to 3.", on: node))
            }
            if node.size.height < 2 {
                context.add(message: AIEMessage(type: .warning, message: "Height must be at least 2, defaulting to 3.", on: node))
            }
            if node.inputFeatureChannels < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Input feature channels must be at least 1.", on: node))
            }
            if node.outputFeatureChannels < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Output feature channels must be at least 1.", on: node))
            }
            // NOTE: Depth can be 0, because when it is we'll just depend on the depth of the input images.
            
            var type : String = "MLCConvolutionTypeStandard"
            switch node.type {
            case .standard: type = "MLCConvolutionTypeStandard"
            case .depthwise: type = "MLCConvolutionTypeDepthwise"
            case .transposed: type = "MLCConvolutionTypeTransposed"
            @unknown default:
                context.add(message: AIEMessage(type: .warning, message: "Encountered an unknown convolution layer type that cannot be handled by the Obj-C code generator: \(node.type). Using \"\(type)\" instead.", on: node))
            }
            try context.write("_\(node.variableName)Descriptor = [MLCConvolutionDescriptor descriptorWithType: \(type)\n")
            if node.depth > 0 {
                try context.write("                       kernelSizes: @[@\(node.size.width >= 2 ? node.size.width : 3), @\(node.size.height >= 2 ? node.size.height : 3), @\(node.depth)]\n")
            } else {
                try context.write("                       kernelSizes: @[@\(node.size.width >= 2 ? node.size.width : 3), @\(node.size.height >= 2 ? node.size.height : 3)]\n")
            }
            try context.write("          inputFeatureChannelCount: \(node.inputFeatureChannels)\n")
            try context.write("         outputFeatureChannelCount: \(node.outputFeatureChannels)\n")
            try context.write("                        groupCount: 1 /* ? */\n")
            try context.write("                           strides: @[@\(node.stride.width > 0 ? node.stride.width : 1), @\(node.stride.height > 0 ? node.stride.height : 1)]\n")
            try context.write("                     dilationRates: @[@\(node.dilation), @\(node.dilation)]\n")
            var paddingPolicy = "MLCPaddingPolicySame"
            switch node.paddingPolicy {
            case .same: paddingPolicy = "MLCPaddingPolicySame"
            case .valid: paddingPolicy = "MLCPaddingPolicyValid"
            case .usePaddingSize: paddingPolicy = "MLCPaddingPolicyUsePaddingSize"
            @unknown default:
                context.add(message: AIEMessage(type: .warning, message: "Encountered an unknown padding policy type that cannot be handled by the Obj-C code generator: \(node.type). Using \"\(paddingPolicy)\" instead.", on: node))
            }
            try context.write("                     paddingPolicy: \(paddingPolicy)\n")
            try context.write("                      paddingSizes: @[@\(node.paddingSize.width), @\(node.paddingSize.height)]];\n")
            
            try progressToChild(in: context)
            
            return true
        }
        
        override func generateBuildCode(in context: AIECodeGeneratorContext) throws -> Bool {
            try context.write("MLCConvolutionLayer *\(node.variableName) = [MLCConvolutionLayer layerWithWeights: /* ???? */\n")
            try context.write("biases: /* ???? */\n")
            try context.write("descriptor: _\(node.variableName)Descriptor];\n")
            
            try progressToChild(in: context)
            
            return true
        }

    }

    internal class ConvolutionSwiftCodeWriter : AIETypedCodeWriter<AIEConvolution> {
    }
    
}

