//
//  AIEBranch.swift
//  AIExplorer
//
//  Created by AJ Raftis on 11/2/22.
//

import Draw

public extension AJRInspectorIdentifier {
    static var aieBranch = AJRInspectorIdentifier("aieBranch")
}

@objcMembers
open class AIEBranch: AIEGraphic {

    // MARK: - AJRInspector

    open override var inspectorIdentifiers: [AJRInspectorIdentifier] {
        var identifiers = super.inspectorIdentifiers
        identifiers.append(.aieBranch)
        return identifiers
    }

    // MARK: - DrawGraphic

    open override func createTitleAspect() -> AIETitle {
        let title = super.createTitleAspect()
        title.simpleAppearance = true
        title.verticalAlignment = .middle
        return title
    }
    
    open override func updatePath() -> Void {
        path.removeAllPoints()
        path.moveTo(x: frame.midX, y: frame.maxY)
        path.lineTo(x: frame.minX, y: frame.midY)
        path.lineTo(x: frame.midX, y: frame.minY)
        path.lineTo(x: frame.maxX, y: frame.midY)
        path.close();

        noteBoundsAreDirty()
    }

    // MARK: - AJRXMLCoding

    open class override var ajr_nameForXMLArchiving: String {
        return "aieBranch"
    }

}
