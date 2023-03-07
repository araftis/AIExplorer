//
//  TestAICodeGenerator.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/4/23.
//

import Cocoa

/**
 This implements a super simple code generator in python. It doesn't actually do anything "real", and it mostly exists to give new developers a rough idea of how to write a code generator.
 */
internal class TestAICodeGenerator: AIECodeGenerator {

    func generateNetwork(in context: AIECodeGeneratorContext) throws -> Void {
        context.begin(stage: .implementationHeader)
        // Tell the context what we're going to be writing.
        try context.writeComment("#")
        try context.writeComment("# \(info[.codeName] ?? "Anonymous").py")
        try context.writeComment("#")
        try context.writeComment("# Created by \(NSFullUserName()) on \(Self.simpleDateFormatter.string(from:Date()))")
        try context.writeComment("# Copyright © \(Self.yearDateFormatter.string(from:Date())), All rights reserved.")
        try context.writeComment("#")

        context.begin(stage: .implementationIncludes)
        // This is where we'd generate out imports, but we're going to skip that right now for simplicity's sake. See AIETensorFlowGenerator, AIEMLComputeObjCGenerator or AIEMLComputeSwiftGenerator for a more fleshed out example.
        try context.write("\n")
        try context.writeComment("We should really import something here.")

        // Let's predefine some documentation, since it looks nicer here than inline.
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

        // Now let's generate the model. For simplicity, let's just generate a simple sequential model, but let's do it in side a function call.
        try context.writeFunction(name: "build_model", type: .implementation, documentation: documentation) {
            try context.writeArgument(name: "is_training", value: "False")
        } body: {
            try context.write("model = Sequential([\n")
            try self.iterateRoots { root in
                // This calls context.begin() for us.
                try context.generateCode(for: root, in: .build)
            }
            try context.write("])\n")
        }
    }

    override func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        // First, create our generation context.
        let context = AIEMLComputeObjCContext(outputStream: outputStream, library: library, codeGenerator: self)

        // Next, we're going to look over our roots. All roots must be an IO node of some sort.
        validateRootNodes(in: context)

        // Finally, call out to a method to generate our network.
        try generateNetwork(in: context)

        messages.append(contentsOf: context.messages)
    }

}
