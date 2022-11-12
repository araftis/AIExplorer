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

    open var width : Int = 0
    open var height : Int = 0
    open var strideX : Int = 0
    open var strideY : Int = 0
    open var dilationX : Int = 0
    open var dilationY : Int = 0
    open var paddingPolicy : AIEConvolution.PaddingPolicy = .same
    open var paddingX : Int = 0
    open var paddingY : Int = 0
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
                            if self.width > 0 || self.height > 0 {
                                string += "\(self.width) ✕ \(self.height)"
                            }
                            return string.isEmpty ? nil : string
                        }
                        return nil
                    }),
                Property("Stride", {
                        if let self = weakSelf {
                            var string = ""
                            if self.strideX > 0 || self.strideY > 0 {
                                string += "\(self.strideX) ✕ \(self.strideY)"
                            }
                            return string.isEmpty ? nil : string
                        }
                        return nil
                    }),
                Property("Dilation", {
                        if let self = weakSelf {
                            if self.dilationX != 0 || self.dilationY != 0 {
                                return "\(self.dilationX) ✕ \(self.dilationY)"
                            }
                        }
                        return nil
                    }),
                Property("Pad", {
                        if let self = weakSelf {
                            if self.paddingPolicy == .usePaddingSize {
                                return "\(self.paddingX) ✕ \(self.paddingY)"
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
            self.width = value
        }
        coder.decodeInteger(forKey: "height") { (value) in
            self.height = value
        }
        coder.decodeInteger(forKey: "strideX") { (value) in
            self.strideX = value
        }
        coder.decodeInteger(forKey: "strideY") { (value) in
            self.strideX = value
        }
        coder.decodeInteger(forKey: "dilationX") { (value) in
            self.dilationX = value
        }
        coder.decodeInteger(forKey: "dilationY") { (value) in
            self.dilationY = value
        }
        coder.decodeEnumeration(forKey: "paddingPolicy") { (value: AIEConvolution.PaddingPolicy?) in
            self.paddingPolicy = value ?? .same
        }
        coder.decodeInteger(forKey: "paddingX") { (value) in
            self.paddingX = value
        }
        coder.decodeInteger(forKey: "paddingY") { (value) in
            self.paddingY = value
        }
        coder.decodeBool(forKey: "countIncludesPadding") { (value) in
            self.countIncludesPadding = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(width, forKey: "width")
        coder.encode(height, forKey: "height")
        coder.encode(strideX, forKey: "strideX")
        coder.encode(strideY, forKey: "strideY")
        coder.encode(dilationX, forKey: "dilationX")
        coder.encode(dilationY, forKey: "dilationY")
        coder.encode(paddingPolicy, forKey: "paddingPolicy")
        coder.encode(paddingX, forKey: "paddingX")
        coder.encode(paddingY, forKey: "paddingY")
        coder.encode(countIncludesPadding, forKey: "countIncludesPadding")
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "aiePoolingLayer"
    }

}
