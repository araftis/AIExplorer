/*
 AIEConvolution+TensorFlow.swift
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

extension AIEConvolution : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendStandardCode(context: context) {
            try context.write("layers.Conv2D(\(outputFeatureChannels)")
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
            try context.output.write(", name='\(variableName)')")
        }
        try progressToChild(context: context)
        
        return true
    }
}

