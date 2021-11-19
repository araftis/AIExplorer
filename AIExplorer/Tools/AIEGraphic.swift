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
import Foundation

public extension AJRInspectorIdentifier {
    static var aiGraphic = AJRInspectorIdentifier("aiGraphic")
}

@objcMembers
open class AIEGraphic: DrawGraphic, AIEMessageObject {

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

    open var title: String {
        get {
            if let aspect = firstAspect(ofType: AIETitle.self, with: AIETitle.defaultPriority) as? DrawText {
                return aspect.attributedString.string
            }
            return "No Title"
        }
        set(newValue) {
            willChangeValue(forKey: "title")
            if let aspect = firstAspect(ofType: AIETitle.self, with: AIETitle.defaultPriority) as? AIETitle {
                aspect.attributedString = NSAttributedString(string: newValue, attributes: Self.defaultTextAttributes)
            }
            didChangeValue(forKey: "title")
        }
    }
    
    open var messagesTitle: String {
        return title
    }
    
    open var messagesImage: NSImage? {
        if let toolSets = DrawToolSet(forIdentifier: .neuralNet) {
            for tool in toolSets.tools {
                for action in tool.actions {
                    if action.graphicClass == Self.self {
                        return action.icon
                    }
                }
            }
        }
        return nil
    }

    open var activity : Activity = .any {
        willSet { willChangeValue(forKey: "activity") }
        didSet { didChangeValue(forKey: "activity") }
    }

    open class var baseVariableName : String {
        return AJRVariableNameFromClass(Self.self)
    }

    /// Mostly a convenience for inspection.
    open var baseVariableName : String {
        return Self.baseVariableName
    }

    open class func keyPathsForValuesAffectingGeneratedVariableName() -> Set<String> {
        return ["graphIndex", "groupIndex"]
    }
    
    open var generatedVariableName : String {
        // TODO: This is quite wrong, but a decent placeholder for the moment. What this needs to do is walk the graph we belong to, generating a unique variable index.
        if groupIndex != 0 {
            return Self.baseVariableName + String(describing: groupIndex)
        } else {
            return Self.baseVariableName
        }
    }

    private func validateVariableName(_ name: String) -> String? {
        return name
    }

    private var _variableName : String?
    open var variableName : String! {
        get {
            return _variableName ?? generatedVariableName
        }
        set {
            willChangeValue(forKey: "variableName")
            if newValue.isEmpty {
                _variableName = nil
            } else {
                _variableName = validateVariableName(newValue)
            }
            didChangeValue(forKey: "variableName")
        }
    }

    /// Used by the inspector, as this can actually be nil, which we want, but only in the inspector
    open var inspectedVariableName : String? {
        get {
            return _variableName
        }
        set {
            if let newValue = newValue {
                if newValue.isEmpty {
                    _variableName = nil
                } else {
                    _variableName = validateVariableName(newValue)
                }
            } else {
                _variableName = nil
            }
        }
    }
    
    open var groupIndex : Int = 0 {
        willSet { willChangeValue(forKey: "groupIndex") }
        didSet { didChangeValue(forKey: "groupIndex") }
    }
    
    open var graphIndex : Int = 0 {
        willSet { willChangeValue(forKey: "graphIndex") }
        didSet { didChangeValue(forKey: "graphIndex") }
    }

    public var aieDocument : AIEDocument? { return document as? AIEDocument }
    
    // MARK: - Creation

    public required override init() {
        super.init()
    }

    public required override init(frame: NSRect) {
        super.init(frame: frame)
    }

    // MARK: - Default Values
    
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
    
    // MARK: - DrawGraphic
    
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

    /// Overriden to re-compute the graph locations when the relationships on the node change.
    open override func add(toRelatedGraphics graphic: DrawGraphic) {
        super.add(toRelatedGraphics: graphic)
        computeGraphLocations()
    }
    
