/*
AIEToolSet.swift
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

import Draw

public extension DrawToolSetId {
    static var neuralNet: DrawToolSetId {
        return DrawToolSetId("neuralNet")
    }
}

open class AIEToolSet: DrawToolSet {

    open override func menu(for event: DrawEvent) -> NSMenu? {
        if event.document.selection.any(passing: { return $0 is AIEGraphic }) != nil {
            let menu = NSMenu(title: "AI Explorer")
            var item : NSMenuItem

            item = menu.addItem(withTitle: "Dump AI Objects", action: #selector(dumpObjects(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = event.document.selection

            item = menu.addItem(withTitle: "Dump Source Code", action: #selector(dumpSourceCodeTest(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = event.document.selection

            return menu
        } else {
            let menu = NSMenu(title: "AI Explorer")
            var item : NSMenuItem

            item = menu.addItem(withTitle: "Dump AI Root Objects", action: #selector(dumpRootObjects(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = event.document

            return menu
        }
    }

    @IBAction open func dumpObjects(_ sender: Any?) -> Void {
        if let objects = (sender as? NSMenuItem)?.representedObject as? Set<DrawGraphic> {
            for graphic in objects {
                if let graphic = graphic as? AIEGraphic {
                    AJRLog.info("object: \(graphic): \(graphic.destinationObjects)")
                }
            }
        }
    }

    @IBAction open func dumpRootObjects(_ sender: Any?) -> Void {
        if let objects = ((sender as? NSMenuItem)?.representedObject as? AIEDocument)?.rootObjects {
            for graphic in objects {
                AJRLog.info("object: \(graphic): \(graphic.destinationObjects)")
            }
        }
    }

    @IBAction open func dumpSourceCodeTest(_ sender: Any?) -> Void {
        var root : AIEGraphic?

        if let objects = (sender as? NSMenuItem)?.representedObject as? Set<DrawGraphic> {
            root = objects.first(where: { (graphic) -> Bool in
                return graphic is AIEGraphic
            }) as? AIEGraphic
        }
        // Comment.
        if let root = root,
           let library = AIELibrary.library(for: .tensorflow),
           let language = library.language(for: "python"),
           let codeGenerator = library.codeGenerator(info: [:], for: language, root: root) {
            let outputStream = OutputStream.toMemory()
            outputStream.open()
            var messages = [AIEMessage]()
            do {
                try codeGenerator.generate(to: outputStream, accumulatingMessages: &messages)
            } catch let error as NSError {
                AJRLog.warning("Error generating code: \(error.localizedDescription)")
            }
            if let string = outputStream.dataAsString(using: .utf8) {
                AJRLog.info("Generated code:\n\(string)")
            }
        }
    }

}
