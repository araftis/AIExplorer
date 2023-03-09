/*
 TestAICodeGenerator.swift
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

/**
 This implements a super simple code generator in python. It doesn't actually do anything "real", and it mostly exists to give new developers a rough idea of how to write a code generator.
 */
internal class TestAICodeGenerator: AIECodeGenerator {

    func generateNetwork(in context: AIECodeGeneratorContext) throws -> Void {
            // First write out a file header. Note that we don't include the body, because we don't need to write anything additional.
            try context.writeFileHeader(for: .implementationHeader, info: info)

        // And then imports.
        try context.writeImports(for: .implementationIncludes) {
            try context.writeImport("import numpy as np")
            try context.writeImport("import tensorflow as tf")
            try context.writeImport("from tensorflow import keras")
            try context.writeImport("from tensorflow.keras import layers")
            try context.writeImport("from tensorflow.keras import optimizers")
            try context.writeImport("from tensorflow.keras import models")
            try context.writeImport("from tensorflow.keras import losses")
            try context.writeImport("from tensorflow.keras import optimizers")
         }
        try context.write("\n")

        // Let's predefine some documentation, since it looks nicer here than inline.
        let documentation = """
        This function builds the model. The model built is based on the model designed with AI Explorer. If `is_training` is `False`, then the model is built ready for inference, otherwise it's built for training. As part of being built for training, the model will be compiled using the supplied loss and optimization options chosen in the modeler.

        Parameters
        ----------
        isTraining : boolean
            Determines whether the model is built for training or not.

        Returns
        -------
        A TensorFlow model ready for training or inference.
        """

        // Now let's generate the model. For simplicity, let's just generate a simple sequential model, but let's do it in side a function call.
        try context.writeFunction(name: "build_model", type: .implementation, documentation: documentation) {
            try context.writeArgument(name: "is_training", value: "False")
        } body: {
            try context.write("model = Sequential([\n")
            try context.indent {
                try self.iterateRoots { root in
                    // This calls context.begin() for us.
                    try context.generateCode(for: root, in: .build)
                }
            }
            try context.write("])\n")
        }
    }

    override func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        // First, create our generation context.
        let context = TestAICodeGeneratorContext(outputStream: outputStream, library: library, codeGenerator: self)

        // Next, we're going to look over our roots. All roots must be an IO node of some sort.
        validateRootNodes(in: context)

        // Finally, call out to a method to generate our network.
        try generateNetwork(in: context)

        messages.append(contentsOf: context.messages)
    }

}