    /// Overriden to re-compute the graph locations when the relationships on the node change.
    open override func remove(fromRelatedGraphics graphic: DrawGraphic) {
        super.remove(fromRelatedGraphics: graphic)
        computeGraphLocations()
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
        if let variableName = _variableName {
            coder.encode(variableName, forKey: "variableName")
        }
        if activity != .any {
            coder.encode(activity, forKey: "activity")
        }
    }

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeEnumeration(forKey: "activity") { (value: Activity?) in
            self.activity = value ?? .any
        }
        coder.decodeString(forKey: "variableName") { name in
            // We assign directly into _variableName, because variable is "nil-resettable", so just to be safe, we by-pass the additional logic of that.
            self._variableName = name
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
    
    internal func traverse(graph: AIEGraphic, visited: inout Set<AIEGraphic>, counts: inout AJRCountedSet<String>) -> Void {
        if !visited.contains(graph) {
            // Note that we've visited this node.
            visited.insert(graph)
            // Increment our count by adding the baseVariableName to the counted set.
            counts.insert(graph.baseVariableName)
            // Update the graphIndex and groupIndex on the node. NOTE: because we just inserted into the set, it's safe to force unwrap the call to counts.count(for:)
            graph.graphIndex = counts.countForAll
            graph.groupIndex = counts.count(for: graph.baseVariableName)!
            // Finally, for each node graph visits, traverse.
            for child in graph.destinationObjects {
                traverse(graph: child, visited: &visited, counts: &counts)
            }
        }
    }
    
    open func computeGraphLocations() -> Void {
        if let document = aieDocument {
            // Use this at the top, as it's possible the document will find two root objects that share siblings
            var visited = Set<AIEGraphic>()
            var counts = AJRCountedSet<String>()
            for root in document.rootObjects {
                traverse(graph: root, visited: &visited, counts: &counts)
            }
        }
    }

}

// MARK: - Iteration

extension AIEGraphic : Sequence {
    
    public func makeIterator() -> some IteratorProtocol {
        return AIEGraphicIterator<Int>(root: self, userData: nil)
    }
    
    public func makeIterator<UserData>(userData: UserData) -> some IteratorProtocol {
        return AIEGraphicIterator(root: self, userData: userData)
    }
    
}

open class AIEGraphicIterator<UserData> : IteratorProtocol {

    struct StackElement {
        var graphic : AIEGraphic
        var index : Int = 0
        
        init(graphic: AIEGraphic) {
            self.graphic = graphic
        }
        
        mutating func next() -> AIEGraphic? {
            if index < graphic.destinationObjects.count {
                let object = graphic.destinationObjects[index]
                index += 1
                return object
            }
            return nil
        }
        
    }
    
    public typealias Element = AIEGraphic
    
    var root : AIEGraphic? = nil
    var stack = [StackElement]()
    var visited = Set<AIEGraphic>()
    var userData : UserData?
    
    init(root: AIEGraphic, userData: UserData?) {
        self.root = root
        self.userData = userData
    }

    public func next() -> AIEGraphic? {
        if let root = root {
            // When root is != nil, then we push it onto the stack and return it.
            stack.append(StackElement(graphic: root))
            // And then set root to nil, so we'll know when to stop.
            self.root = nil
            // And add it to visited
            visited.insert(root)
            return root
        } else if stack.count > 0 {
            let lastIndex = stack.count - 1
            if let next = stack[lastIndex].next() {
                // First, make sure we haven't visited the node.
                if !visited.contains(next) {
                    // We haven't visited it, so add it to visited.
                    visited.insert(next)
                    // We got a next, so push it onto the stack
                    stack.append(StackElement(graphic: next))
                    // And return it.
                    return next
                } else {
                    // We have visited it before, so get the next object.
                    return self.next()
                }
            } else {
                // OK, the stack didn't return next, so pop it
                stack.removeLast()
                // And call ourself to get the next possible object.
                return self.next()
            }
        }
        return nil
    }
    
}
