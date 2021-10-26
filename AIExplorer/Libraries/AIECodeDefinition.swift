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
open class AIECodeDefinition: AJREditableObject, AJRXMLCoding {

    @objc
    public enum Role : Int, CaseIterable {
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
    open var name : String? {
        willSet {
            self.willChangeValue(forKey: "name")
        }
        didSet {
            self.didChangeValue(forKey: "name")
            scheduleCodeUpdate()
        }
    }
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
            scheduleCodeUpdate()
        }
    }
    /** The library to use. */
    open var library : AIELibrary? {
        willSet {
            self.willChangeValue(forKey: "library")
        }
        didSet {
            self.didChangeValue(forKey: "library")
            scheduleCodeUpdate()
//            if let language = language {
//                if let library = library {
//                    if !library.supportsLanguageForCodeGeneration(language) {
//                        self.language = library.preferredLanguage
//                    }
//                } else {
//                    self.language = nil
//                }
//            } else {
//                if let library = library {
//                    self.language = library.preferredLanguage
//                }
//            }
        }
    }
    /** A language supported by library. */
    open var language : AIELanguage? {
        willSet {
            self.willChangeValue(forKey: "language")
        }
        didSet {
            self.didChangeValue(forKey: "language")
            scheduleCodeUpdate()
        }
    }
    /** What type of code should be generated. */
    open var role : AIECodeDefinition.Role = .deploymentAndTraining {
        willSet {
            self.willChangeValue(forKey: "role")
        }
        didSet {
            self.didChangeValue(forKey: "role")
            scheduleCodeUpdate()
        }
    }
    /** Keeps a back pointer to our document. */
    open weak var document : AIEDocument? = nil

    /** The generated code. This is simple a cache for display purposes, but it's possible that could be expanded in the future. It's never archived. */
    open var code : String? {
        willSet {
            willChangeValue(forKey: "code")
        }
        didSet {
            didChangeValue(forKey: "code")
        }
    }

    // MARK: - Creation

    /**
     This initialization is needed by XML unarchiving, and generally speaking, it's not the init you want to call.
     */
    public override init() {
        self.name = "Untitled"
    }
    
    public init(in document: AIEDocument) {
        self.name = "Untitled";
        self.document = document
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

    public func finalizeXMLDecoding() throws -> Any {
        print("<\(descriptionPrefix): \(name ?? "Untitled")>")
        return self
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
    

    // MARK: - Code Generation

    // NOTE: I Think it makes a little more sense to have this code here, now, since we actually have a definition. This code was originally on the AIESourceCodeAccessory, which isn't bad, but doesn't seem quite a logical in a world with multiple source code definitions.

    /**
     Writes the string ot the URL.
     */
    internal func write(code: String, to url: URL) throws -> Void {
        let manager = FileManager.default

        try manager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        if let data = code.data(using: .utf8) {
            try data.write(to: url, options: [.atomic])
        } else {
            throw AIESourceCodeGeneratorError.failedToWrite(message: "Couldn't convert source code to UTF-8")
        }
    }

    /**
     Generates the source code and caches is on `code`. Also writes it to disk. This method is called by `generateCode()` once all nullable objects have been resolved, which is why it isn't public. The public API is to just call `generateCode()`.
     */
    internal func generateCode(for library: AIELibrary, language: AIELanguage, to url: URL?) -> Void {
        if let document = self.document {
            for object in document.rootObjects {
                if let generator = library.codeGenerator(for: language, root: object) {
                    let outputStream = OutputStream.toMemory()
                    outputStream.open()
                    var messages = [AIEMessage]()
                    do {
                        try generator.generate(to: outputStream, accumulatingMessages: &messages)
                    } catch let error as NSError {
                        AJRLog.warning("Error generating code: \(error.localizedDescription)")
                    }
                    if let string = outputStream.dataAsString(using: .utf8) {
                        code = string
                        if let url = url {
                            do {
                                try write(code: string, to: url)
                            } catch {
                                // TODO: This should present in the UI somehow.
                                AJRLog.error("Failed to write code to \(url.path): \(error)")
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     If the receiver is in a state that can validly generate code, this method will generate the code and write it to the outputURL. The generated code will be cached, for display convenience, on `code`.
     */
    open func generateCode() -> Void {
        if let library = library,
           let language = language {
            generateCode(for: library, language: language, to: outputURL)
        }
    }
    
    internal var updateTimer : Timer? = nil
    
    /**
     Schedules that an update to the code probably needs to occur. This may seem strange, but it's quite likely that more than one property will change at a time. When that happens, we don't want to generate the code over and over again with each changing property. This allows us to just note that a change has occurred, and when that happens, we'll schedule ourself to update in the run loop when we return to it. In effect, we'll only update our code once.
     */
    open func scheduleCodeUpdate() -> Void {
//        if let timer = updateTimer {
//            timer.invalidate()
//            self.updateTimer = nil
//        }
//        // NOTE: We're not worried about a retain cycle here, because we're going to clean up as soon as we fire.
//        updateTimer = Timer(fire: Date(timeIntervalSinceNow: 0.0001), interval: 0.0, repeats: false, block: { timer in
//            self.generateCode()
//            self.updateTimer?.invalidate()
//            self.updateTimer = nil
//        })
//        RunLoop.current.add(updateTimer!, forMode: .default)
    }

}
