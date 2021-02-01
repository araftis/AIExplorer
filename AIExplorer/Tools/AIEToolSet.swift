//
//  AIEToolSet.swift
//  NN Explorer
//
//  Created by AJ Raftis on 12/31/20.
//

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
            return nil
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
           let codeGenerator = library.codeGenerator(for: "python", root: root) {
            let outputStream = OutputStream.toMemory()
            outputStream.open()
            do {
                try codeGenerator.generate(to: outputStream)
            } catch let error as NSError {
                AJRLog.warning("Error generating code: \(error.localizedDescription)")
            }
            if let string = outputStream.dataAsString(using: .utf8) {
                AJRLog.info("Generated code:\n\(string)")
            }
        }
    }

}
