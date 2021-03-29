/*
AIELoss.swift
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

import Cocoa
import Draw


public extension AJRInspectorIdentifier {
    static var aiLoss = AJRInspectorIdentifier("aiLoss")
}

@objcMembers
open class AIELoss: AIEGraphic {

    // MARK: - Properties
    open var loss_type : Int = 0
    open var optimization_type : Int = 0
    open var learning_rate : Double = 0.001

    // MARK: - Creation

    public convenience init(loss_type: Int) {
        self.init()

        self.loss_type = loss_type
    }

    public required init() {
        super.init()
    }

    public required init(frame: NSRect) {
        super.init(frame: frame)
    }

    // MARK: - AJRInspector

    open override var inspectorIdentifiers: [AJRInspectorIdentifier] {
        var identifiers = super.inspectorIdentifiers
        identifiers.append(.aiLoss)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeInteger(forKey: "loss_type") { (value) in
            self.loss_type = value
        }
        
        coder.decodeInteger(forKey: "optimization_type") { (value) in
            self.loss_type = value
        }
        
        //coder.decodeInteger(forKey: "learning_rate") { (value) in
        //    self.loss_type = value
        //}
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(loss_type, forKey: "loss_type")
        coder.encode(loss_type, forKey: "optimization_type")
        //coder.encode(loss_type, forKey: "learning_rate")

    }

    
    open class override var ajr_nameForXMLArchiving: String {
        return "loss-layer"
    }

}
