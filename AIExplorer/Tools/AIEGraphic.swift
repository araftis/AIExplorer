//
//  AIEGraphic.swift
//  NN Explorer
//
//  Created by AJ Raftis on 1/3/21.
//

import Draw

@objcMembers
open class AIEGraphic: DrawGraphic {

    public required override init() {
        super.init()
    }

    public required override init(frame: NSRect) {
        super.init(frame: frame)
    }

    open class var defaultTextAttributes : [NSAttributedString.Key:Any] {
        var attributes = [NSAttributedString.Key:Any]()
        let style : NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle

        style.alignment = .center;

        attributes[.font] = NSFont.systemFont(ofSize: 14.0)
        attributes[.paragraphStyle] = style
        attributes[.foregroundColor] = NSColor.black

        return attributes
    }

    open func updatePath() -> Void {
        path.removeAllPoints()
        path.appendRoundedRect(frame, xRadius: 8.0, yRadius: 8.0)
        path.close();

        noteBoundsAreDirty()
    }

    override open var frame : NSRect {
        get {
            return super.frame
        }
        set {
            let needsUpdate = frame.size != newValue.size
            super.frame = newValue
            if needsUpdate {
                updatePath()
            }
        }
    }

    open override func finalizeXMLDecoding() throws -> Any {
        updatePath()
        try super.finalizeXMLDecoding()
        return self
    }

}
