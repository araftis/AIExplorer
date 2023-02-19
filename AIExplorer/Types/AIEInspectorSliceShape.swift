//
//  AIEInspectorShape.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/19/23.
//

import AJRInterface

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
            let shape = valueKey!.value {
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
            let shape = valueKey!.value {
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
            let shape = valueKey!.value {
            let newValue = sender?.integerValue ?? 0
            if shape.depth != newValue {
                shape.depth = newValue
                valueKey?.value = shape
            }
        }
    }

}
