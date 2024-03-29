/*
 AIESourceCodeAccessory.swift
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
import Draw

public let AIECodeGenerationDomain = "AIECodeGeneration"

public enum AIESourceCodeGeneratorError : Error {
    case failedToWrite(message: String)
}

public extension AJRUserDefaultsKey {

    static var outputSavePanelPath : AJRUserDefaultsKey<URL> {
        return AJRUserDefaultsKey<URL>.key(named: "outputSavePanelPath", defaultValue: AJRDocumentsDirectoryURL())
    }

    static var sourceCodeFont : AJRUserDefaultsKey<NSFont> {
        return AJRUserDefaultsKey<URL>.key(named: "AIESourceFont", defaultValue: NSFont.userFixedPitchFont(ofSize: NSFont.systemFontSize(for: .regular)))
    }

}

public extension Notification.Name {

    static var sourceCodeNeedsUpdate = Notification.Name("AIESourceCodeNeedsUpdate")

}

@objcMembers
open class AIESourceCodeAccessory: DrawToolAccessory, DrawDocumentGraphicObserver {

    // MARK: - Properties

    @IBOutlet var sourceTextView : NSTextView!
    @IBOutlet var namePopUp : NSPopUpButton!
    @IBOutlet var libraryLabel : NSTextField!
    @IBOutlet var languageLabel : NSTextField!
    @IBOutlet var roleLabel : NSTextField!
    @IBOutlet var pathLabel : NSTextField!
    @IBOutlet var fileNamePopUp : NSPopUpButton!

    internal var observationTokens = [AJRInvalidation]()
    internal var definitionObservationTokens = [AJRInvalidation]()

    open var aiDocument : AIEDocument {
        // This is harsh, but if we ever belong to a plain document, the world is pretty much borked anyways.
        return document as! AIEDocument
    }

    deinit {
        observationTokens.invalidateObjects()
        observationTokens.removeAll()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // This is not "just working", and I'm not going to spend time debugging right now. Besides, I think I can do this better, given a little time.
//        if let syntaxDefinition = try? AJRSyntaxDefinition(name: "Python"),
//           let syntaxTextStorage = AJRSyntaxTextStorage(syntaxDefinition: syntaxDefinition) {
//            sourceTextView.layoutManager?.replaceTextStorage(syntaxTextStorage)
//        }
    }

    // MARK: - DrawViewController

    open override func documentDidLoad(_ document: DrawDocument) {
        super.documentDidLoad(document)
        updateObservations()
        document.addGraphicObserver(self)
        updateUI(for: aiDocument.selectedCodeDefinition)
        // This notification will be coallesced and then called when idle.
        NotificationCenter.default.addObserver(forName: .sourceCodeNeedsUpdate, object: self, queue: nil) { notification in
            self.generateCode()
        }
    }

    open override func viewWillAppear() {
        self.updateUI(for: aiDocument.selectedCodeDefinition)
    }

    open func updateDefinitionObservations() {
        definitionObservationTokens.invalidateObjects()
        definitionObservationTokens.removeAll()

        weak var weakSelf = self
        for codeDefinition in aiDocument.codeDefinitions {
            definitionObservationTokens.append(codeDefinition.addObserver(self, forKeyPath: "name", options: [], block: { codeDefinition, key, change in
                weakSelf?.updateNamePopUp()
            }))
            definitionObservationTokens.append(codeDefinition.addObserver(self, forKeyPath: "language", options: [], block: { codeDefinition, key, change in
                weakSelf?.updateLanguageLabel(for: codeDefinition as? AIECodeDefinition)
            }))
            definitionObservationTokens.append(codeDefinition.addObserver(self, forKeyPath: "library", options: [], block: { codeDefinition, key, change in
                weakSelf?.updateLibraryLabel(for: codeDefinition as? AIECodeDefinition)
            }))
            definitionObservationTokens.append(codeDefinition.addObserver(self, forKeyPath: "role", options: [], block: { codeDefinition, key, change in
                weakSelf?.updateRoleLabel(for: codeDefinition as? AIECodeDefinition)
            }))
            definitionObservationTokens.append(codeDefinition.addObserver(self, forKeyPath: "outputURL", options: [], block: { codeDefinition, key, change in
                weakSelf?.updatePathLabel(for: codeDefinition as? AIECodeDefinition)
            }))
            definitionObservationTokens.append(codeDefinition.addObserver(self, forKeyPath: "code", options: [], block: { codeDefinition, key, change in
                weakSelf?.updateCode(for: codeDefinition as? AIECodeDefinition)
            }))
            definitionObservationTokens.append(codeDefinition.addObserver(self, forKeyPath: "selectedExtension", options: [], block: { codeDefinition, key, change in
                weakSelf?.updateFileNamePopUp(for: codeDefinition as? AIECodeDefinition)
                weakSelf?.updateCode(for: codeDefinition as? AIECodeDefinition)
            }))
        }
    }
    
    open func updateObservations() -> Void {
        observationTokens.invalidateObjects()
        observationTokens.removeAll()
        
        if let document = document as? AIEDocument {
            weak var weakSelf = self
            observationTokens.append(document.addObserver(self, forKeyPath: "codeDefinitions", options: [], block: { (document, key, change) in
                AJRLog.debug(in: AIECodeGenerationDomain, "Code definitions changed.")
                weakSelf?.updateDefinitionObservations()
            }))
            updateDefinitionObservations()
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
    
    open func updateNamePopUp() -> Void {
        let menu = NSMenu(title: "Code Definition")
        if aiDocument.codeDefinitions.count == 0 {
            let menuItem = menu.addItem(withTitle: "No Definitions", action: nil, keyEquivalent: "")
            menuItem.isEnabled = false
            namePopUp.isEnabled = false
        } else {
            var selected : NSMenuItem? = nil
            for codeDefinition in aiDocument.codeDefinitions {
                let menuItem = menu.addItem(withTitle: codeDefinition.name ?? "No Name", action: #selector(selectName(_:)), keyEquivalent: "")
                menuItem.representedObject = codeDefinition
                menuItem.isEnabled = true
                menuItem.target = self
                if codeDefinition === aiDocument.selectedCodeDefinition {
                    selected = menuItem
                }
            }
            namePopUp.menu = menu
            namePopUp.select(selected)
            namePopUp.isEnabled = true
        }
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
            case .inference:
                roleString = "Inference"
            case .training:
                roleString = "Training"
            case .inferenceAndTraining:
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

    open func updateFileNamePopUp(for codeDefinition: AIECodeDefinition?) -> Void {
        var showNoSelection = true

        if let codeDefinition = codeDefinition,
           codeDefinition == aiDocument.selectedCodeDefinition {
            let names = codeDefinition.fileNames
            if names.count > 0 {
                let selectedExtension = codeDefinition.selectedExtension
                var itemToSelect : NSMenuItem? = nil

                fileNamePopUp.isEnabled = true
                fileNamePopUp.removeAllItems()
                for fileName in names {
                    fileNamePopUp.addItem(withTitle: fileName)
                    if let item = fileNamePopUp.lastItem {
                        item.representedObject = fileName
                        if selectedExtension == (fileName as NSString).pathExtension {
                            itemToSelect = item
                        }
                    }
                }
                if let itemToSelect = itemToSelect {
                    fileNamePopUp.select(itemToSelect)
                }
                showNoSelection = false
            }
        }

        if showNoSelection {
            fileNamePopUp.removeAllItems()
            fileNamePopUp.addItem(withTitle: "No Selection")
            fileNamePopUp.isEnabled = false
        }
    }
    
    open func updateCode(for codeDefinition: AIECodeDefinition?) -> Void {
        if isViewLoaded,
           let textStorage = sourceTextView.textStorage {
            if codeDefinition == aiDocument.selectedCodeDefinition {
                if let value = codeDefinition?.code, let fileName = fileNamePopUp.selectedItem?.representedObject as? String {
                    let pathExtension = (fileName as NSString).pathExtension
                    if let code = value[pathExtension] {
                        textStorage.mutableString.setString(code)
                    }
                } else {
                    textStorage.mutableString.setString("")
                }
            } else if aiDocument.selectedCodeDefinition == nil {
                textStorage.mutableString.setString("")
            }
            textStorage.addAttribute(.font, value: UserDefaults[.sourceCodeFont]!, range: textStorage.mutableString.fullRange)
        }
    }
    
    open func updateUI(for codeDefinition: AIECodeDefinition?) -> Void {
        if isViewLoaded {
            // We only update the UI if our view has been loaded.
            updateNamePopUp()
            updateLibraryLabel(for: codeDefinition)
            updateLanguageLabel(for: codeDefinition)
            updateRoleLabel(for: codeDefinition)
            updatePathLabel(for: codeDefinition)
            updateFileNamePopUp(for: codeDefinition)
            updateCode(for: codeDefinition)
        }
    }

    // MARK: - DrawGraphicObserver

    open func graphic(_ graphic: DrawGraphic, didEditKeys keys: Set<String>) {
        // We only need to generate code if the changed object was a neural network note.
        if graphic is AIEGraphic {
            NotificationQueue.default.enqueue(Notification(name: .sourceCodeNeedsUpdate, object: self, userInfo: [:]), postingStyle: .whenIdle, coalesceMask: [.onName, .onSender], forModes: nil)
        }
    }

    // MARK: - NSNibAwakening
    
    open override func awakeFromNib() -> Void {
        if let storage = sourceTextView.textStorage {
            storage.addAttribute(.font, value: UserDefaults[.sourceCodeFont]!, range: storage.mutableString.fullRange)
        }
    }

    // MARK: - Actions

    @IBAction
    open func selectFileName(_ sender: Any?) -> Void {
        if let ext = (fileNamePopUp.selectedItem?.representedObject as? NSString)?.pathExtension {
            aiDocument.selectedCodeDefinition?.selectedExtension = ext
        }
    }

    @IBAction
    open func selectName(_ sender: NSMenuItem?) -> Void {
        if let selected = sender?.representedObject as? AIECodeDefinition {
            aiDocument.selectedCodeDefinition = selected
        }
    }

}
