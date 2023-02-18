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

// Convenience
internal extension Int {
    var anyIf0 : String {
        return self == 0 ? "Any" : String(describing: self)
    }
}

@objcMembers
open class AIEImageIO: AIEIO {
    
    // MARK: - Properties

    @AJREditableFriend(key: "dataSource") open var dataSource : AIEImageDataSource = AIEImageDataSource()
    
    open var inspectedDataSource : AIEDataSource.Placeholder? {
        get {
            let placeholder = AIEImageDataSource.dataSource(forClass: Swift.type(of: dataSource))
            return placeholder
        }
        set {
            document?.removeObject(fromEditingContext: dataSource)
            if let newValue {
                let width = dataSource.width
                let height = dataSource.height
                let depth = dataSource.depth
                if let newDataSource = newValue.dataSourceClass.init() as? AIEImageDataSource {
                    newDataSource.width = width
                    newDataSource.height = height
                    newDataSource.depth = depth
                    dataSource = newDataSource
                }
            }
        }
    }
    
    open var inspectedAllDataSources : [AIEDataSource.Placeholder] {
        return AIEImageDataSource.allDataSources
    }

    // MARK: - Creation

    public convenience init(width: Int, height: Int, depth: Int) {
        self.init()

        self.dataSource.width = width
        self.dataSource.height = height
        self.dataSource.depth = depth
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
        return [Property("Source", {
                        return weakSelf?.dataSource.localizedName
                    }),
                Property("Size", {
                        if let self = weakSelf {
                            var string = ""
                            string += self.dataSource.width.anyIf0
                            string += "✕"
                            string += self.dataSource.height.anyIf0
                            string += "✕"
                            string += self.dataSource.depth.anyIf0
                            return string.isEmpty ? nil : string
                        }
                        return nil
                    }),
        ]
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
        
        coder.decodeObject(forKey: "dataSource") { value in
            if let value = value as? AIEImageDataSource {
                self.dataSource = value
            } else {
                self.dataSource = AIEImageDataSource()
            }
        }

        // NOTE: These are here for backwards compatibility, and won't generally be called, as these parameters are no longer written as part of the AIEImageIO class, but as part of the data source.
        coder.decodeInteger(forKey: "width") { (value) in
            self.dataSource.width = value
        }
        coder.decodeInteger(forKey: "height") { (value) in
            self.dataSource.height = value
        }
        coder.decodeInteger(forKey: "depth") { (value) in
            self.dataSource.depth = value
        }
    }
    
    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(dataSource, forKey: "dataSource")
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "aieImageIO"
    }

    open override var type : AIEIO.Kind { return .image }

    // MARK: - Shape
    
    open override var inputShape: [Int]? {
        return [batchSize, dataSource.height, dataSource.width, dataSource.depth]
    }

    open override var outputShape: [Int] {
        return [batchSize, dataSource.height, dataSource.width, dataSource.depth]
    }
    
    // MARK: - Editing Context Lifecycle
    
    open override func didAdd(to context: AJREditingContext) {
        document?.addObject(toEditingContext: dataSource)
    }
    
    open override func didRemove(from context: AJREditingContext) {
        document?.removeObject(fromEditingContext: dataSource)
    }
    
}
