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

    open var conditions = [AJREvaluation]()

    // MARK: - AJRInspector

    open override func inspectorIdentifiers(forInspectorContent inspectorContentIdentifier: AJRInspectorContentIdentifier?) -> [AJRInspectorIdentifier] {
        var supers = super.inspectorIdentifiers(forInspectorContent: inspectorContentIdentifier)
        if inspectorContentIdentifier == .graphic {
            supers.append(.aieBranch)
        }
        return supers
    }

    // MARK: - DrawGraphic

    open override func createTitleAspect() -> AIETitle {
        let title = super.createTitleAspect()
        title.simpleAppearance = true
        title.verticalAlignment = .middle
        title.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .large))
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

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)
        coder.decodeObject(forKey: "conditions") { object in
            if let objects = object as? [AJREvaluation] {
                self.conditions.append(contentsOf: objects)
            }
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        if conditions.count > 0 {
            coder.encode(conditions, forKey: "conditions")
        }
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "aieBranch"
    }

}
