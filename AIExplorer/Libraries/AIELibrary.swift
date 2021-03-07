//
//  AIELibrary.swift
//  AIExplorer
//
//  Created by AJ Raftis on 1/25/21.
//

import Cocoa
import AJRFoundation
import Draw

public struct AIELibraryIndentifier : RawRepresentable, Equatable, Hashable {

    public typealias RawValue = String

    public var rawValue: String

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    static var unknown = AIELibraryIndentifier("unknown")
}

/**
 This is a small contained class to describe a programming language. This is a class rather than a struct for Obj-C interoperability.
 */
@objcMembers public class AIELanguage : NSObject, Comparable, AJRInspectorChoiceTitleProvider {

    public var name : String
    public var identifier : String

    public init(name: String, identifier: String) {
        self.name = name
        self.identifier = identifier
        super.init()
    }

    public convenience init?(properties: [String:String]) {
        if let name = properties["name"], let identifier = properties["identifier"] {
            self.init(name: name, identifier: identifier)
        } else {
            return nil
        }
    }

    // MARK: - Comparable

    public static func < (lhs: AIELanguage, rhs: AIELanguage) -> Bool {
        return lhs.name < rhs.name
    }

    // MARK: - CustomStringConvertible

    public override var description: String {
        return "<\(descriptionPrefix): \(name)>"
    }

    // MARK: - Hashable

    public override var hash: Int { return identifier.hash }

    // MARK: - Equatable

    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? AIELanguage {
            return self.identifier == object.identifier
        }
        return false
    }

    // MARK: - Inspection

    public var titleForInspector: String? { return name }

    public var imageForInspector: NSImage? { return nil }

}

/**
 Defines the superclass of libaries used by AI Explorer. A library represents a AI toolkit, such as TensorFlow or Apple's own ML Compute.
 */
@objcMembers
open class AIELibrary: NSObject, AJRInspectorChoiceTitleProvider {

    // MARK: - Factory

    internal static var librariesById = [AIELibraryIndentifier:AIELibrary]()

    @objc(registerLibrary:properties:)
    open class func register(library: AIELibrary.Type, properties: [String:Any]) -> Void {
        if let libraryClass = properties["class"] as? AIELibrary.Type,
           let rawId = properties["id"] as? String,
           let name = properties["name"] as? String {
            let identifier = AIELibraryIndentifier(rawValue: rawId)
            let url = properties["url"] as? URL
            let library = libraryClass.init(id: identifier, name: name, url: url)
            librariesById[identifier] = library
            AJRLog.in(domain: DrawPlugInLogDomain, level: .debug, message: "Library: \(libraryClass)")
        }
    }

    open class func library(for id: AIELibraryIndentifier) -> AIELibrary? {
        return librariesById[id]
    }

    /** All the libraries sorted by their name. */
    open class var orderedLibraries : [AIELibrary] {
        return librariesById.values.sorted { (lhs, rhs) -> Bool in
            return lhs.name < rhs.name
        }
    }

    // MARK: - Properties

    open var identifier : AIELibraryIndentifier
    open var name : String /// Name of the library
    open var url : URL? /// A url that points to the library's homepage.

    // The preferred language of the library. Not very smart right now.
    open var preferredLanguage : AIELanguage {
        let language = supportedLanguagesForCodeGeneration.first
        assert(language != nil, "AIELibraries must support at least one code generation language.")
        return language!
    }

    // MARK: - Creation

    public required init(id: AIELibraryIndentifier, name : String, url : URL?) {
        self.identifier = id
        self.name = name
        self.url = url
    }

    // MARK: - Source Code Generation

    open func language(for identifier: String) -> AIELanguage? {
        for language in supportedLanguagesForCodeGeneration {
            if language.identifier == identifier {
                return language
            }
        }
        return nil
    }

    open var supportedLanguagesForCodeGeneration : [AIELanguage] {
        var allLanguages = Set<AIELanguage>()

        for codeGenerator in codeGenerators {
            for language in codeGenerator.languages {
                allLanguages.insert(language)
            }
        }

        return allLanguages.sorted()
    }

    internal struct CodeGenerator {
        var generatorClass : AIECodeGenerator.Type
        var languages : [AIELanguage]
    }

    private var _codeGenerators : [CodeGenerator]? = nil
    /**
     All of the code generators supported by the library.
     */
    internal var codeGenerators : [CodeGenerator] {
        if _codeGenerators == nil {
            _codeGenerators = [CodeGenerator]()
            if let rawGenerators = AJRPlugInManager.shared.extensionPoint(forName: "aie-library")?.value(forProperty: "codeGenerators", onExtensionFor: type(of: self)) as? [[String:Any]] {
                for rawGenerator in rawGenerators {
                    if let generatorClass = rawGenerator["class"] as? AIECodeGenerator.Type,
                       let rawLanguages = rawGenerator["languages"] as? [[String:String]] {
                        var languages = [AIELanguage]()
                        for rawLanguage in rawLanguages {
                            if let language = AIELanguage(properties: rawLanguage) {
                                languages.append(language)
                            }
                        }
                        _codeGenerators!.append(CodeGenerator(generatorClass: generatorClass, languages: languages))
                    }
                }
            }
        }
        return _codeGenerators!
    }

    /**
     A code generator for a specific language.
     */
    open func codeGenerator(for language: AIELanguage, root: AIEGraphic) -> AIECodeGenerator? {
        for codeGenerator in codeGenerators {
            if codeGenerator.languages.contains(language) {
                return codeGenerator.generatorClass.init(for: language, root: root)
            }
        }
        return nil
    }

    // MARK: - Inspection

    public var titleForInspector: String? { return name }

    public var imageForInspector: NSImage? { return nil }

}
