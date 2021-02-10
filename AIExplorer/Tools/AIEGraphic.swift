//
//  AIEGraphic.swift
//  NN Explorer
//
//  Created by AJ Raftis on 1/3/21.
//

import Draw

public extension AJRInspectorIdentifier {
    static var aiGraphic = AJRInspectorIdentifier("aiGraphic")
}

@objcMembers
open class AIEGraphic: DrawGraphic {

    private var _title : String?
    open var title: String {
        get {
            if _title == nil {
                if let aspect = firstAspect(ofType: DrawText.self, with: DrawText.defaultPriority) as? DrawText {
                    _title = aspect.attributedString.string
                }
            }
            if _title == nil {
                _title = "No Title"
            }
            return _title!
        }
        set(newValue) {
            _title = newValue
        }
    }

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

    // MARK: - AJRInspector

    open override var inspectorIdentifiers: [AJRInspectorIdentifier] {
        var identifiers = super.inspectorIdentifiers
        identifiers.append(.aiGraphic)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        coder.encodeObjectIfNotNil(_title, forKey: "title")
    }

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeString(forKey: "title") { (value) in
            self.title = value
        }
    }

    open override func finalizeXMLDecoding() throws -> Any {
        try super.finalizeXMLDecoding()
        updatePath()
        return self
    }

    // MARK: - Graph Traversal

    open var sourceObjects : [AIEGraphic] {
        var sourceObjects = [AIEGraphic]()
        for related in self.relatedGraphics {
            if let drawLink = related as? DrawLink {
                if (drawLink.destination === self && drawLink.sourceCap == nil
                        && drawLink.destinationCap != nil), let source = drawLink.source as? AIEGraphic {
                    if drawLink.document == nil {
                        // We've got a delete issue, so we're going to "clean" our document here, along with a warning. We will, obviously, want to fix this. This is probably happening because when a link is deleted, it's not deleting itself from it's related graphics.
                        AJRLog.warning("Graphic \(drawLink) in \(self) is no longer a member of the document.")
                    } else {
                        sourceObjects.append(source)
                    }
                }
            }
        }
        return sourceObjects
    }
    /**
     Returns an array of related objects from this graphic.

     This is necessary, because our graphics obejct's aren't really a graph, they're graphics. However, because we've conencted two graphics together via links, we can actually treat them like a graph. That being said, it's a little bit of a pain to traverse the graph, so this method returns the related objects.

     These aren't strictly "children", so I'm going with the "destinationObjects" moniker. These are objects that "point to" other objects. On the flip side, "sourceObjects" represent objects that point to us.

     Finally, if you're going to traverse the graph, you'll need to make sure you don't enter into retain cycles, as the graphs can very much produce cycles.
     */
    open var destinationObjects : [AIEGraphic] {
        var destinationObjects = [AIEGraphic]()
        for related in self.relatedGraphics {
            if let drawLink = related as? DrawLink {
                if (drawLink.source === self && drawLink.sourceCap == nil
                        && drawLink.destinationCap != nil), let destination = drawLink.destination as? AIEGraphic {
                    if drawLink.document == nil {
                        // We've got a delete issue, so we're going to "clean" our document here, along with a warning. We will, obviously, want to fix this. This is probably happening because when a link is deleted, it's not deleting itself from it's related graphics.
                        AJRLog.warning("Graphic \(drawLink) in \(self) is no longer a member of the document.")
                    } else {
                        destinationObjects.append(destination)
                    }
                }
            }
        }
        return destinationObjects
    }

}
