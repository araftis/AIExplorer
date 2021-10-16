/*
AIESourceCodeAccessory.swift
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

import Cocoa
import Draw

public let AIECodeGenerationDomain = "AIECodeGeneration"

public enum AIESourceCodeGeneratorError : Error {
    case failedToWrite(message: String)
}

public extension AJRUserDefaultsKey {

    static var outputSavePanelPath : AJRUserDefaultsKey<URL> {
        return AJRUserDefaultsKey<URL>.key(named: "outputSavePanelPath", defaultValue: AJRDocumentsDirectoryURL())
    }

}

@objcMembers
open class AIESourceCodeAccessory: DrawToolAccessory, DrawDocumentGraphicObserver {

    // MARK: - Properties

    @IBOutlet var sourceTextView : NSTextView!
    @IBOutlet var nameLabel : NSTextField!
    @IBOutlet var libraryLabel : NSTextField!
    @IBOutlet var languageLabel : NSTextField!
    @IBOutlet var roleLabel : NSTextField!
    @IBOutlet var pathLabel : NSTextField!

    internal var observationTokens = [AJRInvalidation]()
    
    open var aiDocument : AIEDocument {
        // This is harsh, but if we ever belong to a plain document, the world is pretty muc borked anyways.
        return document as! AIEDocument
    }

    deinit {
        observationTokens.invalidateObjects()
        observationTokens.removeAll()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    // MARK: - DrawViewController

    open override func documentDidLoad(_ document: DrawDocument) {
        updateObservations()
        document.addGraphicObserver(self)
        updateUI(for: aiDocument.selectedCodeDefinition)
    }
    
    open func updateObservations() -> Void {
        observationTokens.invalidateObjects()
        observationTokens.removeAll()
        
        weak var weakSelf = self
        if let document = document as? AIEDocument {
            observationTokens.append(document.addObserver(self, forKeyPath: "codeDefinitions", options: [], block: { (document, key, change) in
                AJRLog.debug(in: AIECodeGenerationDomain, "Code definitions changed.")
            }))
            // These are probably all going to move onto the code definition.
            for codeDefinition in document.codeDefinitions {
                observationTokens.append(codeDefinition.addObserver(self, forKeyPath: "name", options: [], block: { codeDefinition, key, change in
                    weakSelf?.updateNameLabel(for: codeDefinition as? AIECodeDefinition)
                }))
                observationTokens.append(codeDefinition.addObserver(self, forKeyPath: "language", options: [], block: { codeDefinition, key, change in
                    weakSelf?.updateLanguageLabel(for: codeDefinition as? AIECodeDefinition)
                }))
                observationTokens.append(codeDefinition.addObserver(self, forKeyPath: "library", options: [], block: { codeDefinition, key, change in
                    weakSelf?.updateLibraryLabel(for: codeDefinition as? AIECodeDefinition)
                }))
                observationTokens.append(codeDefinition.addObserver(self, forKeyPath: "role", options: [], block: { codeDefinition, key, change in
                    weakSelf?.updateRoleLabel(for: codeDefinition as? AIECodeDefinition)
                }))
                observationTokens.append(codeDefinition.addObserver(self, forKeyPath: "outputURL", options: [], block: { codeDefinition, key, change in
                    weakSelf?.updatePathLabel(for: codeDefinition as? AIECodeDefinition)
                }))
                observationTokens.append(codeDefinition.addObserver(self, forKeyPath: "code", options: [], block: { codeDefinition, key, change in
                    weakSelf?.updateCode(for: codeDefinition as? AIECodeDefinition)
                }))
            }
            observationTokens.append(document.addObserver(self, forKeyPath: "selectedCodeDefinition", options: [], block: { document, key, change in
                AJRLog.debug(in: AIECodeGenerationDomain, "Selected definition changed.")
                weakSelf?.updateUI(for: weakSelf?.aiDocument.selectedCodeDefinition)
            }))
        }
    }

    // MARK: - UI

    /**
     Generates code for every code definition in the current document. This can be a little heavy handed at times, but should always be fast enough that that doesn't matter. For example, if a code definition is added, this method might be called and new code will be generated for all definitions, not just the newly added one.
     */
    open func generateCode() -> Void {
        if let document = self.document as? AIEDocument {
            for codeDefinition in document.codeDefinitions {
                codeDefinition.generateCode()
            }
        }
    }
    
    open func update(field: NSTextField, value: String?, defaultValue: String, for codeDefinition: AIECodeDefinition?) -> Void {
        if codeDefinition == aiDocument.selectedCodeDefinition {
            if let value = value {
                field.stringValue = value
                field.textColor = .controlTextColor
            } else {
                field.stringValue = defaultValue
                field.textColor = .disabledControlTextColor
            }
        } else if aiDocument.selectedCodeDefinition == nil {
            field.stringValue = "No Selection"
            field.textColor = .disabledControlTextColor
        }
    }
    
    open func updateNameLabel(for codeDefinition: AIECodeDefinition?) -> Void {
        update(field: nameLabel, value: codeDefinition?.name, defaultValue: "No Name", for: codeDefinition)
    }
    
    open func updateLibraryLabel(for codeDefinition: AIECodeDefinition?) -> Void {
        update(field: libraryLabel, value: codeDefinition?.library?.name, defaultValue: "No Library", for: codeDefinition)
    }
    
    open func updateLanguageLabel(for codeDefinition: AIECodeDefinition?) -> Void {
        update(field: languageLabel, value: codeDefinition?.language?.name, defaultValue: "No Language", for: codeDefinition)
    }
    
    open func updateRoleLabel(for codeDefinition: AIECodeDefinition?) -> Void {
        if let role = codeDefinition?.role {
            let roleString : String
            switch role {
            case .deployment:
                roleString = "Deployment"
            case .training:
                roleString = "Training"
            case .deploymentAndTraining:
                roleString = "Both"
            }
            update(field: roleLabel, value: roleString, defaultValue: "", for: codeDefinition)
        } else {
            update(field: roleLabel, value: nil, defaultValue: "No Role", for: codeDefinition)
        }
    }
    
    open func updatePathLabel(for codeDefinition: AIECodeDefinition?) -> Void {
        update(field: pathLabel, value: codeDefinition?.outputURL?.path, defaultValue: "No Path", for: codeDefinition)
    }
    
    open func updateCode(for codeDefinition: AIECodeDefinition?) -> Void {
        if codeDefinition == aiDocument.selectedCodeDefinition {
            if let value = codeDefinition?.code {
                sourceTextView.textStorage?.mutableString.setString(value)
            } else {
                sourceTextView.textStorage?.mutableString.setString("")
            }
        } else if aiDocument.selectedCodeDefinition == nil {
            sourceTextView.textStorage?.mutableString.setString("")
        }
    }
    
    open func updateUI(for codeDefinition: AIECodeDefinition?) -> Void {
        updateNameLabel(for: codeDefinition)
        updateLibraryLabel(for: codeDefinition)
        updateLanguageLabel(for: codeDefinition)
        updateRoleLabel(for: codeDefinition)
        updatePathLabel(for: codeDefinition)
        updateCode(for: codeDefinition)
    }

    // MARK: - DrawGraphicObserver

    open func graphic(_ graphic: DrawGraphic, didEditKeys keys: Set<String>) {
        // We only need to generate code if the changed object was a neural network note.
        if graphic is AIEGraphic {
            print("change: \(graphic): \(keys)")
            self.generateCode()
        }
    }
    
}
