/*
AIEGraphic.swift
AIExplorer

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

import AJRFoundation
import Draw

public extension AJRInspectorIdentifier {
    static var aiGraphic = AJRInspectorIdentifier("aiGraphic")
}

@objcMembers
open class AIEGraphic: DrawGraphic {

    @objc
    public enum Activity : Int, AJRXMLEncodableEnum {

        case any
        case deployment
        case training

        public var description: String {
            switch self {
            case .any: return "any"
            case .deployment: return "deployment"
            case .training: return "training"
            }
        }
    }

    private var _title : String?
    open var title: String {
        get {
            if _title == nil {
                if let aspect = firstAspect(ofType: AIETitle.self, with: AIETitle.defaultPriority) as? DrawText {
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

    open var activity : Activity = .any {
        willSet { willChangeValue(forKey: "activity") }
        didSet { didChangeValue(forKey: "activity") }
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

        attributes[.font] = NSFont.systemFont(ofSize: 9.0)
        attributes[.paragraphStyle] = style
        attributes[.foregroundColor] = NSColor.black

        return attributes
    }

    internal let cornerRadius : CGFloat = 5.0
    
    open func updatePath() -> Void {
        path.removeAllPoints()
        path.move(to: (frame.minX, frame.maxY))
        path.appendArc(boundedBy: CGRect(x: frame.minX, y: frame.minY, width: cornerRadius, height: cornerRadius), startAngle: 180, endAngle: 270, clockwise: false)
        path.appendArc(boundedBy: CGRect(x: frame.maxX - cornerRadius, y: frame.minY, width: cornerRadius, height: cornerRadius), startAngle: 270, endAngle: 0, clockwise: false)
        path.line(to: (frame.maxX, frame.maxY))
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
        var supers = super.inspectorIdentifiers
        supers.append(.aiGraphic)
        return supers
    }

    // MARK: - AJRXMLCoding

    /// This won't normally get used, because we don't encode this graphics by default, but we still want to keep this unique from our superclass.
    open override class var ajr_nameForXMLArchiving: String { return "aieGraphic" }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        coder.encodeObjectIfNotNil(_title, forKey: "title")
        if activity != .any {
            coder.encode(activity, forKey: "activity")
        }
    }

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeEnumeration(forKey: "activity") { (value: Activity?) in
            self.activity = value ?? .any
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
        var objectsToRemove = [DrawGraphic]()
        for related in self.relatedGraphics {
            if let drawLink = related as? DrawLink {
                if (drawLink.destination === self && drawLink.sourceCap == nil
                        && drawLink.destinationCap != nil), let source = drawLink.source as? AIEGraphic {
                    if drawLink.document == nil {
                        // We've got a delete issue, so we're going to "clean" our document here, along with a warning. We will, obviously, want to fix this. This is probably happening because when a link is deleted, it's not deleting itself from it's related graphics.
                        AJRLog.warning("Graphic \(drawLink) in \(self) is no longer a member of the document.")
                        self.document?.remove(drawLink)
                        objectsToRemove.append(drawLink)
                    } else {
                        sourceObjects.append(source)
                    }
                }
            }
        }
        if objectsToRemove.count > 0 {
            for object in objectsToRemove {
                remove(fromRelatedGraphics: object)
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
        var objectsToRemove = [DrawGraphic]()
        for related in self.relatedGraphics {
            if let drawLink = related as? DrawLink {
                if (drawLink.source === self && drawLink.sourceCap == nil
                        && drawLink.destinationCap != nil), let destination = drawLink.destination as? AIEGraphic {
                    if drawLink.document == nil {
                        // We've got a delete issue, so we're going to "clean" our document here, along with a warning. We will, obviously, want to fix this. This is probably happening because when a link is deleted, it's not deleting itself from it's related graphics.
                        AJRLog.warning("Graphic \(drawLink) in \(self) is no longer a member of the document.")
                        self.document?.remove(drawLink)
                        objectsToRemove.append(drawLink)
                    } else {
                        destinationObjects.append(destination)
                    }
                }
            }
        }
        if objectsToRemove.count > 0 {
            for object in objectsToRemove {
                remove(fromRelatedGraphics: object)
            }
        }
        return destinationObjects
    }

}
