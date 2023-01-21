/*
 AIETensorFlowCodeGenerator.swift
 AIExplorer

 Copyright © 2021, AJ Raftis and AIExplorer authors
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

// Class, because we need this to be mutable without hassle.
internal class AIETensorFlowContext {
    var output : OutputStream
    var path : [AIETensorFlowCodeWriter]
    var messages : [AIEMessage]
    var indent : Int

    init(outputStream: OutputStream, indent: Int = 0, messages : inout [AIEMessage]) {
        self.indent = indent
        self.output = outputStream
        self.path = [AIETensorFlowCodeWriter]()
        self.messages = messages
    }

    func push(_ parent: AIETensorFlowCodeWriter) -> Void {
        path.append(parent)
    }

    @discardableResult
    func pop() -> AIETensorFlowCodeWriter? {
        let last = path.last
        path.removeLast()
        return last
    }

    open var parent : AIETensorFlowCodeWriter? {
        return path.last
    }

    func add(message: AIEMessage) -> Void {
        messages.append(message)
    }

    func incrementIndent() -> Void {
        indent += 1
    }

    func decrementIndent() -> Void {
        if indent > 0 {
            indent -= 1
        }
    }

}

internal protocol AIETensorFlowCodeWriter {

    func generateCode(context: AIETensorFlowContext) throws -> Void
    func appendParent(context: AIETensorFlowContext) throws -> Void
    func progressToChild(context: AIETensorFlowContext) throws -> Void
    var destinationObjects : [AIEGraphic] { get }
    var variableName : String { get }
    var inputShape : [Int]? { get }
    var outputShape : [Int] { get }
    func validateSingleChild(context: AIETensorFlowContext) -> Void
    func appendShapes(context: AIETensorFlowContext) throws -> Void

}

extension AIETensorFlowCodeWriter {

    func appendParent(context: AIETensorFlowContext) throws -> Void {
        if let parent = context.parent {
            try context.output.write("(\(parent.variableName))")
        }
    }

    func progressToChild(context: AIETensorFlowContext) throws -> Void {
        let children = destinationObjects

        if children.count == 0 {
            // We're done?
            return
        }

        validateSingleChild(context: context)

        if children.count == 1 {
            // We have one child, so let's do our thing.
            context.push(self)
            if let child = children.first as? AIETensorFlowCodeWriter {
                try child.generateCode(context: context)
            }
            context.pop()
            return
        }

    }

    func validateSingleChild(context: AIETensorFlowContext) -> Void {
        if destinationObjects.count != 1 {
            context.add(message: AIEMessage(type:.warning, message: "The node \(type(of:self)) should only have one child.", on: self as? AIEGraphic))
        }
    }

    func appendShapes(context: AIETensorFlowContext) throws -> Void {
        if let inputShape {
            try context.output.indent(context.indent).write("# Input Shape: \(inputShape) -> \(outputShape)\n")
        }
    }

}

extension AIEImageIO : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws {
        if batchSize <= 0 {
            context.add(message: AIEMessage(type: .warning, message: "The input node should define a batch size.", on: self))
        }
        if let inputShape {
            try context.output.indent(context.indent).write("# Input Shape: \(inputShape)\n")
        }
        try context.output.indent(2).write("\(variableName) = Input(shape=(\(height), \(width), \(depth)))\n")
        try progressToChild(context: context)
    }
}


extension AIEConvolution : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws {
        try appendShapes(context: context)
        try context.output.indent(2).write("\(variableName) = layers.Conv2D(\(outputFeatureChannels)")
        if size.width == size.height {
            try context.output.write(", \(size.height)")
        } else {
            try context.output.write(", (\(size.height), \(size.width))")
        }
        if stride.width < 0 || stride.height < 0 {
            context.add(message: AIEMessage(type: .error, message: "The width and height of stride must both be positive integers.", on: self))
        } else if (stride.width == 0 && stride.height != 0) || (stride.width != 0 && stride.height == 0) {
            context.add(message: AIEMessage(type: .error, message: "If the stride width or height is >= 1, then both the width and height must be >= 1.", on: self))
        } else if stride.width > 1 && stride.height > 1 {
            // We don't need to output if stride = 1, since that's the default.
            try context.output.write(", strides=(\(stride.width), \(stride.height))")
        }
        if dilation.width < 0 || dilation.height < 0 {
            context.add(message: AIEMessage(type: .error, message: "The width and height of dilation must both be positive integers.", on: self))
        } else if (dilation.width == 0 && dilation.height != 0) || (dilation.width != 0 && dilation.height == 0) {
            context.add(message: AIEMessage(type: .error, message: "If the dilation width or height is >= 1, then both the width and height must be >= 1.", on: self))
        } else if dilation.width > 1 && dilation.height > 1 {
            try context.output.write(", dilation_rate=(\(dilation.width), \(dilation.height))")
        }
        if paddingPolicy == .same {
            try context.output.write(", padding=\"same\"")
        } else if paddingPolicy == .usePaddingSize {
            // Not sure how to handle this with TensorFlow just yet.
            context.add(message: AIEMessage(type: .warning, message: "We don't handle the padding policy \"Use Padding Size\" in TensorFlow yet.", on: self))
        }
        try context.output.write(")")
        try appendParent(context: context)
        try context.output.write("\n")
        try progressToChild(context: context)
    }
}

extension AIELSTM : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws {
        try appendShapes(context: context)
        try context.output.write("layers.LTSM(units = \(self.units))")
    }
}

extension AIEUpsample : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws {
        try appendShapes(context: context)
        try context.output.write("layers.Conv2DTranspose(\(depth), (\(height), \(width)), \(step))")
    }
}

extension AIEPooling : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws {
        try appendShapes(context: context)
        try context.output.indent(context.indent).write("\(variableName) = layers.MaxPool2D((\(size.height), \(size.width)), \(stride.width))")
        try appendParent(context: context)
        try context.output.write("\n")
        try progressToChild(context: context)
    }
}

extension AIEReshape : AIETensorFlowCodeWriter {
    internal func generateCode(context: AIETensorFlowContext) throws {
        try appendShapes(context: context)
        try context.output.write("layers.Flatten()")
    }
}

extension AIEFullyConnected : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws {
        try appendShapes(context: context)
        try context.output.indent(context.indent).write("\(variableName) = layers.Dense(\(outputFeatureChannels))")
        if let parent = context.parent {
            try context.output.write("(Flatten()(\(parent.variableName)))")
        }
        try context.output.write("\n")
        try progressToChild(context: context)
    }
}

extension AIELoss : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws {
//        //try outputStream.write("# Loss layer")
//
//        //would need to compile the model to add loss
//        try prePrint(to: outputStream)
//
//        var loss_s: String
//        if (self.loss_type == 0){
//            loss_s = "losses.BinaryCrossentropy(from_logits=True)"
//        }
//        else if (self.loss_type == 1){
//            loss_s = "losses.CategoricalCrossentropy(from_logits=False)"
//        }
//        else {
//            loss_s = "losses.MeanSquaredError()"
//        }
//
//
//        var optimizer : String
//
//        if (self.optimization_type == 0){
//            optimizer = "optimizers.SGD(learning_rate=\(self.learning_rate))"
//        }
//        else if (self.optimization_type == 1){
//            optimizer = "optimizers.Adam(learning_rate=\(self.learning_rate))"
//        }
//        else {
//            optimizer = "optimizers.RMSprop(learning_rate=\(self.learning_rate))"
//        }
//
//
//        try outputStream.write("model.compile(loss=\(loss_s), optimizer=\(optimizer))")
//
//        try outputStream.write("# Loss type number: \(self.loss_type)")
//        try postPrint(to: outputStream)
    }
}

extension AIEActivation : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws {
        try appendShapes(context: context)
        try context.output.indent(context.indent).write("\(variableName) = ")
        if (type == .relu){
            try context.output.write("layers.Activation('relu')")
        } else if (type == .sigmoid){
            try context.output.write("layers.Activation('sigmoid')")
        } else {
            try context.output.write("layers.Activation('tanh')")
        }
        try appendParent(context: context)
        try context.output.write("\n")

        try progressToChild(context: context)
    }
}

extension AIESoftmax : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws {
        try appendShapes(context: context)
        try context.output.write("layers.Softmax(axis=-1)")
    }
}

extension AIEBatchNormalization : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws {
        try appendShapes(context: context)
        try context.output.write("layers.BatchNormalization(momentum = \(self.momentum), epsilon = \(self.epsilon))")
    }
}

extension AIELayerNormalization : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws {
        try appendShapes(context: context)
        try context.output.write("layers.LayerNormalization(epsilon = \(self.epsilon))")
    }
}

extension AIEDropout : AIETensorFlowCodeWriter {
    
    internal func generateCode(context: AIETensorFlowContext) throws {
        try appendShapes(context: context)
        try context.output.indent(context.indent).write("\(variableName) = layers.Dropout(rate=\(rate)")
        if seed != 0 {
            try context.output.write(", seed=\(seed)")
        }
        try context.output.write(")")
        try appendParent(context: context)
        try context.output.write("\n")
        try progressToChild(context: context)
    }
}

@objcMembers
open class AIETensorFlowCodeGenerator: AIECodeGenerator {

//    open func generateCode(for object: AIEGraphic, visited: inout Set<AIEGraphic>, to outputStream: OutputStream) throws -> Void {
//        if !visited.contains(object) {
//            visited.insert(object)
//
//            try outputStream.write("\n")
//
//            if let object = object as? AIETensorFlowCodeWriter {
//                try object.generateCode(to: outputStream)
//            } else {
//                try outputStream.write("# Generating: \(object.title)\n")
//            }
//
//            for child in object.destinationObjects {
//                try generateCode(for: child, visited: &visited, to: outputStream)
//            }
//        }
//    }

    public override func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        // First, we're going to look over our roots. All roots must be an IO node of some sort.
        iterateRoots { root in
            if !(root is AIEIO) {
                messages.append(AIEMessage(type: .error, message: "Network roots must begin on an IO node.", on: root))
            }
        }

        try outputStream.indent(0).write("#\n")
        try outputStream.indent(0).write("# \(info[.codeName] ?? "Anonymous").m\n")
        try outputStream.indent(0).write("#\n")
        try outputStream.indent(0).write("# Created by \(NSFullUserName()) on \(Self.simpleDateFormatter.string(from:Date()))\n")
        try outputStream.indent(0).write("#\n")
        try outputStream.indent(0).write("\n")
        try outputStream.indent(0).write("import numpy as np\n")
        try outputStream.indent(0).write("import tensorflow as tf\n")
        try outputStream.indent(0).write("\n")
        try outputStream.indent(0).write("from tensorflow import keras\n")
        try outputStream.indent(0).write("from tensorflow.keras import layers\n")
        try outputStream.indent(0).write("from tensorflow.keras import optimizers\n")
        try outputStream.indent(0).write("from tensorflow.keras import models\n")
        try outputStream.indent(0).write("\n")
        try outputStream.indent(0).write("class \(info[.codeName] ?? "Anonymous"):\n")
        try outputStream.indent(0).write("\n")

        try outputStream.indent(1).write("def __init__(self):\n")
        try outputStream.indent(2).write("pass\n")
        try outputStream.indent(0).write("\n")
        // Allow any nodes to initialize their ivar values if they declared an ivar (private or public) above. The don't necessarily need to do this.
//        var didGenerateOne = false
//        try iterateAllNodes { node in
//            if let node = node as? AIEMLComputeObjCWriter {
//                if !didGenerateOne {
//                    try outputStream.indent(0).write("\n")
//                    try outputStream.indent(2).write("// Initialize our descriptors\n")
//                    didGenerateOne = true
//                }
//                try node.generateCreationInsideInit(to: outputStream, accumulatingMessages: &messages)
//            }
//        }
//        try outputStream.indent(1).write("}\n")
        try outputStream.indent(0).write("\n")
        try outputStream.indent(1).write("def buildModel(self, isTraining=False):\n")
        try iterateRoots(using: { node in
            if let node = node as? AIETensorFlowCodeWriter {
                try node.generateCode(context: AIETensorFlowContext(outputStream: outputStream, indent: 2, messages: &messages))
            } else {
                try outputStream.indent(1).write("// \(Swift.type(of:node)) is not supported with TensorFlow.\n")
            }
        })
        try outputStream.indent(0).write("\n")
        try outputStream.indent(0).write("\n")
    }
/*
    {
        var visited = Set<AIEGraphic>()

        try outputStream.write("# Look ma! We're generating code.\n")
        try outputStream.write("# Application: \(ProcessInfo.processInfo.processName)\n")
        try outputStream.write("# Creator: \(NSUserName())\n")
        try outputStream.write("# Date: \(Date())\n")
        
        //start python code
        try outputStream.write("model = Sequental()")
        try generateCode(for: roots[0], visited: &visited, to: outputStream)
        
        
        try outputStream.write("\n# Code generation complete.\n")
    }
*/
}
