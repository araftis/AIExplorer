/*
 AIETool.swift
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
import AJRFoundation

@objcMembers
open class AIETool: DrawTool {

    open override func graphic(with point: NSPoint, document: DrawDocument, page: DrawPage) -> DrawGraphic {
        var graphic : AIEGraphic

        if let graphicClass = currentAction.graphicClass as? AIEGraphic.Type {
            graphic = graphicClass.init(frame: NSRect(origin: point, size: .zero))
            graphic.title = currentAction.title
            
            let stroke = DrawStroke(graphic: graphic)
            stroke.width = 1.0;
            stroke.color = strokeColor(for: graphic)
            graphic.addAspect(stroke, with: DrawStroke.defaultPriority)

            let fill = DrawColorFill(graphic: graphic)
            fill.color = fillColor(for: graphic)
            graphic.addAspect(fill, with: DrawFill.defaultPriority)

            // NOTE: Setting the title will create the appropriate title aspect.
            graphic.title = currentAction.title
        } else {
            graphic = AIEGraphic(frame: .zero)
            graphic.title = "ERROR"

            let stroke = DrawStroke(graphic: graphic)
            stroke.width = 1.0;
            stroke.color = strokeColor(for: graphic)
            graphic.addAspect(stroke, with: DrawStroke.defaultPriority)

            let fill = DrawColorFill(graphic: graphic)
            fill.color = NSColor.red
            graphic.addAspect(fill, with: DrawFill.defaultPriority)

            graphic.title = "Error: No class defined for action \(currentAction.title) (\(currentAction.tag))"
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
