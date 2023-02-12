/*
 AIEDataSource.swift
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

import Draw

public struct AIEDataSourceIndentifier : RawRepresentable, Equatable, Hashable {

    public typealias RawValue = String

    public var rawValue: String

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

}


@objcMembers
open class AIEDataSource: NSObject {

    @objcMembers
    public class Placeholder : NSObject, AJRInspectorContentProvider {

        var dataSourceClass: AIEDataSource.Type
        var name: String
        var id: AIEDataSourceIndentifier
        var localizedName : String {
            // TODO: If we ever get around to localizing, localize this.
            return name
        }

        public init(dataSourceClass: AIEDataSource.Type, name: String, id: AIEDataSourceIndentifier) {
            self.dataSourceClass = dataSourceClass
            self.name = name
            self.id = id
        }

        public var inspectorFilename: String? {
            return AJRStringFromClassSansModule(dataSourceClass)
        }

        public var inspectorBundle: Bundle? {
            return Bundle(for: dataSourceClass)
        }

    }

    // MARK: - Factory

    internal static var dataSources = [String:[AIEDataSourceIndentifier:Placeholder]]()

    internal class var key : String {
        return NSStringFromClass(Self.self)
    }

    @objc(registerDataSource:properties:)
    open class func register(dataSource: AIEDataSource.Type, properties: [String:Any]) -> Void {
        if let dataSourceClass = properties["class"] as? AIEDataSource.Type,
           let rawId = properties["id"] as? String,
           let name = properties["name"] as? String {
            let identifier = AIEDataSourceIndentifier(rawValue: rawId)
            let placeholder = Placeholder(dataSourceClass: dataSourceClass, name: name, id: identifier)
            var sources = dataSources[key]
            if sources == nil {
                sources = [AIEDataSourceIndentifier:Placeholder]()
            }
            sources![identifier] = placeholder
            dataSources[key] = sources!

            AJRLog.in(domain: DrawPlugInLogDomain, level: .debug, message: "Data Source: \(name) (\(dataSourceClass))")
        } else {
            AJRLog.in(domain: DrawPlugInLogDomain, level: .error, message: "Received nonsense properties: \(properties)")
        }
    }

    open class var allDataSources : [Placeholder] {
        if let dataSourcesById = dataSources[key] {
            return dataSourcesById.values.sorted { left, right in
                return left.name < right.name
            }
        }
        return []
    }

    open class func dataSource(forId id: AIEDataSourceIndentifier) -> Placeholder? {
        return dataSources[key]?[id]
    }

    open class func dataSource(forClass class: AIEDataSource.Type) -> Placeholder? {
        if let dataSourcesById = dataSources[key] {
            for (_, value) in dataSourcesById {
                if value.dataSourceClass == `class` {
                    return value
                }
            }
        }
        return nil
    }

    open class func dataSourceId(forClass class: AIEDataSource.Type) -> AIEDataSourceIndentifier? {
        if let placeholder = dataSource(forClass: `class`) {
            return placeholder.id
        }
        return nil
    }

}
