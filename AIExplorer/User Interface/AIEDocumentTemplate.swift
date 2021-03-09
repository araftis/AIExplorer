//
//  AIEDocumentTemplate.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/7/21.
//

import Cocoa
import AJRFoundation

open class AIEDocumentTemplate: NSObject {

    open var url: URL
    open var name : String
    open var group : String?
    open var templateDescription : String

    public init(url: URL) {
        self.url = url
        self.name = "<No Name>"
        self.group = nil
        self.templateDescription = "<No Description>"

        let infoURL = url.appendingPathComponent("Info.plist")
        if let data = try? Data(contentsOf: infoURL) {
            if let properties = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String:Any] {
                print("properties: \(properties)")
                self.name = (properties["name"] as? String) ?? "<No Name>"
                self.group = (properties["group"] as? String)
                self.templateDescription = (properties["description"] as? String) ?? "<No Description>"
            }
        } else {
            AJRLog.error("Template has no Info.plist: \(url)")
        }

        super.init()
    }

    public override var description: String {
        return "<\(descriptionPrefix): url: \(url)>"
    }

}
