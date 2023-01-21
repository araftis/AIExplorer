/*
 AIEPooling.swift
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
    static var aiePooling = AJRInspectorIdentifier("aiePooling")
}

@objcMembers
open class AIEPooling: AIEGraphic {

    @objc
    public enum PoolingType : Int, AJRXMLEncodableEnum {

        case max
        case average
        case l2norm

        public var description: String {
            switch self {
            case .max: return "max"
            case .average: return "average"
            case .l2norm: return "l2norm"
            }
        }

        public var localizedDescription: String {
            switch self {
            case .max: return "Max"
            case .average: return "Average"
            case .l2norm: return "L2 Norm"
            }
        }

    }

    // MARK: - Properties

    open var size : AIEShape = .zero
    open var stride : AIEShape = .zero
    open var dilation : AIEShape = .zero
    open var paddingPolicy : AIEConvolution.PaddingPolicy = .same
    open var padding : AIEShape = .zero
    open var countIncludesPadding : Bool = false

    // MARK: - Creation

    public required init() {
        super.init()
    }

    public required init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    // MARK: - AIEGraphic

    open override var displayedProperties : [Property] {
        weak var weakSelf = self
        return [Property("Size", {
                        if let self = weakSelf {
                            var string = ""
                            if self.size.width > 0 || self.size.height > 0 {
                                string += "\(self.size.width) ✕ \(self.size.height)"
                            }
                            return string.isEmpty ? nil : string
                        }
                        return nil
                    }),
                Property("Stride", {
                        if let self = weakSelf {
                            var string = ""
                            if self.stride.width > 1 || self.stride.height > 1 {
                                string += "\(self.stride.width) ✕ \(self.stride.height)"
                            }
                            return string.isEmpty ? nil : string
                        }
                        return nil
                    }),
                Property("Dilation", {
                        if let self = weakSelf {
                            if self.dilation.width != 1 || self.dilation.height != 1 {
                                return "\(self.dilation.width) ✕ \(self.dilation.height)"
                            }
                        }
                        return nil
                    }),
                Property("Pad", {
                        if let self = weakSelf {
                            if self.paddingPolicy == .usePaddingSize {
                                return "\(self.padding.width) ✕ \(self.padding.height)"
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
            supers.append(.aiePooling)
        }
        return supers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeInteger(forKey: "width") { (value) in
            // For backwards compatibility
            self.size.width = value
        }
        coder.decodeInteger(forKey: "height") { (value) in
            // For backwards compatibility
            self.size.height = value
        }
        coder.decodeShape(forKey: "size") { value in
            self.size = value
        }
        coder.decodeInteger(forKey: "strideX") { (value) in
            // For backwards compatibility
            self.stride.width = value
        }
        coder.decodeInteger(forKey: "strideY") { (value) in
            // For backwards compatibility
            self.stride.height = value
        }
        coder.decodeShape(forKey: "stride") { value in
            self.stride = value
        }
        coder.decodeInteger(forKey: "dilationX") { (value) in
            // For backwards compatibility
            self.dilation.width = value
        }
        coder.decodeInteger(forKey: "dilationY") { (value) in
            // For backwards compatibility
            self.dilation.height = value
        }
        coder.decodeShape(forKey: "dilation") { value in
            self.dilation = value
        }
        coder.decodeEnumeration(forKey: "paddingPolicy") { (value: AIEConvolution.PaddingPolicy?) in
            self.paddingPolicy = value ?? .same
        }
        coder.decodeInteger(forKey: "paddingX") { (value) in
            // For backwards compatibility
            self.padding.width = value
        }
        coder.decodeInteger(forKey: "paddingY") { (value) in
            // For backwards compatibility
            self.padding.height = value
        }
        coder.decodeShape(forKey: "padding") { value in
            self.padding = value
        }
        coder.decodeBool(forKey: "countIncludesPadding") { (value) in
            self.countIncludesPadding = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(size, forKey: "size")
        coder.encode(stride, forKey: "stride")
        coder.encode(dilation, forKey: "dilation")
        coder.encode(paddingPolicy, forKey: "paddingPolicy")
        coder.encode(padding, forKey: "padding")
        coder.encode(countIncludesPadding, forKey: "countIncludesPadding")
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "aiePoolingLayer"
    }

    // MARK: - Shape

    open override var outputShape: [Int] {
        if let inputShape {
            return AIEConvolution.output(from: inputShape, size: size, padding: paddingPolicy, paddingSize: padding, stride: stride, dilation: dilation)
        }
        return []
    }

}
