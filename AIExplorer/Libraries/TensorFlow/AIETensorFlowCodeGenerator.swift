/*
AIETensorFlowCodeGenerator.swift
AIExplorer

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

//decode and encode float value, look at batch nromalization file, loss=learning_rate

import Cocoa

func prePrint(to outputStream: OutputStream) throws {
    try outputStream.write("model.add(")
}

func postPrint(to outputStream: OutputStream) throws {
    try outputStream.write(")")
}




public protocol AIETensorFlowCodeWriter {

    func generateCode(to outputStream: OutputStream) throws -> Void

}

extension AIEImageIO : AIETensorFlowCodeWriter {

    public func generateCode(to outputStream: OutputStream) throws {
        //try outputStream.write("# Image IO Layer\n")
        
        try prePrint(to: outputStream)
        try outputStream.write("tf.keras.Input(shape=(\(self.height), \(self.width), \(self.depth))")
        try postPrint(to: outputStream)
    }
}


extension AIEConvolution : AIETensorFlowCodeWriter {

    public func generateCode(to outputStream: OutputStream) throws {
        //try outputStream.write("# We're writing a convolution layer. \(self.title)\n")

        try prePrint(to: outputStream)
        try outputStream.write("tf.keras.layers.Conv2D(\(3/*self.depth*/), (\(height), \(width)), \(stride))")
        try postPrint(to: outputStream)
    }
}


extension AIELSTM : AIETensorFlowCodeWriter {

    public func generateCode(to outputStream: OutputStream) throws {
        //try outputStream.write("# We're writing a convolution layer. \(self.title)\n")

        try prePrint(to: outputStream)
        try outputStream.write("tf.keras.layers.LTSM(units = \(self.units))")
        try postPrint(to: outputStream)
    }
}

extension AIEUpsample : AIETensorFlowCodeWriter {

    public func generateCode(to outputStream: OutputStream) throws {
        //try outputStream.write("# We're writing a convolution layer. \(self.title)\n")

        try prePrint(to: outputStream)
        try outputStream.write("tf.keras.layers.Conv2DTranspose(\(self.depth), (\(self.height), \(self.width)), \(self.step))")
        try postPrint(to: outputStream)
    }
}

extension AIEPooling : AIETensorFlowCodeWriter {

    public func generateCode(to outputStream: OutputStream) throws {
        //try outputStream.write("# We're writing a convolution layer. \(self.title)\n")

        try prePrint(to: outputStream)
        try outputStream.write("tf.keras.layers.MaxPool2D((\(self.height), \(self.width)), \(self.strideX))")
        try postPrint(to: outputStream)
    }
}

extension AIEReshape : AIETensorFlowCodeWriter {
    public func generateCode(to outputStream: OutputStream) throws {
        //try outputStream.write("# We're writing a convolution layer. \(self.title)\n")

        try prePrint(to: outputStream)
        try outputStream.write("tf.keras.layers.Flatten()")
        try postPrint(to: outputStream)
    }
}

extension AIEFullyConnected : AIETensorFlowCodeWriter{
    
    public func generateCode(to outputStream: OutputStream) throws {
        //try outputStream.write("# Fully connected layer")
        
        try prePrint(to: outputStream)
        try outputStream.write("tf.keras.layers.Dense(\(self.dimension))")
        try postPrint(to: outputStream)
    }
}

extension AIELoss : AIETensorFlowCodeWriter{
    
