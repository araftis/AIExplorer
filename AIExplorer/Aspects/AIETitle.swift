/*
AIETitle.swift
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
import Draw

/**
 Draws the title in a neural network node. This pretty specialized, and not all that useful for general purpose.
 */
open class AIETitle: DrawText {

    open var title : String {
        get {
            return attributedString.string
        }
        set {
            attributedString = NSAttributedString(string: newValue, attributes: Self.defaultTextAttributes)
        }
    }

    // MARK: - Default Values

    open class var defaultTextAttributes : [NSAttributedString.Key:Any] {
        var attributes = [NSAttributedString.Key:Any]()
        let style : NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle

        style.alignment = .center;

        attributes[.font] = NSFont.boldSystemFont(ofSize: 9.0)
        attributes[.paragraphStyle] = style
        attributes[.foregroundColor] = NSColor.black

        return attributes
    }

    // MARK: - DrawAspect

    open override class var shouldArchive : Bool { return false }

    open override class func defaultAspect(for graphic: DrawGraphic) -> DrawAspect {
        return AIETitle(graphic: graphic, text: NSAttributedString(string: "Untitled", attributes: Self.defaultTextAttributes))
    }

    internal var _height : CGFloat? = nil
    open var height : CGFloat {
        if _height == nil {
            prepareTextInLayoutManager()
            _height = layoutManager.usedRect(for: textContainer!).height + 3.0
        }
        return _height!
    }

    override public func draw(_ path: AJRBezierPath, with priority: DrawAspectPriority) -> DrawGraphicCompletionBlock? {

        prepareTextInLayoutManager()

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

    open override func graphicDidChangeShape(_ graphic: DrawGraphic) {
        _height = nil
    }
    
    // MARK: - AJRXMLCoding
    
    open class override var ajr_nameForXMLArchiving: String {
        return "aieTitle"
    }
    
}