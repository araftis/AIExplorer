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
 Defines the superclass of libaries used by AI Explorer. A library represents a AI toolkit, such as TensorFlow or Apple's own ML Compute.
 */
@objcMembers
open class AIELibrary: NSObject {

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

    // MARK: - Properties

    open var identifier : AIELibraryIndentifier
    open var name : String /// Name of the library
    open var url : URL? /// A url that points to the library's homepage.

    // MARK: - Creation

    public required init(id: AIELibraryIndentifier, name : String, url : URL?) {
        self.identifier = id
        self.name = name
        self.url = url
    }

    // MARK: - Source Code Generation

    open func codeGenerator(for language: String, root: AIEGraphic) -> AIECodeGenerator? {
        if let rawGenerators = AJRPlugInManager.shared.extensionPoint(forName: "aie-library")?.value(forProperty: "codeGenerators", onExtensionFor: type(of: self)) as? [[String:Any]] {
            for rawGenerator in rawGenerators {
                if let languages = rawGenerator["languages"] as? [[String:String]],
                   languages.contains(where: { (entry) -> Bool in
                    return entry["name"] == language
                   }),
                   let generatorClass = rawGenerator["class"] as? AIECodeGenerator.Type {
                    return generatorClass.init(for: language, root: root)
                }
            }
        }

        return nil
    }

}
