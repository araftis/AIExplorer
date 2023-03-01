/*
 AIEDocument.swift
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

    static var aieDocument = AJRInspectorIdentifier("aieDocument")

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

    /** Retypes the DrawDocumentStorage to our AIE type for easier access. */
    open var aiStorage : AIEDocumentStorage {
        return storage as! AIEDocumentStorage
    }

    // NOTE: We don't want this settable on the doucment. The user should call the appropriate add/remove methods below.
    open var codeDefinitions : [AIECodeDefinition] {
        return aiStorage.codeDefinitions
    }

    // MARK: - DrawDocument

    open override class var storageClass: AnyClass {
        return AIEDocumentStorage.self
    }

    open override func inspectorIdentifiers(forInspectorContent inspectorContentIdentifier: AJRInspectorContentIdentifier?) -> [AJRInspectorIdentifier] {
        var supers = super.inspectorIdentifiers(forInspectorContent: inspectorContentIdentifier)
        supers.append(.aieDocument)
        return supers
    }
    
    open override var storage: DrawDocumentStorage {
        get {
            return super.storage
        }
        set {
            super.storage = newValue
            selectedCodeDefinition = (newValue as! AIEDocumentStorage).selectedCodeDefinition

            // We need to make our code definitions points to us, as well as make sure they're in our editing context.
            for codeDefinition in codeDefinitions {
                codeDefinition.document = self
                addObject(toEditingContext: codeDefinition)
            }
            
            // If we have root objects, have them compute their offsets within the graph.
            self.rootObjects.first?.computeGraphLocations()

            // Make sure we have the "isTraining" variable.
            var isTraining = variableStore["isTraining"] as? AJRVariable
            if isTraining == nil {
                isTraining = variableStore.createVariable(named: "isTraining", type: .boolean, value: false)
            }
        }
    }

    // MARK: - Inspection

    /**
     Used to provide the list of libraies to the document inspector. Basically a pass through for AIELibrari.orderedLibraries.
     */
    open var allLibraries : [AIELibrary] {
        return AIELibrary.orderedLibraries
    }

    // MARK: - Code

    open func createCodeDefinition() -> AIECodeDefinition {
        let newCode = AIECodeDefinition(in: self)

        addCodeDefinition(newCode)

        return newCode
    }

    open func addCodeDefinition(_ codeDefinition: AIECodeDefinition, at index: Int) -> Void {
        let index = aiStorage.codeDefinitions.count
        self.willChange(.insertion, valuesAt: IndexSet(integer: index), forKey: "codeDefinitions")
        aiStorage.codeDefinitions.append(codeDefinition)
        codeDefinition.name = aiStorage.codeDefinitions.nextTitle(forKey: "name", basename: "Untitled")
        self.didChange(.insertion, valuesAt: IndexSet(integer: index), forKey: "codeDefinitions")
        addObject(toEditingContext: codeDefinition)
        self.registerUndo(target: self) { target in
            target.removeCodeDefinition(at: index)
        }
    }

    open func addCodeDefinition(_ codeDefinition: AIECodeDefinition) -> Void {
        self.addCodeDefinition(codeDefinition, at: codeDefinitions.count)
    }

    /**
     Removes the code definition at `index`. If `index` is  &lt; 0 or &gt;= codeDefinitions.count, an exception will be thrown.

     - parameter index: The index of the code definition to remove.
     */
    @discardableResult
    open func removeCodeDefinition(at index: Int) -> AIECodeDefinition? {
        if aiStorage.codeDefinitions[index] == selectedCodeDefinition {
            selectedCodeDefinition = nil
        }
        let codeDefinition = aiStorage.codeDefinitions[index]
        self.willChange(.removal, valuesAt: IndexSet(integer: index), forKey: "codeDefinitions")
        aiStorage.codeDefinitions.remove(at: index)
        self.didChange(.removal, valuesAt: IndexSet(integer: index), forKey: "codeDefinitions")
        removeObject(fromEditingContext: codeDefinition)
        self.registerUndo(target: self) { target in
            target.addCodeDefinition(codeDefinition, at: index)
        }
        return codeDefinition
    }

    /**
     Removes the specified code definition.

     - parameter codeDefinition: The Code definition to remove.
     */
    @discardableResult
    open func removeCodeDefinition(_ codeDefinition: AIECodeDefinition) -> AIECodeDefinition? {
        if let index = aiStorage.codeDefinitions.firstIndex(of: codeDefinition) {
            return removeCodeDefinition(at: index)
        }
        return nil
    }

    /**
     Short hand for self.removeCodeDefinition(self.selectedCodeDefinition).
     */
    open func removeSlectedCodeDefinition() -> AIECodeDefinition? {
        if let codeDefinition = selectedCodeDefinition {
            return removeCodeDefinition(codeDefinition)
        }
        return nil
    }

    /** Mostly used by the UI to indicate which code definition is currently selected in the UI. */
    open var selectedCodeDefinition : AIECodeDefinition? {
        get {
            return aiStorage.selectedCodeDefinition
        }
        set {
            if newValue !== aiStorage.selectedCodeDefinition {
                willChangeValue(forKey: "selectedCodeDefinition")
                aiStorage.selectedCodeDefinition = newValue
                didChangeValue(forKey: "selectedCodeDefinition")
            }
        }
    }
    
    /// Defines the "default" code name, where the code name is a class name, function name, or other name as needed by the code generators. The default is simple the document name, with generally non-viable characters removed.
    open var defaultCodeName : String {
        if let url = fileURL {
            var name = url.deletingPathExtension().lastPathComponent
            name = name.stringContainingOnlyCharacters(in: NSCharacterSet.ajr_swiftIdentifier())
            return name
        } else {
            return "Unknown"
        }
    }
    
    /**
     NOTE: This is a horrible hack. There's something going wrong with setValue(\_:forKey:) where where KVO tries to unregister for an observance twice, but only when the value is changed via setValue(\_:forKey:). That's wrong, in so many ways, but it's current what seems to be going on. It seems to be related, maybe, to some kind of optimazation that AppKit is doing along with something strange going on between the Obj-C and Swift bridge. This is probably worth a test case to reproduce (if I can), and filing with Apple.
     */
    open override func setValue(_ value: Any?, forKey key: String) {
        if key == "selectedCodeDefinition" {
            selectedCodeDefinition = value as? AIECodeDefinition
        } else {
            super.setValue(value, forKey: key)
        }
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

    // MARK: - Message Reporting

    open var messages = [AIEMessage]()

    open func clearMessages() -> Void {
        messages.removeAll()
        updateMessageDisplay()
    }

    open func addMessage(_ message: AIEMessage) -> Void {
        let index = IndexSet(integer: messages.count)
        self.willChange(.insertion, valuesAt: index, forKey: "messages")
        messages.append(message)
        self.didChange(.insertion, valuesAt: index, forKey: "messages")
    }

    open func addMessages(_ messages: [AIEMessage]) -> Void {
        let indexes = IndexSet(integersIn: self.messages.count ..< (self.messages.count + messages.count))
        self.willChange(.insertion, valuesAt: indexes, forKey: "messages")
        self.messages.append(contentsOf: messages)
        self.didChange(.insertion, valuesAt: indexes, forKey: "messages")
    }

    open func removeMessage(_ message: AIEMessage) -> Void {
        if let index = messages.index(ofObjectIdenticalTo: message) {
            let indexSet = IndexSet(integer: index)
            self.willChange(.removal, valuesAt: indexSet, forKey: "messages")
            messages.remove(at: index)
            self.didChange(.removal, valuesAt: indexSet, forKey: "messages")
        }
    }

    open func replaceMessages(_ newMessages : [AIEMessage]) -> Void {
        var addIndexes = IndexSet()
        var insertIndex = messages.count
        var messagesToAdd = [AIEMessage]()
        for message in newMessages {
            if !messages.contains(message) {
                addIndexes.insert(insertIndex)
                messagesToAdd.append(message)
                insertIndex += 1
            }
        }
        self.willChange(.insertion, valuesAt: addIndexes, forKey: "messages")
        messages.append(contentsOf: messagesToAdd)
        self.didChange(.insertion, valuesAt: addIndexes, forKey: "messages")

        var removeIndexes = IndexSet()
        var messagesToRemove = [AIEMessage]()
        for message in messages {
            if let index = newMessages.firstIndex(of: message) {
                removeIndexes.insert(index)
                messagesToRemove.append(message)
            }
        }
        self.willChange(.removal, valuesAt: removeIndexes, forKey: "messages")
        messages.remove(at: removeIndexes)
        self.didChange(.removal, valuesAt: removeIndexes, forKey: "messages")
    }

    open func updateMessageDisplay() -> Void {
    }

    // MARK: - Object Edits

    open override func editingContext(_ editingContext: AJREditingContext!, didObserveEditsForKeys keys: Set<AnyHashable>!, on object: Any!) {
        if let object = object as? AIECodeDefinition {
            object.generateCode()
        } else {
            super.editingContext(editingContext, didObserveEditsForKeys: keys, on: object)
        }
    }

}
