//
//  AIEShape.swift
//  AIExplorer
//
//  Created by AJ Raftis on 12/4/22.
//

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
            var size = valueKey!.value {
            let newValue = sender?.integerValue ?? 0
            if size.width != newValue {
                size.width = newValue
                if linkedButton1.state == .on {
                    size.height = newValue
                }
                valueKey?.value = size
            }
        }
    }

    @IBAction open override func setValue2(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var size = valueKey!.value {
            let newValue = sender?.integerValue ?? 0
            if size.height != newValue {
                if linkedButton1.state == .on {
                    size.width = newValue
                }
                size.height = newValue
                valueKey?.value = size
            }
        }
    }

    @IBAction open override func setValue3(_ sender: NSControl?) {
        if valueKey?.selectionType == .single,
            var size = valueKey!.value {
            let newValue = sender?.integerValue ?? 0
            if size.depth != newValue {
                size.depth = newValue
                valueKey?.value = size
            }
        }
    }

}

