//
//  AIETool.swift
//  AIExplorer
//
//  Created by AJ Raftis on 1/19/21.
//

import Draw

@objcMembers
open class AIETool: DrawTool {

    open override func graphic(with point: NSPoint, document: DrawDocument, page: DrawPage) -> DrawGraphic {
        var graphic : AIEGraphic

        if let graphicClass = currentAction.graphicClass as? AIEGraphic.Type {
            graphic = graphicClass.init(frame: NSRect(origin: point, size: .zero))
            
            let stroke = DrawStroke(graphic: graphic)
            stroke.width = 2.0;
            stroke.color = strokeColor(for: graphic)
            graphic.addAspect(stroke, with: DrawStroke.defaultPriority)

            let fill = DrawColorFill(graphic: graphic)
            fill.color = fillColor(for: graphic)
            graphic.addAspect(fill, with: DrawFill.defaultPriority)

            let text = DrawText(graphic: graphic, text: NSAttributedString(string: currentAction.title, attributes: AIEGraphic.defaultTextAttributes))
            graphic.addAspect(text)
        } else {
            graphic = AIEGraphic(frame: .zero)

            let stroke = DrawStroke(graphic: graphic)
            stroke.width = 2.0;
            stroke.color = strokeColor(for: graphic)
            graphic.addAspect(stroke, with: DrawStroke.defaultPriority)

            let fill = DrawColorFill(graphic: graphic)
            fill.color = NSColor.red
            graphic.addAspect(fill, with: DrawFill.defaultPriority)

            let text = DrawText(graphic: graphic, text: NSAttributedString(string: "Error: No class defined for action \(currentAction.title) (\(currentAction.tag))", attributes: AIEGraphic.defaultTextAttributes))
            graphic.addAspect(text)
        }

        return graphic
    }

    open func strokeColor(for graphic: AIEGraphic) -> NSColor {
        return NSColor.black
    }

    open func fillColor(for graphic: AIEGraphic) -> NSColor {
        return NSColor.white
    }

}
