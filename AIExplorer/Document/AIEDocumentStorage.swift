//
//  AIEDocumentStorage.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/2/21.
//

import Draw

@objcMembers
open class AIEDocumentStorage: DrawDocumentStorage {

    // MARK: - Properties

    open var aiLibrary : AIELibrary

    // MARK: - Initialization

    public override init() {
        aiLibrary = AIELibrary.library(for: .tensorflow)!
        super.init()
    }

    // MARK: - AJRXMLCoding

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        coder.encode(aiLibrary.identifier.rawValue, forKey: "library")
    }

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)
        coder.decodeString(forKey: "library") { (identifier) in
            if let library = AIELibrary.library(for: AIELibraryIndentifier(identifier)) {
                self.aiLibrary = library
            } else {
                self.aiLibrary = AIELibrary.library(for: .tensorflow)!
            }
        }
    }

}
