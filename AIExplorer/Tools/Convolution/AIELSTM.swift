//
//  AIELSTM.swift
//  NN Explorer
//
//  Created by AJ Raftis on 1/4/21.
//

import Draw

public extension AJRInspectorIdentifier {
    static var aiLTSM = AJRInspectorIdentifier("aiLTSM")
}


@objcMembers
open class AIELSTM: AIEGraphic {

    // MARK: - Properties
    open var units : Int = 0

    // MARK: - Creation

    public convenience init(units: Int) {
        self.init()

        self.units = units
    }

    public required init() {
        super.init()
    }

    public required init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    // MARK: - AJRInspector

    open override var inspectorIdentifiers: [AJRInspectorIdentifier] {
        var identifiers = super.inspectorIdentifiers
        identifiers.append(.aiLayerNormalization)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeInteger(forKey: "units") { (value) in
            self.units = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(units, forKey: "units")
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "lstm-layer"
    }

}
