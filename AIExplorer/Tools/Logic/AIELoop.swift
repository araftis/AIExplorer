//
//  AIELoop.swift
//  AIExplorer
//
//  Created by AJ Raftis on 11/2/22.
//

import Draw

public extension AJRInspectorIdentifier {
    static var aieLoop = AJRInspectorIdentifier("aieLoop")
}

@objcMembers
open class AIELoop: AIEGraphic {

    // MARK: - AJRInspector

    open override var inspectorIdentifiers: [AJRInspectorIdentifier] {
        var identifiers = super.inspectorIdentifiers
        identifiers.append(.aieLoop)
        return identifiers
    }

    // MARK: - DrawGraphic
    
    open override func updatePath() -> Void {
        path.removeAllPoints()
        path.appendOval(in: frame.insetBy(dx: 1.0, dy: 1.0))
        path.close();

        noteBoundsAreDirty()
    }

    // MARK: - AJRXMLCoding

    open class override var ajr_nameForXMLArchiving: String {
        return "aieLoop"
    }

}
