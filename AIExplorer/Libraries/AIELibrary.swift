/*
 AIELibrary.swift
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
import AJRFoundation
import Draw

public struct AIELibraryIdentifier : RawRepresentable, Equatable, Hashable {

    public typealias RawValue = String

    public var rawValue: String

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    static var unknown = AIELibraryIdentifier("unknown")
}

@objcMembers
public class AIEFileType : NSObject {
    
    public var `extension` : String
    public var uti : String
    
    public init(extension: String, uti: String) {
        self.extension = `extension`
        self.uti = uti
    }
    
    public convenience init?(properties : [String:String]) {
        if let ext = properties["extension"],
           let uti = properties["uti"] {
            self.init(extension: ext, uti: uti)
        } else {
            return nil
        }
    }
    
}

public struct AIELanguageIdentifier : RawRepresentable, Equatable, Hashable {

    public typealias RawValue = String

    public var rawValue: String

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    static var unknown = AIELanguageIdentifier("unknown")
    static var objC = AIELanguageIdentifier("obj-c")
    static var swift = AIELanguageIdentifier("swift")
    static var python = AIELanguageIdentifier("python")
    static var jupyterNoteBook = AIELanguageIdentifier("ipynb")
    static var java = AIELanguageIdentifier("java")
    static var go = AIELanguageIdentifier("go")
    static var rust = AIELanguageIdentifier("rust")
    static var javaScript = AIELanguageIdentifier("javaScript")

}

/**
 This is a small contained class to describe a programming language. This is a class rather than a struct for Obj-C interoperability.
 */
@objcMembers public class AIELanguage : NSObject, Comparable, AJRInspectorChoiceTitleProvider {

    public var name : String
    public var identifier : AIELanguageIdentifier
    public var fileTypes : [AIEFileType]
    public var fileExtensions : [String] {
        return fileTypes.map { $0.extension }
    }
    public var fileUTIs : [String] {
        return fileTypes.map { $0.uti }
    }

    public init(name: String, identifier: AIELanguageIdentifier, fileTypes: [AIEFileType]) {
        self.name = name
        self.identifier = identifier
        self.fileTypes = fileTypes
        super.init()
    }

    public convenience init?(properties: [String:Any]) {
        if let name = properties["name"] as? String,
           let identifier = properties["identifier"] as? String,
           let rawFileTypes = properties["extensions"] as? [[String:String]] {
            var fileTypes = [AIEFileType]()
            for rawFileType in rawFileTypes {
                if let fileType = AIEFileType(properties: rawFileType) {
                    fileTypes.append(fileType)
                } else {
                    AJRLog.error("Failed to create a file type from the properties: \(rawFileType)")
                }
            }
            self.init(name: name, identifier: AIELanguageIdentifier(identifier), fileTypes: fileTypes)
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

    public override var hash: Int { return identifier.rawValue.hash }

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

    // MARK: - Utilities

    open func fileNames(forBaseName baseName: String) -> [String] {
        var names = [String]()

        for fileExtension in fileExtensions {
            names.append("\(baseName).\(fileExtension)")
        }

        return names
    }

}

/**
 Defines the superclass of libaries used by AI Explorer. A library represents a AI toolkit, such as TensorFlow or Apple's own ML Compute.
 */
@objcMembers
open class AIELibrary: NSObject, AJRInspectorChoiceTitleProvider {

    // MARK: - Factory

    internal static var librariesById = [AIELibraryIdentifier:AIELibrary]()

    @objc(registerLibrary:properties:)
    open class func register(library: AIELibrary.Type, properties: [String:Any]) -> Void {
        if let libraryClass = properties["class"] as? AIELibrary.Type,
           let rawId = properties["id"] as? String,
           let name = properties["name"] as? String {
            let identifier = AIELibraryIdentifier(rawValue: rawId)
            let url = properties["url"] as? URL
            let library = libraryClass.init(id: identifier, name: name, url: url)
            librariesById[identifier] = library
            AJRLog.in(domain: .drawPlugIn, level: .debug, message: "Library: \(libraryClass)")
        }
    }

    open class func library(for id: AIELibraryIdentifier) -> AIELibrary? {
        return librariesById[id]
    }

    /** All the libraries sorted by their name. */
    open class var orderedLibraries : [AIELibrary] {
        return librariesById.values.sorted { (lhs, rhs) -> Bool in
            return lhs.name < rhs.name
        }
    }

    // MARK: - Properties

    open var identifier : AIELibraryIdentifier
    open var name : String /// Name of the library
    open var url : URL? /// A url that points to the library's homepage.

    // The preferred language of the library. Not very smart right now.
    open var preferredLanguage : AIELanguage {
        let language = codeGenerators.first?.languages.first
        assert(language != nil, "AIELibraries must support at least one code generation language.")
        return language!
    }

    // MARK: - Creation

    public required init(id: AIELibraryIdentifier, name : String, url : URL?) {
        self.identifier = id
        self.name = name
        self.url = url
    }

    // MARK: - Source Code Generation

    open func language(for identifier: AIELanguageIdentifier) -> AIELanguage? {
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

    open func supportsLanguageForCodeGeneration(_ language: AIELanguage) -> Bool {
        return supportedLanguagesForCodeGeneration.contains(language)
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
                       let rawLanguages = rawGenerator["languages"] as? [[String:Any]] {
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
    open func codeGenerator(info: [String:Any], for language: AIELanguage, roots: [AIEGraphic]) -> AIECodeGenerator? {
        for codeGenerator in codeGenerators {
            if codeGenerator.languages.contains(language) {
                return codeGenerator.generatorClass.init(library: self, info: info, for: language, roots: roots)
            }
        }
        return nil
    }

    // MARK: - Inspection

    public var titleForInspector: String? { return name }

    public var imageForInspector: NSImage? { return nil }

}
