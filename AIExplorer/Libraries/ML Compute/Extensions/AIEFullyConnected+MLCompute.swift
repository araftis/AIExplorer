//
//  AIEFullyConnected+MLCompute.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/5/23.
//

import Foundation

extension AIEFullyConnected : AIEMLComputeCodeWriter {

    public func createMLComputeObjCCodeWriter() -> AIECodeWriter {
        return ObjCFullyConnectedCodeWriter(object: self)
    }
    
    public func createMLComputeSwiftCodeWriter() -> AIECodeWriter {
        return SwiftFullyConnectedCodeWriter(object: self)
    }
    
    class ObjCFullyConnectedCodeWriter : AIETypedCodeWriter<AIEFullyConnected> {
        
        open override func generatePropertyDeclarationCode(in context: AIECodeGeneratorContext) throws -> Bool {
            var wrote = false
            if context.scope == .private {
                try context.write("MLCConvolutionDescriptor *_\(object.variableName)Descriptor;\n")
                wrote = true
            }
            try progressToChild(context: context)
            return wrote
        }

        open override func generateInitializationCode(context: AIECodeGeneratorContext) throws -> Bool {
            // Let's do some generally error checking, first.
            if node.stride < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Stride must be at least 1.", on: node))
            }
            if node.width < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Width must be at least 2, defaulting to 3.", on: node))
            }
            if node.height < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Height must be at least 2, defaulting to 3.", on: node))
            }
            if node.inputFeatureChannels < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Input feature channels must be at least 1.", on: node))
            }
            if node.outputFeatureChannels < 1 {
                context.add(message: AIEMessage(type: .warning, message: "Output feature channels must be at least 1.", on: node))
            }
            // NOTE: Depth can be 0, because when it is we'll just depend on the depth of the input images.
            try context.write("\(node.variableName)Descriptor = ")
            try context.writeFunction(name: "descriptionWith", type: .call, receiver: "MLCConvolutionDescriptor", argumentsIndented: true) {
                try context.writeArgument(name: "kernelWidth", value: "\(node.height)")
                try context.writeArgument(name: "kernelHeight", value: "\(node.height)")
                try context.writeArgument(name: "inputFeatureChannelCount", value: "\(node.inputFeatureChannels)")
                try context.writeArgument(name: "outputFeatureChannelCount", value: "\(node.outputFeatureChannels)")
            }
            try context.write(";\n")
            
            try progressToChild(context: context)
            
            return true
        }
        
    }

    class SwiftFullyConnectedCodeWriter : AIETypedCodeWriter<AIEFullyConnected> {
    }
    
}