    public func generateCode(to outputStream: OutputStream) throws {
//        //try outputStream.write("# Loss layer")
//
//        //would need to compile the model to add loss
//        try prePrint(to: outputStream)
//
//        var loss_s: String
//        if (self.loss_type == 0){
//            loss_s = "tf.keras.losses.BinaryCrossentropy(from_logits=True)"
//        }
//        else if (self.loss_type == 1){
//            loss_s = "tf.keras.losses.CategoricalCrossentropy(from_logits=False)"
//        }
//        else {
//            loss_s = "tf.keras.losses.MeanSquaredError()"
//        }
//
//
//        var optimizer : String
//
//        if (self.optimization_type == 0){
//            optimizer = "tf.keras.optimizers.SGD(learning_rate=\(self.learning_rate))"
//        }
//        else if (self.optimization_type == 1){
//            optimizer = "tf.keras.optimizers.Adam(learning_rate=\(self.learning_rate))"
//        }
//        else {
//            optimizer = "tf.keras.optimizers.RMSprop(learning_rate=\(self.learning_rate))"
//        }
//
//
//        try outputStream.write("model.compile(loss=\(loss_s), optimizer=\(optimizer))")
//
//        try outputStream.write("# Loss type number: \(self.loss_type)")
//        try postPrint(to: outputStream)
    }
}



extension AIEActivation : AIETensorFlowCodeWriter{
    
    public func generateCode(to outputStream: OutputStream) throws {
        //try outputStream.write("# Activation layer")
        
        try prePrint(to: outputStream)
        if (type == .relu){
            try outputStream.write("tf.keras.layers.Activation('relu')")
        } else if (type == .sigmoid){
            try outputStream.write("tf.keras.layers.Activation('sigmoid')")
        } else {
            try outputStream.write("tf.keras.layers.Activation('tanh')")
        }
        try postPrint(to: outputStream)
    }
}


extension AIESoftmax : AIETensorFlowCodeWriter{
    
    public func generateCode(to outputStream: OutputStream) throws {
        try prePrint(to: outputStream)
        try outputStream.write("tf.keras.layers.Softmax(axis=-1)")
        try postPrint(to: outputStream)
    }
}

extension AIEBatchNormalization : AIETensorFlowCodeWriter{
    
    public func generateCode(to outputStream: OutputStream) throws {
        
        try prePrint(to: outputStream)
        try outputStream.write("tf.keras.layers.BatchNormalization(momentum = \(self.momentum), epsilon = \(self.epsilon))")
        try postPrint(to: outputStream)
    }
}


extension AIELayerNormalization : AIETensorFlowCodeWriter{
    
    public func generateCode(to outputStream: OutputStream) throws {
        
        try prePrint(to: outputStream)
        try outputStream.write("tf.keras.layers.LayerNormalization(epsilon = \(self.epsilon))")
        try postPrint(to: outputStream)
    }
}



extension AIEDropout : AIETensorFlowCodeWriter{
    
    public func generateCode(to outputStream: OutputStream) throws {
        
        try prePrint(to: outputStream)
        try outputStream.write("tf.keras.layers.Dropout(rate = \(self.rate))")
        try postPrint(to: outputStream)
    }
}





@objcMembers
open class AIETensorFlowCodeGenerator: AIECodeGenerator {

    open func generateCode(for object: AIEGraphic, visited: inout Set<AIEGraphic>, to outputStream: OutputStream) throws -> Void {
        if !visited.contains(object) {
            visited.insert(object)

            try outputStream.write("\n")

            if let object = object as? AIETensorFlowCodeWriter {
                try object.generateCode(to: outputStream)
            } else {
                try outputStream.write("# Generating: \(object.title)\n")
            }

            for child in object.destinationObjects {
                try generateCode(for: child, visited: &visited, to: outputStream)
            }
        }
    }

    public override func generate(to outputStream: OutputStream, accumulatingMessages message: inout [AIEMessage]) throws -> Void {
        var visited = Set<AIEGraphic>()

        try outputStream.write("# Look ma! We're generating code.\n")
        try outputStream.write("# Application: \(ProcessInfo.processInfo.processName)\n")
        try outputStream.write("# Creator: \(NSUserName())\n")
        try outputStream.write("# Date: \(Date())\n")
        
        //start python code
        try outputStream.write("model = tf.keras.Sequental()")
        try generateCode(for: roots[0], visited: &visited, to: outputStream)
        
        
        try outputStream.write("\n# Code generation complete.\n")
    }

}
