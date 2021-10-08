//
//  AIECode.swift
//  AIExplorer
//
//  Created by AJ Raftis on 10/7/21.
//

import Cocoa
import AJRFoundation

/**
 Defines a relationship from document for a source code generator. The is basically on container the library, language, and output path which can then be used to instantiate an AIECodeGenerator. Documents can have multiple AIECode objects.
 */
open class AIECode: NSObject, AJRXMLCoding {

    /* NOTE: All of these properties are nullable, but the object won't really be useable until they're defined. They're nullable in order to allow the user to populate them via the UI. */

    /** Defines a name. This is mostly useful for the user to track what they've created the code object for. */
    open var name : String?
    /** The output path. */
    open var outputURL : URL? {
        willSet {
            if let current = outputURL {
                current.stopAccessingSecurityScopedResource()
            }
        }
        didSet {
            if let current = outputURL {
                if !current.startAccessingSecurityScopedResource() {
                    AJRLog.warning("Failed to get security access to: \(current)")
                }
            }
        }
    }
    /** The library to use. */
    open var library : AIELibrary?
    /** A language supported by library. */
    open var language : AIELanguage?

    // MARK: - Creation

    public override init() {
        self.name = "Untitled";
    }

    // MARK: - XML Coding

    open override var ajr_nameForXMLArchiving: String {
        return "code";
    }

    open func encode(with coder: AJRXMLCoder) {
        if let library = library {
            coder.encode(library.identifier.rawValue, forKey: "library")
        }
        if let language = language {
            coder.encode(language.identifier, forKey: "language")
        }
        if let url = outputURL {
            coder.encodeURLBookmark(url, forKey: "outputURL")
        }
    }

    open func decode(with coder: AJRXMLCoder) {
        coder.decodeString(forKey: "library") { (identifier) in
            if let library = AIELibrary.library(for: AIELibraryIndentifier(identifier)) {
                self.library = library
            } else {
                self.library = AIELibrary.library(for: .tensorflow)!
            }
        }
        coder.decodeString(forKey: "language") { (identifier) in
            if let language = self.library?.language(for: identifier) {
                self.language = language
            } else {
                self.language = self.library?.preferredLanguage
            }
        }
        coder.decodeURLBookmark(forKey: "outputURL") { (url) in
            self.outputURL = url
        }
    }


}
