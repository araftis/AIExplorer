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

extension AIEShape : Equatable {

    public static func == (lhs: AIEShape, rhs: AIEShape) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }
    
}

extension AIEShape : AJRInspectorValue, AJRInspectorValueAsValue {

    public static func inspectorValue(from string: String) -> Any? {
        return AIEShapeFromString(string)
    }

    public static func inspectorValue(from value: NSValue) -> Any? {
        return value.shapeValue
    }

    public var description: String {
        return AIEStringFromShape(self)
    }

    public func toValue() -> NSValue {
        return NSValue(shape: self)
    }

}

public extension AIEShape {

    static let zero = AIEShapeZero
    static let identity = AIEShapeIdentity

}

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
    override func encode(_ size: AIEShape, forKey key: String) -> Void {
        encodeGroup(forKey: key, using: {
            if size.width != 0 {
                self.encode(size.width, forKey: "width")
            }
            if size.height != 0 {
                self.encode(size.height, forKey: "height")
            }
            if size.depth != 0 {
                self.encode(size.depth, forKey: "depth")
            }
        })
    }


}

@objc
public extension AJRXMLUnarchiver {

    @objc(decodeShapeForKey:setter:)
    override func decodeShape(forKey key: String, setter: @escaping (_ value: AIEShape) -> Void) -> Void {
        var size = AIEShape.zero
        decodeGroup(forKey: key, using: {
            self.decodeInteger(forKey: "width") { value in
                size.width = value
            }
            self.decodeInteger(forKey: "height") { value in
                size.height = value
            }
            self.decodeInteger(forKey: "depth") { value in
                size.depth = value
            }
        }, setter: {
            setter(size)
        })
    }

}
// MARK: - AJRInspectorSliceSize -

@objcMembers
open class AIEInspectorSliceShape : AJRInspectorSliceThreeValues<AIEShape> {

    open override var nibBundle: Bundle {
        // Because we don't define our own xib, we use the one from AJRInterface.
        return Bundle(for: AJRInspectorSliceGeometry.self)
    }

    open override var units : Unit? {
        // We don't want to display "units", they don't really have meaning to us.
        return nil
    }

    // We link, because when linked, we set both fields to the same value.
    open override var defaultValuesCanLink: Bool { return true }

    open override var defaultLabel1Value : String { return translator["Width"] }
    open override var defaultLabel2Value : String { return translator["Height"] }
    open override var defaultLabel3Value : String { return translator["Depth"] }

    open override func updateFields() -> Void {
        super.updateFields()
        if let size = configureFieldsAndFetchSingleValue() {
            numberField1.integerValue = size.width
            numberField2.integerValue = size.height
            numberField3.integerValue = size.depth
            stepper1.integerValue = size.width
            stepper2.integerValue = size.height
            stepper3.integerValue = size.depth
        }
    }

    @IBAction open override func setValue1(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var shape = valueKey!.value {
            let newValue = sender?.integerValue ?? 0
            if shape.width != newValue {
                shape.width = newValue
                if linkedButton1.state == .on {
                    shape.height = newValue
                }
                valueKey?.value = shape
            }
        }
    }

    @IBAction open override func setValue2(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var shape = valueKey!.value {
            let newValue = sender?.integerValue ?? 0
            if shape.height != newValue {
                if linkedButton1.state == .on {
                    shape.width = newValue
                }
                shape.height = newValue
                valueKey?.value = shape
            }
        }
    }

    @IBAction open override func setValue3(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var shape = valueKey!.value {
            let newValue = sender?.integerValue ?? 0
            if shape.depth != newValue {
                shape.depth = newValue
                valueKey?.value = shape
            }
        }
    }

}

