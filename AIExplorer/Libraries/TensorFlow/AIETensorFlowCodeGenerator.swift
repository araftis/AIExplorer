/*
 AIETensorFlowCodeGenerator.swift
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
open class AIETensorFlowCodeGenerator: AIECodeGenerator {

    internal func generateHeader(using context: AIECodeGeneratorContext) throws -> Void {
        context.stage = .implementationHeader
        
        try context.write("#\n")
        try context.write("# \(info[.codeName] ?? "Anonymous").py\n")
        try context.write("#\n")
        try context.write("# Created by \(NSFullUserName()) on \(Self.simpleDateFormatter.string(from:Date()))\n")
        try context.write("# Copyright © \(Self.yearDateFormatter.string(from:Date())), All rights reserved.\n")
        try context.write("#\n")

        // Handle Licenses
        context.stage = .licenses
        try generateLicenses(using: context)

        var imports = [
            "import numpy as np", 
            "import tensorflow as tf",
            "from tensorflow import keras",
            "from tensorflow.keras import layers",
            "from tensorflow.keras import optimizers",
            "from tensorflow.keras import models",
            "from tensorflow.keras import losses",
            "from tensorflow.keras import optimizers",
        ]

        iterateRoots { root in
            root.iterateGraph { node, stop in
                let additional = context.imports(for: node)
                for importString in additional {
                    if !imports.contains(importString) {
                        imports.append(importString)
                    }
                }
            }
        }

        // And finally, all the import statements we'll need.
        context.stage = .implementationIncludes
        try context.write("\n")
        for importStatement in imports {
            try context.write("\(importStatement)\n")
        }
    }
    
    internal func generateLicenses(using context: AIECodeGeneratorContext) throws -> Void {
        var licenses = [String]()
        iterateRoots { root in
            root.iterateGraph { node, stop in
                if let license = context.license(for: node) {
                    licenses.append(license)
                }
            }
        }
        for (index, license) in licenses.enumerated() {
            if index > 0 {
                try context.write("#\n")
            }
            try context.write(license.byWrapping(to: 75, prefix: "# ", lineSeparator: "\n", splitURLs: false))
            try context.write("\n")
        }
    }
    
    internal func generateClass(for node: AIETensorFlowCodeWriter, using context: AIECodeGeneratorContext) throws -> Void {
        try context.write("\n")
        try context.write("class \(info[.codeName] ?? "Anonymous"):\n")
        try context.write("\n")
        
        try context.indent {
            // Create the init method.
            try context.writeFunction(name: "__init__", type: .implementation) {
                try context.writeArgument(name: "self")
                try context.generateCode(for: node, in: .initArguments)
            } body: {
                let wroteCode = try context.generateCode(for: node, in: .initialization)
                if !wroteCode  {
                    try context.write("pass\n")
                }
            }
            
            // Write any additional methods desired by our nodes.
            try context.generateCode(for: node, in: .implementationMethods)
            
            // Declare the build method. This actually builds and compiles.
            try context.write("\n")
            let documentation = """
            This method builds your model if it doesn't already exist. The more built is based on the model designed with AI Explorer. If `isTraining` is `False`, then the model is built ready for inference, otherwise it's built for training. As part of being built for training, the model will be compiled using the supplied loss and optimization options chosen in the modeler.
            
            Parameters
            ----------
            isTraining : boolean
                Determines whether the model is built for training or not.
            
            Returns
            -------
            A TensorFlow model ready for training or inference.
            """
            try context.writeFunction(name: "build_model", type: .implementation, documentation: documentation) {
                try context.writeArgument(name: "self")
                try context.writeArgument(name: "isTraining", value: "False")
            } body: {
                try context.writeComment("Let's see if the model's already created, and just return it if it is.\n")
                try context.write("if isTraining:\n")
                try context.indent {
                    try context.write("if hasattr(self, 'model_training'):\n")
                    try context.indent {
                        try context.write("return self.model_training\n")
                    }
                }
                try context.write("else:\n")
                try context.indent {
                    try context.write("if hasattr(self, 'model_inference'):\n")
                    try context.indent {
                        try context.write("return self.model_inference\n")
                    }
                }
                
                // Write the model declaration.
                try context.write("\n")
                try context.writeComment("Define the model as a Sequential model. This should cover most situations, but there's a good chance we'll need to improve this in the future.\n")
                try context.write("model = models.Sequential(")
                if let name = self.info[.codeName] {
                    try context.write("name='\(name)'")
                }
                try context.write(")\n")
                try context.write("\n")
                
                // And generate the model.
                try context.generateCode(for: node, in: .build)
                
                try context.write("\n")
                try context.write("if isTraining:\n")
                try context.indent {
                    try context.write("self.model_training = model\n")
                }
                try context.write("else:\n")
                try context.indent {
                    try context.write("self.model_inference = model\n")
                }
                
                // And finally return the model.
                try context.write("\n")
                try context.write("return model\n")
            }
            
            try context.write("\n")
            try context.writeFunction(name: "train", type: .implementation) {
                try context.writeArgument(name: "self")
                try context.writeArgument(name: "batch_size", value: "128")
            } body: {
                try context.write("model = self.build_model(isTraining=True)\n")
            }
            
            try context.write("\n")
            try context.writeFunction(name: "infer", type: .implementation) {
                try context.writeArgument(name: "self")
            } body: {
                try context.write("model = self.build_model(isTraining=False)\n")
            }
        }
    }

    public override func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        // First, we're going to look over our roots. All roots must be an IO node of some sort.
        iterateRoots { root in
            if !(root is AIEIO) {
                messages.append(AIEMessage(type: .error, message: "Network roots must begin on an IO node.", on: root))
            }
        }
        
        let context = AIETensorFlowContext(outputStream: outputStream)
        
        try generateHeader(using: context)

        // TODO: Make this smarter. If we're going to allow multiple roots, we need to make sure we generate a class for each root, but that also means we need to attach the name of the neural net to the root node, which is an I/O node? Need to think about that last thing.
        try iterateRoots { node in
            if let node = node as? AIETensorFlowCodeWriter {
                try generateClass(for: node, using: context)
            } else {
                messages.append(AIEMessage(type: .error, message: "\(Swift.type(of:node)) is not supported with TensorFlow.", on: node))
                try context.write("// \(Swift.type(of:node)) is not supported with TensorFlow.\n")
            }
        }
        try context.write("\n")
        try context.write("\n")
        
        messages.append(contentsOf: context.messages)
    }
    
}
