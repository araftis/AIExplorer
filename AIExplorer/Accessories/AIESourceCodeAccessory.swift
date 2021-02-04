//
//  AIESourceCodeRepository.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/1/21.
//

import Cocoa
import Draw

@objcMembers
open class AIESourceCodeAccessory: DrawToolAccessory {

    // MARK: - Properties

    @IBOutlet var languagePopUp : NSPopUpButton!
    @IBOutlet var outputPath : NSTextField!
    @IBOutlet var chooseOutputButton : NSButton!
    @IBOutlet var sourceTextView : NSTextView!

    internal var libraryObservationToken : AJRInvalidation?

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
    }

    // MARK: - Actions

    @IBAction open func chooseOutputPath(_ sender: Any?) -> Void {
        
    }

    // MARK: - UI

    open func updateLibrary() -> Void {
        if let document = self.document as? AIEDocument {
            let library = document.aiLibrary
            let languages = library.supportedLanguagesForCodeGeneration
            languagePopUp.removeAllItems()
            for language in languages {
                languagePopUp.addItem(withTitle: language.name)
                if let item = languagePopUp.lastItem {
                    // We do this, because eventually we many add translations, so we want to make sure we can map back to the language
                    item.representedObject = language
                }
            }
        }
    }
    
}
