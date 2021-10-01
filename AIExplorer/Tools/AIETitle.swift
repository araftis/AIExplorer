//
//  AIETitle.swift
//  AIExplorer
//
//  Created by AJ Raftis on 9/30/21.
//

import Cocoa
import Draw

open class AIETitle: DrawText {

    override public func draw(_ path: AJRBezierPath, with priority: DrawAspectPriority) -> DrawGraphicCompletionBlock? {

        prepareTextInLayoutManager()
        
        let height = layoutManager.usedRect(for: textContainer!).height + 3.0
        
        let bounds = path.strokeBounds()

        var rectBounds = bounds
        drawWithSavedGraphicsState() {
            rectBounds.size.height = height
            if let fill = graphic?.firstAspect(ofType: DrawFill.self, with: DrawFill.defaultPriority) as? DrawColorFill {
                fill.color.set()
            } else {
                NSColor.red.set()
            }
            path.addClip()
            rectBounds.fill()
        }
        
        NSColor.black.withAlphaComponent(0.25).set()
        let linePath = AJRBezierPath()
        linePath.move(to: (bounds.minX, bounds.minY + height))
        linePath.line(to: (bounds.maxX, bounds.minY + height))
        linePath.lineWidth = 1.0
        linePath.stroke()

        super.draw(path, with: priority)

        return nil
    }
    
    // MARK: - AJRXMLCoding
    
    open class override var ajr_nameForXMLArchiving: String {
        return "title"
    }
    
}
