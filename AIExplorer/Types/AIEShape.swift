/*
 AIEShape.swift
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

import AJRInterface

@objcMembers
public class AIEShape : NSObject, AJRInspectorValue, AJRInspectorValueAsValue, AJREquatable {
    
    public private(set) var count : Int = 3
    internal var labels : [AIEShapeLabel] = [.height, .width, .depth]
    internal var values : [Int] = [ 0, 0, 0 ]
    
    // MARK: - Creation
    
    open class func shape(width: Int, height: Int, depth: Int) -> AIEShape {
        return AIEShape(width: width, height: height, depth: depth)
    }
    
    /**
     Creates a basic image shape initialized to all 0.
     */
    public override init() {
    }
    
    public init(labels: [AIEShapeLabel], values: [Int]) {
        assert(labels.count == values.count, "The labels and values parameters must have the same count.")
        self.count = labels.count
        self.labels = labels
        self.values = values
    }
    
    public convenience init(width: Int, height: Int, depth: Int) {
        self.init()
        self.width = width
        self.height = height
        self.depth = depth
    }
    
    // MARK: - Convenience Properties
    
    public class var zero : AIEShape {
        return AIEShape()
    }
    
    public var width : Int {
        get {
            return count >= 2 ? values[1] : 0
        }
        set {
            if count >= 1 {
                values[1] = newValue
            }
        }
    }
    
    public var height : Int {
        get {
            return count >= 1 ? values[0] : 0
        }
        set {
            if count >= 1 {
                values[0] = newValue
            }
        }
    }
    
    public var depth : Int {
        get {
            return count >= 2 ? values[2] : 0
        }
        set {
            if count >= 2 {
                values[2] = newValue
            }
        }
    }
    
    public subscript(_ index: Int) -> Int {
        return values[index]
    }
    
    public subscript(_ label: AIEShapeLabel) -> Int? {
        for x in 0 ..< count {
            if labels[x] == label {
                return values[x]
            }
        }
        return nil
    }
    
    // MARK: - NSObject

    public override var description: String {
        return AIEStringFromShape(self)
    }
    
    // MARK: - NSValue

    public func toValue() -> NSValue {
        return NSValue.value(with: self)
    }
    
    // MARK: - AJREquatable
    
    public func isEqual(toShape shape: AIEShape) -> Bool {
        if count == shape.count {
            for x in 0 ..< count {
                if values[x] != shape.values[x]
                    || labels[x] != shape.labels[x] {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? AIEShape {
            return object .isEqual(toShape: object)
        }
        return false
    }
    
    public override class func isEqual(to object: Any?) -> Bool {
        return isEqual(object)
    }
    
}

@nonobjc
public extension AIEShape {
    
    // MARK: - AJRInspectorValue
    
    static func inspectorValue(from string: String) -> Any? {
        return AIEShapeFromString(string)
    }
    
    static func inspectorValue(from value: NSValue) -> Any? {
        return value.shapeValue
    }
    
}

// MARK: - AIEShapesEqual

@_cdecl("AIEShapesEqual")
public func AIEShapesEqual(_ lhs: AIEShape, _ rhs: AIEShape) -> Bool {
    return lhs == rhs
}

// MARK: - AIEShapeFromString

@_cdecl("AIEShapeFromString")
public func AIEShapeFromString(_ string: String) -> AIEShape? {
    var labels = [AIEShapeLabel]()
    var values = [Int]()
    
    let scanner = Scanner(string: string)
    if scanner.scanString("{") == nil {
        return nil
    }
    while true {
        if let label = scanner.scanUpToString("="),
           scanner.scanString("=") != nil,
           let value = scanner.scanInt() {
            labels.append(AIEShapeLabel(label))
            values.append(value)
        }
        // This means we'll likely have more values.
        if scanner.scanString(";") != nil {
            continue
        }
        // This means we're done. We'll allow garbage at the end of the string.
        if scanner.scanString("}") != nil{
            break
        }
        return nil
    }
    return AIEShape(labels: labels, values: values)
}

// MARK: - AIEStringFromShape

@_cdecl("AIEStringFromShape")
public func AIEStringFromShape(_ shape: AIEShape) -> String {
    var string = "{"
    for x in 0 ..< shape.count {
        if x > 0 {
            string += "; "
        }
        string += shape.labels[x].rawValue
        string += "="
        string += String(describing: shape[x])
    }
    string += "}"
    return string
}

// MARK: - AJRXMLCoding

@objc
public extension AJRXMLCoder {

    @objc(encodeShape:forKey:)
    func encode(_ size: AIEShape, forKey key: String) -> Void {
    }

    @objc(decodeShapeForKey:setter:)
    func decodeShape(forKey key: String, setter: @escaping (_ value: AIEShape) -> Void) -> Void {
    }

}

@objc
public extension AJRXMLArchiver {

    @objc(encodeShape:forKey:)
    override func encode(_ shape: AIEShape, forKey key: String) -> Void {
        encodeGroup(forKey: key, using: {
            for x in 0 ..< shape.count {
                self.encode(shape.values[x], forKey: shape.labels[x].rawValue)
            }
        })
    }

}

@objc
public extension AJRXMLUnarchiver {

    @objc(decodeShapeForKey:setter:)
    override func decodeShape(forKey key: String, setter: @escaping (_ value: AIEShape) -> Void) -> Void {
        let labels : [AIEShapeLabel] = [ .height, .width, .depth ]
        var values : [Int] = [0, 0, 0]
        // TODO: We need to add a mechanism to the XML decode that'll just call us for each attribute found in the XML. Then, we can create the labels and values from that call back, and thus reproduce the struct in the same order.
        decodeGroup(forKey: key) {
            self.decodeInteger(forKey: "width") { value in
                values[1] = value
            }
            self.decodeInteger(forKey: "height") { value in
                values[0] = value
            }
            self.decodeInteger(forKey: "depth") { value in
                values[2] = value
            }
        } setter: {
            let shape = AIEShape(labels: labels, values: values)
            setter(shape)
        }
    }

}

// MARK: - NSValue

public extension NSValue {
    
    class func value(with shape: AIEShape) -> NSValue {
        preconditionFailure("Shouldn't have gotten here.")
    }
    
    var shapeValue : AIEShape {
        preconditionFailure("Shouldn't have gotten here.")
    }
    
}
