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
 Defines the superclass of libaries used by AI Explorer. A library represents a AI toolkit, such as Tesseract or Apple's own ML Compute.
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

}
