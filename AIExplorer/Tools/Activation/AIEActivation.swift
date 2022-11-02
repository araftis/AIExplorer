/*
 AIEActivation.swift
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
    static var aiActivation = AJRInspectorIdentifier("aiActivation")
}

@objcMembers
open class AIEActivation: AIEGraphic {

    @objc
    public enum ActivationType : Int, AJRXMLEncodableEnum {
        case absolute
        case celu
        case clamp
        case elu
        case gelu
        case hardShrink
        case hardSigmoid
        case hardSwish
        case linear
        case logSigmoid
        case none
        case relu
        case relun
        case selu
        case sigmoid
        case softPlus
        case softShrink
        case softSign
        case tanh
        case tanhShrink
        case threshold

        public var description: String {
            switch self {
            case .absolute: return "absolute"
            case .celu: return "celu"
            case .clamp: return "clamp"
            case .elu: return "elu"
            case .gelu: return "gelu"
            case .hardShrink: return "hardShrink"
            case .hardSigmoid: return "hardSigmoid"
            case .hardSwish: return "hardSwish"
            case .linear: return "linear"
            case .logSigmoid: return "logSigmoid"
            case .none: return "none"
            case .relu: return "relu"
            case .relun: return "relun"
            case .selu: return "selu"
            case .sigmoid: return "sigmoid"
            case .softPlus: return "softPlus"
            case .softShrink: return "softShrink"
            case .softSign: return "softSign"
            case .tanh: return "tanh"
            case .tanhShrink: return "tanhShrink"
            case .threshold: return "threshold"
            }
        }

        public var localizedDescription: String {
            switch self {
            case .absolute: return "Absolute"
            case .celu: return "CELU"
            case .clamp: return "Clamp"
            case .elu: return "ELU"
            case .gelu: return "GELU"
            case .hardShrink: return "Hard Shrink"
            case .hardSigmoid: return "hard Sigmoid"
            case .hardSwish: return "Hard Swish"
            case .linear: return "Linear"
            case .logSigmoid: return "Log Sigmoid"
            case .none: return "None"
            case .relu: return "ReLU"
            case .relun: return "ReLUN"
            case .selu: return "SELU"
            case .sigmoid: return "Sigmoid"
            case .softPlus: return "Soft Plus"
            case .softShrink: return "Soft Shrink"
            case .softSign: return "Soft Sign"
            case .tanh: return "Tanh"
            case .tanhShrink: return "Tanh Shrink"
            case .threshold: return "Threshold"
            }
        }
    }
    
    // MARK: - Properties
    open var type : ActivationType = .none
    open var a: Float = 0.0
    open var b: Float = 0.0
    open var c: Float = 0.0
    
    // MARK: - Creation

    public convenience init(type: ActivationType, a: Float = 0.0, b: Float = 0.0, c: Float = 0.0) {
        self.init()
        self.type = type
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
        return [Property("Type", {
                        if let self = weakSelf {
                            return self.type.localizedDescription
                        }
                        return nil
                    }),
                Property("Alpha", {
                        if let self = weakSelf {
                            if self.type == .celu || self.type == .elu || self.type == .relun {
                                return String(describing: self.a)
                            }
                        }
                        return nil
                    }),
                Property("Beta", {
                        if let self = weakSelf {
                            if self.type == .relun {
                                return String(describing: self.b)
                            }
                            if self.type == .softPlus {
                                return String(describing: self.a)
                            }
                        }
                        return nil
                    }),
                Property("Min Value", {
                        if let self = weakSelf {
                            if self.type == .clamp {
                                return String(describing: self.a)
                            }
                        }
                        return nil
                    }),
                Property("Max Value", {
                        if let self = weakSelf {
                            if self.type == .clamp {
                                return String(describing: self.b)
                            }
                        }
                        return nil
                    }),
                Property("Lambda", {
                        if let self = weakSelf {
                            if self.type == .hardShrink || self.type == .softShrink {
                                return String(describing: self.a)
                            }
                        }
                        return nil
                    }),
                Property("Scale", {
                        if let self = weakSelf {
                            if self.type == .linear {
                                return String(describing: self.a)
                            }
                        }
                        return nil
                    }),
                Property("Bias", {
                        if let self = weakSelf {
                            if self.type == .linear {
                                return String(describing: self.b)
                            }
                        }
                        return nil
                    }),
                Property("Threshold", {
                        if let self = weakSelf {
                            if self.type == .threshold {
                                return String(describing: self.a)
                            }
                        }
                        return nil
                    }),
                Property("Replacement", {
                        if let self = weakSelf {
                            if self.type == .threshold {
                                return String(describing: self.b)
                            }
                        }
                        return nil
                    }),
        ]
    }

    // MARK: - AJRInspector

    open override var inspectorIdentifiers: [AJRInspectorIdentifier] {
        var identifiers = super.inspectorIdentifiers
        identifiers.append(.aiActivation)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeEnumeration(forKey: "type") { (value: ActivationType?) in
            self.type = value ?? .none
        }
        
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(type, forKey: "type")
    }

    
    
    open class override var ajr_nameForXMLArchiving: String {
        return "aieActivationLayer"
    }
    
    

}
