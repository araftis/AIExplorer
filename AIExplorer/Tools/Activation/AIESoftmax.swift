/*
 AIESoftmax.swift
 AIExplorer

 Copyright © 2021, AJ Raftis and AIExplorer authors
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
    static var aieSoftmax = AJRInspectorIdentifier("aieSoftmax")
}


@objcMembers
open class AIESoftmax: AIEGraphic {
    
    @objc
    public enum SoftmaxOperation : Int, AJRXMLEncodableEnum {
        case softmax
        case logSoftmax

        public var description: String {
            switch self {
            case .softmax: return "softmax"
            case .logSoftmax: return "logSoftmax"
            }
        }

        public var localizedDescription: String {
            switch self {
            case .softmax: return "Softmax"
            case .logSoftmax: return "Log Softmax"
            }
        }
    }
    // MARK: - Properties

    open var operation : SoftmaxOperation = .softmax
    open var dimension : Int = 0
    
    // MARK: - Creation

    public convenience init(dimension: Int) {
        self.init()

        self.dimension = dimension
    }

    public required init() {
        super.init()
    }

    public required init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    // MARK: - AIEGraphic

    open override var displayedProperties : [Property] {
        weak var weakSelf = self
        return [Property("Op", {
                        if let self = weakSelf {
                            return self.operation.localizedDescription
                        }
                        return nil
                    }),
                Property("Dimension", {
                        if let self = weakSelf {
                            if self.dimension != 0 {
                                return String(describing: self.dimension)
                            }
                        }
                        return nil
                    }),
        ]
    }

    // MARK: - AJRInspector

    open override func inspectorIdentifiers(forInspectorContent inspectorContentIdentifier: AJRInspectorContentIdentifier?) -> [AJRInspectorIdentifier] {
        var supers = super.inspectorIdentifiers(forInspectorContent: inspectorContentIdentifier)
        if inspectorContentIdentifier == .graphic {
            supers.append(.aieSoftmax)
        }
        return supers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeEnumeration(forKey: "operation") { (value: SoftmaxOperation?) in
            self.operation = value ?? .softmax
        }
        coder.decodeInteger(forKey: "dimension") { (value) in
            self.dimension = value
        }
        
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(operation, forKey: "operation")
        coder.encode(dimension, forKey: "dimension")
    }

    
    open class override var ajr_nameForXMLArchiving: String {
        return "aieSoftmaxLayer"
    }

    // MARK: - Shape

    open override var outputShape: [Int] {
        if let inputShape {
            // We just return the input shape, but in reality, softmax only works if we have one output channel (other than the batch size channel).
            return inputShape
        }
        return []
    }

}
