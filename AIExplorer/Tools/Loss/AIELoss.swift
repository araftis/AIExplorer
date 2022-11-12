/*
 AIELoss.swift
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
    static var aieLoss = AJRInspectorIdentifier("aieLoss")
}

@objcMembers
open class AIELoss: AIEGraphic {

    @objc
    public enum LossType : Int, AJRXMLEncodableEnum {
        case categoricalCrossEntropy
        case cosineDistance
        case hinge
        case huber
        case log
        case meanAbsoluteError
        case meanSquaredError
        case sigmoidCrossEntropy
        case softmaxCrossEntropy

        public var description: String {
            switch self {
            case .categoricalCrossEntropy: return "categoricalCrossEntropy"
            case .cosineDistance: return "cosineDistance"
            case .hinge: return "hinge"
            case .huber: return "huber"
            case .log: return "log"
            case .meanAbsoluteError: return "meanAbsoluteError"
            case .meanSquaredError: return "meanSquaredError"
            case .sigmoidCrossEntropy: return "sigmoidCrossEntropy"
            case .softmaxCrossEntropy: return "softmaxCrossEntropy"
            }
        }

        public var localizedDescription: String {
            switch self {
            case .categoricalCrossEntropy: return "Categorical Cross Entropy"
            case .cosineDistance: return "Cosine Distance"
            case .hinge: return "Hinge"
            case .huber: return "Huber"
            case .log: return "Log"
            case .meanAbsoluteError: return "Mean Absolute Error"
            case .meanSquaredError: return "Mean Squared Error"
            case .sigmoidCrossEntropy: return "Sigmoid Cross Entropy"
            case .softmaxCrossEntropy: return "Softmax Cross Entropy"
            }
        }
    }

    @objc
    public enum ReductionType : Int, AJRXMLEncodableEnum {
        case all
        case any
        case argMax
        case argMin
        case max
        case mean
        case min
        case none
        case sum
        case l1Norm

        public var description: String {
            switch self {
            case .all: return "all"
            case .any: return "any"
            case .argMax: return "argMax"
            case .argMin: return "argMin"
            case .max: return "max"
            case .mean: return "mean"
            case .min: return "min"
            case .none: return "none"
            case .sum: return "sum"
            case .l1Norm: return "l1Norm"
            }
        }

        public var localizedDescription: String {
            switch self {
            case .all: return "All"
            case .any: return "Any"
            case .argMax: return "Arg Max"
            case .argMin: return "Arg Min"
            case .max: return "Max"
            case .mean: return "Mean"
            case .min: return "Min"
            case .none: return "None"
            case .sum: return "Sum"
            case .l1Norm: return "L1 Norm"
            }
        }
    }

    // MARK: - Properties
    open var type : LossType = .softmaxCrossEntropy
    open var reductionType : ReductionType = .none
    open var weight : Float = 0.001
    open var labelSmoothing : Float = 0.001
    open var classCount : Int = 1
    open var epsilon : Float = 0.001
    open var delta : Float = 0.001

    // MARK: - Creation

    public convenience init(type: LossType) {
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
                Property("Reduction", {
                        if let self = weakSelf {
                            return self.reductionType.localizedDescription
                        }
                        return nil
                    }),
                Property("Smooth", {
                        if let self = weakSelf {
                            if self.type == .softmaxCrossEntropy
                                || self.type == .categoricalCrossEntropy
                                || self.type == .sigmoidCrossEntropy {
                                return String(describing: self.labelSmoothing)
                            }
                        }
                        return nil
                    }),
                Property("Class Count", {
                        if let self = weakSelf {
                            if self.type == .categoricalCrossEntropy
                                || self.type == .softmaxCrossEntropy {
                                return String(describing: self.classCount)
                            }
                        }
                        return nil
                    }),
                Property("Epsilon", {
                        if let self = weakSelf {
                            if self.type == .log {
                                return String(describing: self.epsilon)
                            }
                        }
                        return nil
                    }),
                Property("Delta", {
                        if let self = weakSelf {
                            if self.type == .huber {
                                return String(describing: self.delta)
                            }
                        }
                        return nil
                    }),
                Property("Weight", {
                        if let self = weakSelf {
                            return String(describing: self.weight)
                        }
                        return nil
                    }),
        ]
    }

    // MARK: - AJRInspector

    open override func inspectorIdentifiers(forInspectorContent inspectorContentIdentifier: AJRInspectorContentIdentifier?) -> [AJRInspectorIdentifier] {
        var supers = super.inspectorIdentifiers(forInspectorContent: inspectorContentIdentifier)
        if inspectorContentIdentifier == .graphic {
            supers.append(.aieLoss)
        }
        return supers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeEnumeration(forKey: "type") { (value: LossType?) in
            self.type = value ?? .softmaxCrossEntropy
        }
        coder.decodeEnumeration(forKey: "reductionType") { (value: ReductionType?) in
            self.reductionType = value ?? .none
        }
        coder.decodeFloat(forKey: "weight") { value in
            self.weight = value
        }
        coder.decodeFloat(forKey: "labelSmoothing") { value in
            self.labelSmoothing = value
        }
        coder.decodeInteger(forKey: "classCount") { value in
            self.classCount = value
        }
        coder.decodeFloat(forKey: "epsilon") { value in
            self.epsilon = value
        }
        coder.decodeFloat(forKey: "delta") { value in
            self.delta = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(type, forKey: "type")
        coder.encode(reductionType, forKey: "reductionType")
        coder.encode(weight, forKey: "weight")
        coder.encode(labelSmoothing, forKey: "labelSmoothing")
        coder.encode(classCount, forKey: "classCount")
        coder.encode(epsilon, forKey: "epsilon")
        coder.encode(delta, forKey: "delta")
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "aieLoss"
    }

}
