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

    internal func generateHeader(using context: AIETensorFlowContext) throws -> Void {
        context.stage = .header
        
        try context.write("#\n")
        try context.write("# \(info[.codeName] ?? "Anonymous").m\n")
        try context.write("#\n")
        try context.write("# Created by \(NSFullUserName()) on \(Self.simpleDateFormatter.string(from:Date()))\n")
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
                guard let node = node as? AIETensorFlowCodeWriter else { return }
                let additional = node.imports
                for importString in additional {
                    if !imports.contains(importString) {
                        imports.append(importString)
                    }
                }
            }
        }

        // And finally, all the import statements we'll need.
        context.stage = .imports
        try context.write("\n")
        for importStatement in imports {
            try context.write("\(importStatement)\n")
        }
    }
    
    internal func generateLicenses(using context: AIETensorFlowContext) throws -> Void {
        var licenses = [String]()
        iterateRoots { root in
            root.iterateGraph { child, stop in
                if let child = child as? AIETensorFlowCodeWriter,
                   let license = child.license {
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
    
    internal func generateClass(for node: AIETensorFlowCodeWriter, using context: AIETensorFlowContext) throws -> Void {
        try context.write("\n")
        try context.write("class \(info[.codeName] ?? "Anonymous"):\n")
        try context.write("\n")
        
        // Create the init method.
        context.stage = .initArguments
        try context.writeFunctionDef(name: "__init__") {
            try context.writeArgument("self")
            try node.generateInitArguments(context: context)
        } body: {
            context.stage = .initialization
            let wroteCode = try node.generateInitializationCode(context: context)
            if !wroteCode  {
                try context.writeIndented("pass\n")
            }
        }

        // Write any additional methods desired by our nodes.
        context.stage = .methods
        try node.generateMethodsCode(context: context)

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
        try context.writeFunctionDef(name: "build_model", documentation: documentation) {
            try context.writeArgument("self")
            try context.writeArgument("isTraining=False")
        } body: {
            context.stage = .build

            try context.writeComment("Let's see if the model's already created, and just return it if it is.\n")
            try context.writeIndented("if isTraining:\n")
            try context.indent {
                try context.writeIndented("if hasattr(self, 'model_training'):\n")
                try context.indent {
                    try context.writeIndented("return self.model_training\n")
                }
            }
            try context.writeIndented("else:\n")
            try context.indent {
                try context.writeIndented("if hasattr(self, 'model_inference'):\n")
                try context.indent {
                    try context.writeIndented("return self.model_inference\n")
                }
            }

            // Write the model declaration.
            try context.write("\n")
            try context.writeComment("Define the model as a Sequential model. This should cover most situations, but there's a good chance we'll need to improve this in the future.\n")
            try context.writeIndented("model = models.Sequential(")
            if let name = self.info[.codeName] {
                try context.write("name='\(name)'")
            }
            try context.write(")\n")
            try context.write("\n")
            
            // And generate the model.
            try node.generateCode(context: context)

            try context.write("\n")
            try context.writeIndented("if isTraining:\n")
            try context.indent {
                try context.writeIndented("self.model_training = model\n")
            }
            try context.writeIndented("else:\n")
            try context.indent {
                try context.writeIndented("self.model_inference = model\n")
            }

            // And finally return the model.
            try context.write("\n")
            try context.writeIndented("return model\n")
        }

        try context.write("\n")
        try context.writeFunctionDef(name: "train") {
            try context.writeArgument("self")
            try context.writeArgument("batch_size=128")
        } body: {
            try context.writeIndented("model = self.build_model(isTraining=True)\n")
        }

        try context.write("\n")
        try context.writeFunctionDef(name: "infer") {
            try context.writeArgument("self")
        } body: {
            try context.writeIndented("model = self.build_model(isTraining=False)\n")
        }
    }

    public override func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        // First, we're going to look over our roots. All roots must be an IO node of some sort.
        iterateRoots { root in
            if !(root is AIEIO) {
                messages.append(AIEMessage(type: .error, message: "Network roots must begin on an IO node.", on: root))
            }
        }
        
        let context = AIETensorFlowContext(outputStream: outputStream, indent: 1)
        
        try generateHeader(using: context)

        // TODO: Make this smarter. If we're going to allow multiple roots, we need to make sure we generate a class for each root, but that also means we need to attach the name of the neural net to the root node, which is an I/O node? Need to think about that last thing.
        try iterateRoots { node in
            if let node = node as? AIETensorFlowCodeWriter {
                try generateClass(for: node, using: context)
            } else {
                messages.append(AIEMessage(type: .error, message: "\(Swift.type(of:node)) is not supported with TensorFlow.", on: node))
                try outputStream.indent(1).write("// \(Swift.type(of:node)) is not supported with TensorFlow.\n")
            }
        }
        try outputStream.indent(0).write("\n")
        try outputStream.indent(0).write("\n")
        
        messages.append(contentsOf: context.messages)
    }
    
}
