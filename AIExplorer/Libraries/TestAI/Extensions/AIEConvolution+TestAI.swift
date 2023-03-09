/*
 AIEConvolution+TestAI.swift
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
import Foundation

extension AIEConvolution : TestAICodeWriter {

    func createTestAICodeWriter() -> AIECodeWriter {
        TestAIConvolutionWriter(object: self)
    }

    internal class TestAIConvolutionWriter : AIETypedCodeWriter<AIEConvolution> {

        override func generateBuildCode(in context: AIECodeGeneratorContext) throws -> Bool {
            // This checks to make sure we only have one child. This is useful, because 99% of nodes should only have one child.
            validateSingleChild(in: context)

            // Appends a comment that shows are input and output shapes.
            try appendShapes(in: context)

            // Now we write a call to create our layer. Note that for our example, we're ignoring padding, stride, and dilation.
            try context.writeFunction(name: "Convolution", terminal: ",\n") {
                try context.writeArgument(value: "\(node.outputFeatureChannels)")
                if node.size.width == node.size.height {
                    try context.writeArgument(value: "\(node.size.height)")
                } else {
                    try context.writeArgument(value: "(\(node.size.height), \(node.size.width))")
                }
                try context.writeArgument(node.dilation.width != 1 && node.dilation.height != 1, name: "dilation_rate", value: "(\(node.dilation.width), \(node.dilation.height))")
                try context.writeArgument(name: "name", value: node.variableName)
            }

            // Now we progress to our next child. Like the validateSingleChild(context:) call above, this works for all nodes with one child. If a node has multiple children, you'll need to do something else.
            try progressToChild(in: context)

            // Finally return true, because we generated output.
            return true
        }

    }

}

