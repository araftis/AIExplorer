/*
 AIELoss.swift
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
import Draw

public struct AIELossIndentifier : RawRepresentable, Equatable, Hashable {

    public typealias RawValue = String

    public var rawValue: String

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public static var unknown = AIELossIndentifier("unknown")
}

@objcMembers
open class AIELoss: AJREditableObject, AJRXMLCoding, AIEMessageObject {

    @objcMembers
    public class LossPlaceholder : NSObject, AJRInspectorContentProvider {

        var lossClass: AIELoss.Type
        var name: String
        var id: AIELossIndentifier
        var localizedName : String {
            // TODO: If we ever get around to localizing, localize this.
            return name
        }

        public init(lossClass: AIELoss.Type, name: String, id: AIELossIndentifier) {
            self.lossClass = lossClass
            self.name = name
            self.id = id
        }

        public var inspectorFilename: String? {
            return AJRStringFromClassSansModule(lossClass)
        }

        public var inspectorBundle: Bundle? {
            return Bundle(for: lossClass)
        }

    }

    // MARK: - Factory

    internal static var lossesById = [AIELossIndentifier:LossPlaceholder]()

    @objc(registerLoss:properties:)
    open class func register(loss: AIELoss.Type, properties: [String:Any]) -> Void {
        if let lossClass = properties["class"] as? AIELoss.Type,
           let rawId = properties["id"] as? String,
           let name = properties["name"] as? String {
            let identifier = AIELossIndentifier(rawValue: rawId)
            let placeholder = LossPlaceholder(lossClass: lossClass, name: name, id: identifier)
            lossesById[identifier] = placeholder
            AJRLog.in(domain: .drawPlugIn, level: .debug, message: "Loss: \(name) (\(lossClass))")
        } else {
            AJRLog.in(domain: .drawPlugIn, level: .error, message: "Received nonsense properties: \(properties)")
        }
    }

    open class var allLosses : [LossPlaceholder] {
        return lossesById.values.sorted { left, right in
            return left.name < right.name
        }
    }

    open class func loss(forId id: AIELossIndentifier) -> LossPlaceholder? {
        return lossesById[id]
    }

    open class func loss(forClass class: AIELoss.Type) -> LossPlaceholder? {
        for (_, value) in lossesById {
            if value.lossClass == `class` {
                return value
            }
        }
        return nil
    }

    open class func lossId(forClass class: AIELoss.Type) -> AIELossIndentifier? {
        if let placeholder = loss(forClass: `class`) {
            return placeholder.id
        }
        return nil
    }

    // MARK: -

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
    
    open var reductionType : ReductionType = .none
    open var weight : Float = 0.001

    // MARK: - Creation

    public required override init() {
        super.init()
    }

    // MARK: Conveniences

    open var localizedName : String? {
        return AIELoss.loss(forClass: Self.self)?.localizedName
    }

// TODO: Move to AIETerminus
//     MARK: - AIEGraphic
//
//    open override var displayedProperties : [Property] {
//        weak var weakSelf = self
//        return [Property("Type", {
//                        if let self = weakSelf {
//                            return self.type.localizedDescription
//                        }
//                        return nil
//                    }),
//                Property("Reduction", {
//                        if let self = weakSelf {
//                            return self.reductionType.localizedDescription
//                        }
//                        return nil
//                    }),
//                Property("Smooth", {
//                        if let self = weakSelf {
//                            if self.type == .softmaxCrossEntropy
//                                || self.type == .categoricalCrossEntropy
//                                || self.type == .sigmoidCrossEntropy {
//                                return String(describing: self.labelSmoothing)
//                            }
//                        }
//                        return nil
//                    }),
//                Property("Class Count", {
//                        if let self = weakSelf {
//                            if self.type == .categoricalCrossEntropy
//                                || self.type == .softmaxCrossEntropy {
//                                return String(describing: self.classCount)
//                            }
//                        }
//                        return nil
//                    }),
//                Property("Epsilon", {
//                        if let self = weakSelf {
//                            if self.type == .log {
//                                return String(describing: self.epsilon)
//                            }
//                        }
//                        return nil
//                    }),
//                Property("Delta", {
//                        if let self = weakSelf {
//                            if self.type == .huber {
//                                return String(describing: self.delta)
//                            }
//                        }
//                        return nil
//                    }),
//                Property("Weight", {
//                        if let self = weakSelf {
//                            return String(describing: self.weight)
//                        }
//                        return nil
//                    }),
//        ]
//    }
//
    // MARK: - AJRXMLCoding

    open func decode(with coder: AJRXMLCoder) {
        coder.decodeEnumeration(forKey: "reductionType") { (value: ReductionType?) in
            self.reductionType = value ?? .none
        }
        coder.decodeFloat(forKey: "weight") { value in
            self.weight = value
        }
    }

    open func encode(with coder: AJRXMLCoder) {
        coder.encode(reductionType, forKey: "reductionType")
        coder.encode(weight, forKey: "weight")
    }

    open class override var ajr_nameForXMLArchiving: String {
        if let id = lossId(forClass: self.self) {
            return "aie" + id.rawValue.capitalized
        }
        return "aieLoss"
    }

    // MARK: - AIEMessageObject
    
    open var messagesTitle: String {
        return "Loss"
    }
    
    open var messagesImage: NSImage? {
        return nil
    }
    
}
