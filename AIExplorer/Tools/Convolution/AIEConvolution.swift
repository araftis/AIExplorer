/*
 AIEConvolution.swift
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

import Draw

public extension AJRInspectorIdentifier {
    static var aieConvolution = AJRInspectorIdentifier("aieConvolution")
}

@objcMembers
open class AIEConvolution: AIEGraphic {

    @objc
    public enum `Type` : Int, AJRXMLEncodableEnum {
        case standard
        case depthwise
        case transposed

        public var description: String {
            switch self {
            case .standard: return "standard"
            case .depthwise: return "depthwise"
            case .transposed: return "transposed"
            }
        }

        public var localizedDescription: String {
            switch self {
            case .standard: return "Standard"
            case .depthwise: return "Depthwise"
            case .transposed: return "Transposed"
            }
        }

    }
    
    @objc
    public enum PaddingPolicy : Int, AJRXMLEncodableEnum {
        case same
        case valid
        case usePaddingSize

        public var description: String {
            switch self {
            case .same: return "same"
            case .valid: return "valid"
            case .usePaddingSize: return "usePaddingSize"
            }
        }

        public var localizedDescription : String {
            switch self {
            case .same: return "Same"
            case .valid: return "Valid"
            case .usePaddingSize: return "Use Padding Size"
            }
        }

    }

    // MARK: - Properties
    open var type : `Type` = .standard
    open var width : Int = 0
    open var height : Int = 0
    open var depth : Int = 0
    open var inputFeatureChannels : Int = 0
    open var outputFeatureChannels : Int = 0
    open var dilation : Int = 0
    open var stride : Int = 0
    open var paddingPolicy : PaddingPolicy = .same
    open var paddingSize : Int = 0

    // MARK: - Creation

    public convenience init(width: Int, height: Int, depth: Int, step : Int) {
        self.init()

        self.width = width
        self.height = height
        self.depth = height
        self.stride = stride
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
                Property("Size", {
                        if let self = weakSelf {
                            var string = ""
                            if self.width > 0 || self.height > 0 {
                                string += "\(self.width) ✕ \(self.height)"
                            }
                            if self.depth > 0 {
                                if !string.isEmpty {
                                    string += " ✕ "
                                }
                                string += "\(self.depth)"
                            }
                            return string.isEmpty ? nil : string
                        }
                        return nil
                    }),
                Property("FC", {
                        if let self = weakSelf {
                            if self.inputFeatureChannels > 0 || self.outputFeatureChannels > 0 {
                                return "\(self.inputFeatureChannels) → \(self.outputFeatureChannels)"
                            }
                        }
                        return nil
                    }),
                Property("Dilation", {
                        if let self = weakSelf {
                            return self.dilation > 0 ? String(describing: self.dilation) : nil
                        }
                        return nil
                    }),
                Property("Stride", {
                        if let self = weakSelf {
                            return self.stride > 0 ? String(describing: self.stride) : nil
                        }
                        return nil
                    }),
                Property("Pad", {
                        if let self = weakSelf {
                            if self.paddingPolicy == .usePaddingSize {
                                return String(describing: self.paddingSize)
                            } else {
                                return self.paddingPolicy.localizedDescription
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
            supers.append(.aieConvolution)
        }
        return supers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeEnumeration(forKey: "type") { (value: `Type`?) in
            self.type = value ?? .standard
        }
        coder.decodeInteger(forKey: "width") { (value) in
            self.width = value
        }
        coder.decodeInteger(forKey: "height") { (value) in
            self.height = value
        }
        coder.decodeInteger(forKey: "depth") { (value) in
            self.depth = value
        }
        coder.decodeInteger(forKey: "inputFeatureChannels") { (value) in
            self.inputFeatureChannels = value
        }
        coder.decodeInteger(forKey: "outputFeatureChannels") { (value) in
            self.outputFeatureChannels = value
        }
        coder.decodeInteger(forKey: "dilation") { (value) in
            self.dilation = value
        }
        coder.decodeInteger(forKey: "stride") { (value) in
            self.stride = value
        }
        coder.decodeEnumeration(forKey: "paddingPolicy") { (value : PaddingPolicy?) in
            self.paddingPolicy = value ?? .same
        }
        coder.decodeInteger(forKey: "paddingSize") { value in
            self.paddingSize = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        if type != .standard {
            coder.encode(type, forKey: "type")
        }
        if width != 0 {
            coder.encode(width, forKey: "width")
        }
        if height != 0 {
            coder.encode(height, forKey: "height")
        }
        if depth != 0 {
            coder.encode(depth, forKey: "depth")
        }
        if inputFeatureChannels != 0 {
            coder.encode(inputFeatureChannels, forKey: "inputFeatureChannels")
        }
        if outputFeatureChannels != 0 {
            coder.encode(outputFeatureChannels, forKey: "outputFeatureChannels")
        }
        if dilation != 0 {
            coder.encode(stride, forKey: "dilation")
        }
        if stride != 0 {
            coder.encode(stride, forKey: "stride")
        }
        if paddingPolicy != .same {
            coder.encode(paddingPolicy, forKey: "paddingPolicy")
        }
        if paddingSize != 0 {
            coder.encode(paddingSize, forKey: "paddingSize")
        }
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "aieConvolution"
    }

}
