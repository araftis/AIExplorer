/*
AIEDocumentTemplate.swift
AIExplorer

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

open class AIEDocumentTemplate: NSObject {

    open var url: URL
    open var name : String
    open var group : String?
    open var templateDescription : String
    open var image : NSImage? = nil

    public init(url: URL) {
        self.url = url
        self.name = "<No Name>"
        self.group = nil
        self.templateDescription = "<No Description>"

        let infoURL = url.appendingPathComponent("Info.plist")
        if let data = try? Data(contentsOf: infoURL) {
            if let properties = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String:Any] {
                self.name = (properties["name"] as? String) ?? "<No Name>"
                self.group = (properties["group"] as? String)
                self.templateDescription = (properties["description"] as? String) ?? "<No Description>"
                if let imageName = (properties["image"] as? String) {
                    let bundle = Bundle(for: AIEDocument.self)
                    if let url = bundle.urlForImageResource(imageName) {
                        self.image = NSImage(contentsOf: url)
                    }
                }
            }
        } else {
            AJRLog.error("Template has no Info.plist: \(url)")
        }

        super.init()
    }

    public override var description: String {
        return "<\(descriptionPrefix): url: \(url)>"
    }

    // MARK: - Managing Templates

    public static var _templates : [AIEDocumentTemplate]! = nil
    public static var templates : [AIEDocumentTemplate] {
        if _templates == nil {
            _templates = [AIEDocumentTemplate]()
            let fileFinder = AJRFileFinder(subpath: "AIE Templates", andExtension: "nnt")
            fileFinder.addAllBundles()

            for path in fileFinder.findFiles() {
                _templates.append(AIEDocumentTemplate(url: URL(fileURLWithPath: path)))
            }

            _templates!.sort { (left, right) -> Bool in
                return left.name < right.name
            }
        }

        return _templates
    }

    public static var groups : [String] {
        var groups = Set<String>()

        for template in templates {
            if let group = template.group {
                groups.insert(group)
            }
        }

        return groups.sorted()
    }

    public static func templates(for group: String) -> [AIEDocumentTemplate] {
        var templates = [AIEDocumentTemplate]()

        for template in self.templates {
            if template.group == group {
                templates.append(template)
            }
        }

        templates.sort { (left, right) -> Bool in
            return left.name < right.name
        }

        return templates
    }

}
