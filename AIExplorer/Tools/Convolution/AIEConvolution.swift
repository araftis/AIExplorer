/*
 AIEConvolution.swift
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
    open var size : AIEShape = .zero
    open var depth : Int = 0
    open var outputFeatureChannels : Int = 0
    open var dilation : AIEShape = .identity
    open var stride : AIEShape = .identity
    open var paddingPolicy : PaddingPolicy = .same
    open var paddingSize : AIEShape = .zero

    open var inputFeatureChannels : Int {
        if let inputShape,
           inputShape.count > 0 {
            return inputShape[inputShape.count - 1]
        }
        return 0
    }

    // MARK: - Creation

    public convenience init(width: Int, height: Int, depth: Int, step : Int) {
        self.init()

        self.size.width = width
        self.size.height = height
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

    internal func sizeString(for size: AIEShape, min: Int = 0) -> String? {
        if size.width > min && size.height > min {
            if size.width == size.height {
                return "\(size.width)"
            } else {
                return "\(size.width) ✕ \(size.height)"
            }
        }
        return nil
    }

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
                if self.size.width > 0 || self.size.height > 0 {
                    string += "\(self.size.width) ✕ \(self.size.height)"
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
                return self.sizeString(for: self.dilation, min: 1)
            }
            return nil
        }),
                Property("Stride", {
            if let self = weakSelf {
                return self.sizeString(for: self.stride, min: 1)
            }
            return nil
        }),
                Property("Pad", {
            if let self = weakSelf {
                if self.paddingPolicy == .usePaddingSize {
                    return self.sizeString(for: self.paddingSize)
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
            // Backwards compatibility
            self.size.width = value
        }
        coder.decodeInteger(forKey: "height") { (value) in
            // Backwards compatibility
            self.size.height = value
        }
        coder.decodeShape(forKey: "size") { value in
            self.size = value
        }
        coder.decodeInteger(forKey: "depth") { (value) in
            self.depth = value
        }
        coder.decodeInteger(forKey: "outputFeatureChannels") { (value) in
            self.outputFeatureChannels = value
        }
        coder.decodeShape(forKey: "dilation") { value in
            self.dilation = value
        }
        coder.decodeShape(forKey: "stride") { value in
            self.stride = value
        }
        coder.decodeEnumeration(forKey: "paddingPolicy") { (value : PaddingPolicy?) in
            self.paddingPolicy = value ?? .same
        }
        coder.decodeShape(forKey: "paddingSize") { value in
            self.paddingSize = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        if type != .standard {
            coder.encode(type, forKey: "type")
        }
        if size.width != 0 || size.height != 0 {
            coder.encode(size, forKey: "size")
        }
        if depth != 0 {
            coder.encode(depth, forKey: "depth")
        }
        if outputFeatureChannels != 0 {
            coder.encode(outputFeatureChannels, forKey: "outputFeatureChannels")
        }
        if dilation != .zero {
            coder.encode(dilation, forKey: "dilation")
        }
        if stride != .zero {
            coder.encode(stride, forKey: "stride")
        }
        if paddingPolicy != .same {
            coder.encode(paddingPolicy, forKey: "paddingPolicy")
        }
        if paddingSize != .zero {
            coder.encode(paddingSize, forKey: "paddingSize")
        }
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "aieConvolution"
    }

    // MARK: - Shape

    open override var outputShape: [Int] {
        if let inputShape {
            var outputShape = AIEConvolution.output(from: inputShape, size: size, padding: paddingPolicy, paddingSize: paddingSize, stride: stride, dilation: dilation)
            outputShape[outputShape.count - 1] = outputFeatureChannels
            return outputShape
        }
        return []
    }

    // MARK: - Utilities

    public static func outputLength(from inputLength: Int, size: Int, padding: PaddingPolicy, paddingSize: Int, stride: Int, dilation: Int = 1) -> Int {
        // NOTE: Adapted from conv_utils.py:conv_output_length from the Keras source on github: https://github.com/keras-team/keras/blob/master/keras/utils/conv_utils.py
        let dilatedFilterSize = size + (size - 1) * (dilation - 1)
        var outputLength = 0
        if padding == .same {
            outputLength = inputLength
        } else if padding == .valid {
            outputLength = inputLength - dilatedFilterSize + 1
        } else if padding == .usePaddingSize {
            AJRLog.warning("We're not computing with PaddingPolicy.usePaddingSize and paddingSize.")
            // This was original the if case for "full", so that's this computation. We're not support full, but I left this here for right now.
            outputLength = inputLength + dilatedFilterSize - 1
        }
        return (outputLength + stride - 1) / stride
    }

    public static func output(from input: [Int], size: AIEShape, padding: PaddingPolicy, paddingSize: AIEShape, stride: AIEShape, dilation: AIEShape = .identity) -> [Int] {
        assert(input.count >= 3 && input.count <= 5, "input size must be between 3 and 5.")
        var output = input

        if input.count == 3 {
            output[1] = outputLength(from: output[1], size: size.width, padding: padding, paddingSize: paddingSize.width, stride: stride.width)
        } else if input.count == 4 {
            output[1] = outputLength(from: output[1], size: size.height, padding: padding, paddingSize: paddingSize.height, stride: stride.height)
            output[2] = outputLength(from: output[2], size: size.width, padding: padding, paddingSize: paddingSize.width, stride: stride.width)
        } else if input.count == 5 {
            output[1] = outputLength(from: output[1], size: size.depth, padding: padding, paddingSize: paddingSize.depth, stride: stride.depth)
            output[2] = outputLength(from: output[2], size: size.height, padding: padding, paddingSize: paddingSize.height, stride: stride.height)
            output[3] = outputLength(from: output[3], size: size.width, padding: padding, paddingSize: paddingSize.width, stride: stride.width)
        }

        return output
    }

}
