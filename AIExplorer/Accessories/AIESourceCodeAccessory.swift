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

    @IBOutlet var languagePopUp : NSPopUpButton!
    @IBOutlet var outputPath : NSTextField!
    @IBOutlet var chooseOutputButton : NSButton!
    @IBOutlet var sourceTextView : NSTextView!

    internal var libraryObservationToken : AJRInvalidation?
    internal var languageObservationToken : AJRInvalidation?
    internal var sourceOutputObservationToken : AJRInvalidation?

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    // MARK: - DrawViewController

    open override func documentDidLoad(_ document: DrawDocument) {
        weak var weakSelf = self
        libraryObservationToken = document.addObserver(document, forKeyPath: "aiLibrary", options: [.initial], block: { (document, key, change) in
            // This pattern makes sure the weak reference to self stays valid until we're done with our call.
            if let strongSelf = weakSelf {
                strongSelf.updateLibrary()
            }
        })
        languageObservationToken = document.addObserver(document, forKeyPath: "aiLanguage", options: [.initial], block: { (document, key, change) in
            weakSelf?.updateLanguage()
        })
        sourceOutputObservationToken = document.addObserver(document, forKeyPath: "sourceOutputURL", options: [.initial], block: { (document, key, change) in
            weakSelf?.updateSourceOutputURL()
        })

        document.addGraphicObserver(self)
    }

    // MARK: - Actions

    @IBAction open func chooseOutputPath(_ sender: Any?) -> Void {
        let savePanel = NSSavePanel.init()
        if let document = self.document as? AIEDocument,
           let url = document.codeDefinitions.last?.outputURL {
            savePanel.directoryURL = url.deletingLastPathComponent()
            savePanel.nameFieldStringValue = url.lastPathComponent
        } else {
            let url = UserDefaults[.outputSavePanelPath]!
            savePanel.directoryURL = url
        }
        savePanel.beginSheetModal(for: languagePopUp.window!) { (response) in
            if response == .OK {
                if let document = self.document as? AIEDocument {
                    document.codeDefinitions.last?.outputURL = savePanel.url
                    self.regenerateCode()
                }
                UserDefaults[.outputSavePanelPath] = savePanel.directoryURL
            }
        }
    }

    @IBAction open func chooseLanguage(_ sender: Any?) -> Void {
        if let language = languagePopUp.selectedItem?.representedObject as? AIELanguage,
           let document = document as? AIEDocument {
            document.codeDefinitions.last?.language = language
        }
    }

    // MARK: - UI

    open func updateLibrary() -> Void {
        if let document = self.document as? AIEDocument {
            if let library = document.codeDefinitions.last?.library {
                let languages = library.supportedLanguagesForCodeGeneration
                languagePopUp.removeAllItems()
                for language in languages {
                    languagePopUp.addItem(withTitle: language.name)
                    if let item = languagePopUp.lastItem {
                        // We do this, because eventually we many add translations, so we want to make sure we can map back to the language
                        item.representedObject = language
                    }
                }
                regenerateCode()
            }
        }
    }

    open func updateLanguage() -> Void {
        if let document = document as? AIEDocument {
            if let language = document.codeDefinitions.last?.language {
                for (index, childItem) in languagePopUp.itemArray.enumerated() {
                    if (childItem.representedObject as? AIELanguage) == language {
                        languagePopUp.selectItem(at: index)
                        regenerateCode()
                        break
                    }
                }
            }
        }
    }

    open func updateSourceOutputURL() -> Void {
        if let document = document as? AIEDocument {
            if let url = document.codeDefinitions.last?.outputURL {
                outputPath.stringValue = url.path
            } else {
                outputPath.stringValue = ""
            }
        }
    }

    open var sourceOutputURL : URL? {
        return (document as? AIEDocument)?.codeDefinitions.last?.outputURL
    }

    open func write(code: String, to url: URL) throws -> Void {
        let manager = FileManager.default

        try manager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        if let data = code.data(using: .utf8) {
            try data.write(to: url, options: [.atomic])
        } else {
            throw AIESourceCodeGeneratorError.failedToWrite(message: "Couldn't convert source code to UTF-8")
        }
    }

    open func regenerateCode() -> Void {
        if let document = self.document as? AIEDocument,
           let codeDefinition = document.codeDefinitions.last,
           let language = languagePopUp.selectedItem?.representedObject as? AIELanguage,
           let library = codeDefinition.library {
            for object in document.rootObjects {
                if let generator = library.codeGenerator(for: language, root: object) {
                    let outputStream = OutputStream.toMemory()
                    outputStream.open()
                    do {
                        try generator.generate(to: outputStream)
                    } catch let error as NSError {
                        AJRLog.warning("Error generating code: \(error.localizedDescription)")
                    }
                    if let string = outputStream.dataAsString(using: .utf8) {
                        sourceTextView.textStorage?.setAttributedString(NSAttributedString(string: string, attributes: [.font:NSFont.userFixedPitchFont(ofSize: 13.0)!]))
                        if let sourceOutputURL = sourceOutputURL {
                            do {
                                try write(code: string, to: sourceOutputURL)
                            } catch {
                                // TODO: This should present in the UI somehow.
                                AJRLog.error("Failed to write code to \(sourceOutputURL.path): \(error)")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - DrawGraphicObserver

    open func graphic(_ graphic: DrawGraphic, didEditKeys keys: Set<String>) {
        print("change: \(graphic): \(keys)")
        self.regenerateCode()
    }
    
}
