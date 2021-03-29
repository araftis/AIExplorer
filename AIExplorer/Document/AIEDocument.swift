/*
AIEDocument.swift
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

import Draw

public extension AJRInspectorIdentifier {

    static var aiDocument = AJRInspectorIdentifier("aiDocument")

}

@objcMembers
open class AIEDocument: DrawDocument {

    // MARK: - Creation

    public convenience init(fromTemplateURL url: URL) throws {
        try self.init(type: "com.ajr.neuralnet")

        let storagePath = url.appendingPathComponent("document").appendingPathExtension("nn")
        let data = try Data(contentsOf: storagePath)
        if let storage = try AJRXMLUnarchiver.unarchivedObject(with: data, topLevelClass: Self.storageClass) as? AIEDocumentStorage {
            self.storage = storage
        }
    }

    // MARK: - Properties

    open var aiStorage : AIEDocumentStorage {
        return storage as! AIEDocumentStorage
    }

    open var aiLibrary : AIELibrary {
        get {
            return aiStorage.aiLibrary
        }
        set(newValue) {
            willChangeValue(forKey: "aiLibrary")
            aiStorage.aiLibrary = newValue
            if let newLanguage = newValue.language(for: aiLanguage.identifier) {
                aiLanguage = newLanguage
            } else {
                aiLanguage = newValue.preferredLanguage
            }
            didChangeValue(forKey: "aiLibrary")
        }
    }

    // NOTE: Has ai prefix, because language could easily (likely?) become defined on the superclass someday.
    open var aiLanguage : AIELanguage {
        get {
            return aiStorage.aiLanguage
        }
        set(newValue) {
            willChangeValue(forKey: "aiLanguage")
            aiStorage.aiLanguage = newValue
            didChangeValue(forKey: "aiLanguage")
        }
    }

    open var sourceOutputURL : URL? {
        get {
            return aiStorage.sourceOutputURL
        }
        set(newValue) {
            willChangeValue(forKey: "sourceOutputURL")
            aiStorage.sourceOutputURL = newValue
            didChangeValue(forKey: "sourceOutputURL")
        }
    }

    // MARK: - DrawDocument

    open override class var storageClass: AnyClass {
        return AIEDocumentStorage.self
    }

    open override var inspectorIdentifiers: [AJRInspectorIdentifier] {
        var identifiers = super.inspectorIdentifiers
        identifiers.append(AJRInspectorIdentifier.aiDocument)
        return identifiers
    }

    // MARK: - Inspection

    /**
     Used to provide the list of libraies to the document inspector. Basically a pass through for AIELibrari.orderedLibraries.
     */
    open var allLibraries : [AIELibrary] {
        return AIELibrary.orderedLibraries
    }

    // MARK: - AI Objects

    /**
     Returns all graphics that represent "origin" obejcts in the canvas. An origin object is an object that may have outgoing to links to other layers, it has no incoming layers.

     NOTE: This may not be sufficient, because you could "loop" back to a start point. For now I'm going to go with this, but we just need to keep in mind that this might need to be revisited. In the very least, we may need to combine it with a mechanism where the user can flag a graphic as a "start" node. That being said, because the start node will often be an input type, and those won't be looped back into, I think this'll work most of the time.
     */
    var rootObjects : [AIEGraphic] {
        var rootObjects = [AIEGraphic]()
        for page in pages {
            for layer in layers {
                for graphic in page.graphics(for: layer) {
                    if let graphic = graphic as? AIEGraphic,
                       graphic.sourceObjects.count == 0 {
                        rootObjects.append(graphic)
                    }
                }
            }
        }
        return rootObjects
    }

}
