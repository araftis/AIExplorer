/*
 AIERMSPropOptimizer.swift
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
import Draw

public extension AIEOptimizerIndentifier {
    static var rmsProp = AIEOptimizerIndentifier("rmsProp")
}

@objcMembers
open class AIERMSPropOptimizer: AIEOptimizer {

    /// A hyper-parameter that specifies the momentum factor.
    var momentumScale: Float = 0.0
    /// The constant for smoothing.
    var alpha: Float = 0.9
    /// The epsilon value you use to improve numerical stability.
    var epsilon: Float = 1e-7
    /// A Boolean that indicates whether you compute the centered RMSProp.
    var isCentered: Bool = false
    
    // MARK: - AJRXMLCoding
    
    open override func decode(with coder: AJRXMLCoder) {
        coder.decodeFloat(forKey: "momentumScale") { value in
            self.momentumScale = value
        }
        coder.decodeFloat(forKey: "alpha") { value in
            self.alpha = value
        }
        coder.decodeFloat(forKey: "epsilon") { value in
            self.epsilon = value
        }
        coder.decodeBool(forKey: "isCentered") { value in
            self.isCentered = value
        }
    }
    
    open override func encode(with coder: AJRXMLCoder) {
        if momentumScale != 0.9 {
            coder.encode(momentumScale, forKey: "momentumScale")
        }
        if alpha != 0.999 {
            coder.encode(alpha, forKey: "alpha")
        }
        if epsilon != 1e-07 {
            coder.encode(epsilon, forKey: "epsilon")
        }
        if isCentered {
            coder.encode(isCentered, forKey: "isCentered")
        }
    }
    
    open override var ajr_nameForXMLArchiving: String {
        return "aieRMSPropOptimizer"
    }
    
    // MARK: - AIEMessageObject
    
    open override var messagesTitle: String {
        return "RMS Prop Optimizer"
    }
    
}
