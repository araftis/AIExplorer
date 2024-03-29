/*
 AIEMLComputeCodeGenerator.swift
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
open class AIEMLComputeCodeGenerator: AIECodeGenerator {

    override open func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
        var childGenerator : AIECodeGenerator? = nil
        
        if language.identifier == .objC {
            childGenerator = AIEMLComputeObjCGenerator(library: library, info: info, for: language, roots: roots)
        } else if language.identifier == .swift {
            childGenerator = AIEMLComputeSwiftGenerator(library: library, info: info, for: language, roots: roots)
        } else {
            for root in roots {
                messages.append(AIEMessage(type: .error, message: "Invalid language: \(language.name)", on: root))
            }
        }
        
        if let childGenerator = childGenerator {
            try childGenerator.generate(to: outputStream, accumulatingMessages: &messages)
        }
    }
    
    // MARK: - Conveniences
    
    public enum FileType {
        case objCInterface
        case objCImplementation
        case swift
    }

    var fileType : FileType {
        if info[.extension] == "h" {
            return .objCInterface
        } else if info[.extension] == "m" {
            return .objCImplementation
        }
        return .swift
    }

}
