/*
 AIEImageIO.swift
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

import Draw

public extension AJRInspectorIdentifier {
    static var aieImageIO = AJRInspectorIdentifier("aieImageIO")
}

@objcMembers
open class AIEImageIO: AIEIO {

    // MARK: - Properties
    open var width : Int = 0
    open var height : Int = 0
    open var depth : Int = 0

    // MARK: - Creation

    public convenience init(width: Int, height: Int, depth: Int) {
        self.init()

        self.width = width
        self.height = height
        self.depth = depth
    }

    public required init() {
        super.init()
    }

    public required init(frame: NSRect) {
        super.init(frame: frame)
    }

    // MARK: - AIEGraphic

    open override var displayedProperties : [Property] {
        weak var weakSelf = self
        return [Property("Size", {
                        if let self = weakSelf {
                            var string = ""
                            string += "\(self.width == 0 ? "Any" : String(describing: self.width)) ✕ \(self.height == 0 ? "Any" : String(describing: self.height))"
                            if self.depth > 0 {
                                if !string.isEmpty {
                                    string += " ✕ "
                                }
                                string += "\(self.depth)"
                            }
                            return string.isEmpty ? nil : string
                        }
                        return nil
                    }),
        ]
    }



    // MARK: - AJREditableObject

    open override class func populateProperties(toObserve propertiesSet: NSMutableSet) {
        propertiesSet.add("width")
        propertiesSet.add("height")
        propertiesSet.add("depth")
        super.populateProperties(toObserve: propertiesSet)
    }

    // MARK: - AJRInspector

    open override func inspectorIdentifiers(forInspectorContent inspectorContentIdentifier: AJRInspectorContentIdentifier?) -> [AJRInspectorIdentifier] {
        var supers = super.inspectorIdentifiers(forInspectorContent: inspectorContentIdentifier)
        if inspectorContentIdentifier == .graphic {
            supers.append(.aieImageIO)
        }
        return supers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeInteger(forKey: "width") { (value) in
            self.width = value
        }
        coder.decodeInteger(forKey: "height") { (value) in
            self.height = value
        }
        coder.decodeInteger(forKey: "depth") { (value) in
            self.depth = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(width, forKey: "width")
        coder.encode(height, forKey: "height")
        coder.encode(depth, forKey: "depth")
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "aieImageIO"
    }

    open override var type : AIEIO.Kind { return .image }

    // MARK: - Shape
    
    open override var inputShape: [Int]? {
        return [batchSize, width, height, depth]
    }

    open override var outputShape: [Int] {
        return [batchSize, width, height, depth]
    }

}
