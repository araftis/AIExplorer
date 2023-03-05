/*
 AIEImageDataSource.swift
 AIExplorer

 Copyright © 2023, AJ Raftis and AIExplorer authors
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

import Cocoa

public extension AIEDataSourceIndentifier {

    // Just gives us place to scope our identifiers.
    struct image {
    }

}

@objcMembers
open class AIEImageDataSource: AIEDataSource, AJRXMLCoding, AIEMessageObject, AIEWritableObject {
    
    open class var defaultWidth : Int { return 0 }
    open class var defaultHeight : Int { return 0 }
    open class var defaultDepth : Int { return 0 }

    open class func keyPathsForValuesAffectingInspectedWidth() -> Set<String> {
        return ["inspectedShape"]
    }
    @AJRObjCObservable(key: "width") open var width : Int = 0
    open class func keyPathsForValuesAffectingInspectedHeight() -> Set<String> {
        return ["inspectedShape"]
    }
    @AJRObjCObservable(key: "height") open var height : Int = 0
    open class func keyPathsForValuesAffectingInspectedDepth() -> Set<String> {
        return ["inspectedShape"]
    }
    @AJRObjCObservable(key: "depth") open var depth : Int = 0
    
    open class func keyPathsForValuesAffectingInspectedShape() -> Set<String> {
        return ["width", "height", "depth"]
    }
    open var inspectedShape : AIEShape {
        get {
            return AIEShape(width: width, height: height, depth: depth)
        }
        set {
            willChangeValue(forKey: "inspectedShape")
            if width != newValue.width {
                width = newValue.width
            }
            if height != newValue.height {
                height = newValue.height
            }
            if depth != newValue.depth {
                depth = newValue.depth
            }
            didChangeValue(forKey: "inspectedShape")
        }
    }
    
    open override class var propertiesToIgnore: Set<String>? {
        if var properties = super.propertiesToIgnore {
            properties.insert("inspectedShape")
            properties.insert("localizedName")
            return properties
        }
        return nil
    }

    open var localizedName : String {
        return AIEImageDataSource.dataSource(forClass: type(of: self))?.localizedName ?? String(describing: type(of: self))
    }

    // MARK: - Creation

    required public init() {
        self.width = Self.defaultWidth
        self.height = Self.defaultHeight
        self.depth = Self.defaultDepth
        super.init()
    }

    // MARK: - AJRXMLCoding

    open func encode(with coder: AJRXMLCoder) {
        if width != Self.defaultWidth {
            coder.encode(width, forKey: "width")
        }
        if height != Self.defaultHeight {
            coder.encode(height, forKey: "height")
        }
        if depth != Self.defaultDepth {
            coder.encode(depth, forKey: "depth")
        }
    }

    open func decode(with coder: AJRXMLCoder) {
        coder.decodeInteger(forKey: "width") { value in
            self.width = value
        }
        coder.decodeInteger(forKey: "height") { value in
            self.height = value
        }
        coder.decodeInteger(forKey: "depth") { value in
            self.depth = value
        }
    }

    open override var ajr_nameForXMLArchiving: String {
        return "aieImageDataSource"
    }
    
    // MARK: - NSObject
    
    open override var description: String {
        var string = "<" + descriptionPrefix
        string += ", type: \(localizedName)"
        string += ", width: \(width)"
        string += ", height: \(width)"
        string += ", depth: \(depth)"
        string += ">"
        return string
    }

    // MARK: - AIEMessageObject
    
    public var messagesTitle: String {
        return "Image Data Source"
    }
    
    public var messagesImage: NSImage? {
        return nil
    }

    public var kind: AIEGraphic.Kind {
        return .support
    }
    
    public var destinationObjects: [AIEGraphic] {
        return []
    }
    
    public var variableName: String {
        return ""
    }
    
    public var inputShape: [Int]? {
        return nil
    }
    
    public var outputShape: [Int] {
        return []
    }
    

}
