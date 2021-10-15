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

    internal var observationTokens = [AJRInvalidation]()

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
                    if let codeDefinition = codeDefinition as? AIECodeDefinition {
                        AJRLog.debug(in: AIECodeGenerationDomain, "Name changed: \(codeDefinition.name ?? "No Name")")
                    }
                }))
                observationTokens.append(codeDefinition.addObserver(self, forKeyPath: "language", options: [], block: { codeDefinition, key, change in
                    if let codeDefinition = codeDefinition as? AIECodeDefinition {
                        AJRLog.debug(in: AIECodeGenerationDomain, "Language changed: \(codeDefinition.language?.name ?? "No Language")")
                    }
                }))
                observationTokens.append(codeDefinition.addObserver(self, forKeyPath: "library", options: [], block: { codeDefinition, key, change in
                    if let codeDefinition = codeDefinition as? AIECodeDefinition {
                        AJRLog.debug(in: AIECodeGenerationDomain, "Library changed: \(codeDefinition.library?.name ?? "No Library")")
                    }
                }))
                observationTokens.append(codeDefinition.addObserver(self, forKeyPath: "role", options: [], block: { codeDefinition, key, change in
                    if let codeDefinition = codeDefinition as? AIECodeDefinition {
                        AJRLog.debug(in: AIECodeGenerationDomain, "Role changed: \(codeDefinition.inspectedRole)")
                    }
                }))
                observationTokens.append(codeDefinition.addObserver(self, forKeyPath: "outputURL", options: [], block: { codeDefinition, key, change in
                    if let codeDefinition = codeDefinition as? AIECodeDefinition {
                        AJRLog.debug(in: AIECodeGenerationDomain, "Output URL changed: \(codeDefinition.outputURL?.path ?? "No Output Path")")
                    }
                }))
            }
            observationTokens.append(document.addObserver(self, forKeyPath: "selectedCodeDefinition", options: [], block: { document, key, change in
                AJRLog.debug(in: AIECodeGenerationDomain, "Selected definition changed.")
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

    // MARK: - DrawGraphicObserver

    open func graphic(_ graphic: DrawGraphic, didEditKeys keys: Set<String>) {
        // We only need to generate code if the changed object was a neural network note.
        if graphic is AIEGraphic {
            print("change: \(graphic): \(keys)")
            self.generateCode()
        }
    }
    
}
