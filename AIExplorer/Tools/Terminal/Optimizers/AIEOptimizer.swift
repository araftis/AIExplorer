/*
 AIEOptimizer.swift
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

public struct AIEOptimizerIndentifier : RawRepresentable, Equatable, Hashable {

    public typealias RawValue = String

    public var rawValue: String

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    static var unknown = AIEOptimizerIndentifier("unknown")
}

@objcMembers
open class AIEOptimizer: AJREditableObject, AJRXMLCoding, AIEMessageObject {
    
    @objcMembers
    public class OptimizerPlaceholder : NSObject, AJRInspectorContentProvider {
        var optimizerClass: AIEOptimizer.Type
        var name: String
        var id: AIEOptimizerIndentifier
        var localizedName : String {
            // TODO: If we ever get around to localizing, localize this.
            return name
        }
        
        public init(optimizerClass: AIEOptimizer.Type, name: String, id: AIEOptimizerIndentifier) {
            self.optimizerClass = optimizerClass
            self.name = name
            self.id = id
        }
        
        public var inspectorFilename: String? {
            return AJRStringFromClassSansModule(optimizerClass)
        }
        
        public var inspectorBundle: Bundle? {
            return Bundle(for: optimizerClass)
        }
        
    }

    // MARK: - Factory

    internal static var optimizersById = [AIEOptimizerIndentifier:OptimizerPlaceholder]()

    @objc(registerOptimizer:properties:)
    open class func register(optimizer: AIEOptimizer.Type, properties: [String:Any]) -> Void {
        if let optimizerClass = properties["class"] as? AIEOptimizer.Type,
           let rawId = properties["id"] as? String,
           let name = properties["name"] as? String {
            let identifier = AIEOptimizerIndentifier(rawValue: rawId)
            let placeholder = OptimizerPlaceholder(optimizerClass: optimizerClass, name: name, id: identifier)
            optimizersById[identifier] = placeholder
            AJRLog.in(domain: .drawPlugIn, level: .debug, message: "Optimizer: \(name) (\(optimizerClass))")
        } else {
            AJRLog.in(domain: .drawPlugIn, level: .error, message: "Received nonsense properties: \(properties)")
        }
    }
    
    open class var allOptimizers : [OptimizerPlaceholder] {
        return optimizersById.values.sorted { left, right in
            return left.name < right.name
        }
    }
    
    open class func optimizer(forId id: AIEOptimizerIndentifier) -> OptimizerPlaceholder? {
        return optimizersById[id]
    }
    
    open class func optimizer(forClass class: AIEOptimizer.Type) -> OptimizerPlaceholder? {
        for (_, value) in optimizersById {
            if value.optimizerClass == `class` {
                return value
            }
        }
        return nil
    }

    // MARK: - RegularizationType
    
    @objc
    public enum RegularizationType : Int, AJRXMLEncodableEnum {
        case none
        case l1
        case l2
        
        public var description: String {
            switch self {
            case .none: return "none"
            case .l1: return "l1"
            case .l2: return "l2"
            }
        }
        
        public var localizedDescription: String {
            switch self {
            case .none: return "None"
            case .l1: return "L1"
            case .l2: return "L2"
            }
        }
    }
    
    // MARK: - GradientClippingType
    
    @objc
    public enum GradientClippingType : Int, AJRXMLEncodableEnum {
        /// An option that clips by value.
        case byValue
        /// An option that clips by norm.
        case byNorm
        /// An option that clips by global norm.
        case byGlobalNorm
        
        public var description: String {
            switch self {
            case .byValue: return "byValue"
            case .byNorm: return "byNorm"
            case .byGlobalNorm: return "byGlobalNorm"
            }
        }
        
        public var localizedDescription: String {
            switch self {
            case .byValue: return "By Value"
            case .byNorm: return "By Norm"
            case .byGlobalNorm: return "By Global Norm"
            }
        }
        
    }
    
    // MARK: - Properties
    
    /// The learning rate.
    var learningRate: Float = 0.001
    /// The rescale value the optimizer applies to gradients during updates.
    var gradientRescale: Float? = nil
    // TODO: I feel like this could be a good use for property wrappers?
    var inspectedGradientRescale : NSNumber? { get { if let gradientRescale { return NSNumber(value: gradientRescale) } else { return nil } } set { gradientRescale = newValue?.floatValue }}
    /// A Boolean value that indicates whether you apply gradient clipping.
    var appliesGradientClipping: Bool = false
    /// The type of clipping the system applies to the gradient.
    var gradientClippingType: GradientClippingType = .byValue
    /// The maximum gradient value before the optimizer rescales the gradient, if you enable gradient clipping.
    var gradientClipMax: Float? = nil
    var inspectedGradientClipMax : NSNumber? { get { if let gradientClipMax { return NSNumber(value: gradientClipMax) } else { return nil } } set { gradientClipMax = newValue?.floatValue }}
    /// The minimum gradient value before the optimizer rescales the gradient, if you enable gradient clipping.
    var gradientClipMin: Float? = nil
    var inspectedGradientClipMin : NSNumber? { get { if let gradientClipMin { return NSNumber(value: gradientClipMin) } else { return nil } } set { gradientClipMin = newValue?.floatValue }}
    /// The maximum clipping value.
    var maximumClippingNorm: Float? = nil
    var inspectedMaximumClippingNorm : NSNumber? { get { if let maximumClippingNorm { return NSNumber(value: maximumClippingNorm) } else { return nil } } set { maximumClippingNorm = newValue?.floatValue }}
    /// A custom norm the system uses in place of the global norm.
    var customGlobalNorm: Float? = nil
    var inspectedCustomGlobalNorm : NSNumber? { get { if let customGlobalNorm { return NSNumber(value: customGlobalNorm) } else { return nil } } set { customGlobalNorm = newValue?.floatValue }}
    /// The regularization type.
    var regularizationType: RegularizationType = .none
    /// The regularization scale.
    var regularizationScale: Float? = nil
    var inspectedRegularizationScale : NSNumber? { get { if let regularizationScale { return NSNumber(value: regularizationScale) } else { return nil } } set { regularizationScale = newValue?.floatValue }}

    // MARK: - Creation
    
    public required override init() {
        super.init()
    }
    
    // MARK: - AJRXMLCoding
    
    open func decode(with coder: AJRXMLCoder) {
        coder.decodeFloat(forKey: "learningRate") { value in
            self.learningRate = value
        }
        coder.decodeBool(forKey: "appliesGradientClipping") { value in
            self.appliesGradientClipping = value
        }
        coder.decodeFloat(forKey: "gradientClipMax") { value in
            self.gradientClipMax = value
        }
        coder.decodeFloat(forKey: "gradientClipMin") { value in
            self.gradientClipMin = value
        }
        coder.decodeFloat(forKey: "regularizationScale") { value in
            self.regularizationScale = value
        }
        coder.decodeEnumeration(forKey: "regularizationType") { (value: RegularizationType?) in
            self.regularizationType = value ?? .none
        }
        coder.decodeEnumeration(forKey: "gradientClippingType") { (value: GradientClippingType?) in
            self.gradientClippingType = value ?? .byValue
        }
        coder.decodeFloat(forKey: "maximumClippingNorm") { value in
            self.maximumClippingNorm = value
        }
        coder.decodeFloat(forKey: "customGlobalNorm") { value in
            self.customGlobalNorm = value
        }
    }
    
    open func encode(with coder: AJRXMLCoder) {
        coder.encode(learningRate, forKey: "learningRate")
        if let gradientRescale {
            coder.encode(gradientRescale, forKey: "gradientRescale")
        }
        if appliesGradientClipping {
            coder.encode(appliesGradientClipping, forKey: "appliesGradientClipping")
        }
        if let gradientClipMax {
            coder.encode(gradientClipMax, forKey: "gradientClipMax")
        }
        if let gradientClipMin {
            coder.encode(gradientClipMin, forKey: "gradientClipMin")
        }
        if let regularizationScale {
            coder.encode(regularizationScale, forKey: "regularizationScale")
        }
        coder.encode(regularizationType, forKey: "regularizationType")
        coder.encode(gradientClippingType, forKey: "gradientClippingType")
        if let maximumClippingNorm {
            coder.encode(maximumClippingNorm, forKey: "maximumClippingNorm")
        }
        if let customGlobalNorm {
            coder.encode(customGlobalNorm, forKey: "customGlobalNorm")
        }
    }
    
    open override var ajr_nameForXMLArchiving: String {
        return "aieOptimizer"
    }
    
    // MARK: Conveniences

    open var localizedName : String? {
        return AIEOptimizer.optimizer(forClass: Self.self)?.localizedName
    }

    // MARK: - AIEMessageObject
    
    open var messagesTitle: String {
        return "Optimizer"
    }
    
    open var messagesImage: NSImage? {
        return nil
    }
    
}
