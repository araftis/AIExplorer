/*
 AIEAdamOptimizer.swift
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
    static var adam = AIEOptimizerIndentifier("adam")
}

@objcMembers
open class AIEAdamOptimizer: AIEOptimizer {

    /// The coefficent for computing running averages of gradient.
    open var beta1: Float = 0.9
    /// The coefficent for computing running averages of square of gradient.
    open var beta2: Float = 0.999
    /// The epsilon value for improving numerical stability.
    open var epsilon: Float = 1e-07
    /// The initial timestep for the update.
    open var timeStep: Int = 1
    /// A Boolean value that indicates whether to use a variant of the algorithm.
    open var usesAMSGrad: Bool = false
    
    // MARK: - AJRXMLCoding
    
    open override func decode(with coder: AJRXMLCoder) {
        coder.decodeFloat(forKey: "beta1") { value in
            self.beta1 = value
        }
        coder.decodeFloat(forKey: "beta2") { value in
            self.beta2 = value
        }
        coder.decodeFloat(forKey: "epsilon") { value in
            self.epsilon = value
        }
        coder.decodeInteger(forKey: "timeStep") { value in
            self.timeStep = value
        }
        coder.decodeBool(forKey: "usesAMSGrad") { value in
            self.usesAMSGrad = value
        }
    }
    
    open override func encode(with coder: AJRXMLCoder) {
        if beta1 != 0.9 {
            coder.encode(beta1, forKey: "beta1")
        }
        if beta2 != 0.999 {
            coder.encode(beta2, forKey: "beta2")
        }
        if epsilon != 1e-07 {
            coder.encode(epsilon, forKey: "epsilon")
        }
        if timeStep != 1 {
            coder.encode(timeStep, forKey: "timeStep")
        }
        if usesAMSGrad {
            coder.encode(usesAMSGrad, forKey: "usesAMSGrad")
        }
    }
    
    open override var ajr_nameForXMLArchiving: String {
        return "aieAdamOptimizer"
    }
    
    // MARK: - AIEMessageObject
    
    open override var messagesTitle: String {
        return "Adam Optimizer"
    }
    
}
