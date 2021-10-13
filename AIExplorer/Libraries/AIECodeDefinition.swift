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
@objcMembers
open class AIECodeDefinition: NSObject, AJRXMLCoding {

    public enum Role : CaseIterable {
        case deployment
        case training
        case deploymentAndTraining
        
        init?(string: String) {
            if let found = Self.allCases.first(where: { string == "\($0)" }) {
                self = found
            } else {
                return nil
            }
        }
    }

    /* NOTE: All of these properties are nullable, but the object won't really be useable until they're defined. They're nullable in order to allow the user to populate them via the UI. */

    /** Defines a name. This is mostly useful for the user to track what they've created the code object for. */
    open var name : String?
    /** The output path. */
    open var outputURL : URL? {
        willSet {
            self.willChangeValue(forKey: "outputURL")
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
            self.didChangeValue(forKey: "outputURL")
        }
    }
    /** The library to use. */
    open var library : AIELibrary?
    /** A language supported by library. */
    open var language : AIELanguage?
    /** What type of code should be generated. */
    open var role : AIECodeDefinition.Role = .deploymentAndTraining

    // MARK: - Creation

    public override init() {
        self.name = "Untitled";
    }

    // MARK: - XML Coding

    open override class var ajr_nameForXMLArchiving: String {
        return "codeDefinition";
    }

    open func encode(with coder: AJRXMLCoder) {
        if let name = name {
            coder.encode(name, forKey: "name")
        }
        if let library = library {
            coder.encode(library.identifier.rawValue, forKey: "library")
        }
        if let language = language {
            coder.encode(language.identifier, forKey: "language")
        }
        if let url = outputURL {
            coder.encodeURLBookmark(url, forKey: "outputURL")
        }
        if role != .deploymentAndTraining {
            coder.encode("\(role)", forKey: "role")
        }
    }

    open func decode(with coder: AJRXMLCoder) {
        coder.decodeObject(forKey: "name") { value in
            // Typecast should never fail, but since this is coming from an external file, let's be safe, just in case.
            self.name = value as? String
        }
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
        self.role = .deploymentAndTraining // Set to default, and then override if present.
        coder.decodeString(forKey: "role") { value in
            self.role = Role(string: value) ?? .deploymentAndTraining
        }
    }

    // MARK: - Inspection
    
    // These methods are needed because Swift doesn't necessarily play well with UI in all cases.
    
    open class func keyPathsForValuesAffectingInspectedRole() -> Set<String> {
        return ["role"]
    }
    
    open var inspectedRole : String {
        get {
            switch role {
            case .deploymentAndTraining:
                return "Both"
            case .deployment:
                return "Deployment"
            case .training:
                return "Training"
            }
        }
        set {
            if newValue == "Both" {
                role = .deploymentAndTraining
            } else if newValue == "Deployment" {
                role = .deployment
            } else if newValue == "Training" {
                role = .training
            }
        }
    }
    

}
