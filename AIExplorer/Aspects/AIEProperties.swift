/*
 AIEProperties.swift
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

/**
 Draws the properties of the aspect inside the neural network node.
 */
open class AIEProperties: DrawText, AJREditObserver {

    // MARK: - DrawAspect

    public static var fontSize : CGFloat = 8.0

    open override class var shouldArchive : Bool { return false }

    open override class func defaultAspect(for graphic: DrawGraphic) -> DrawAspect? {
        if graphic is AIEGraphic {
            return AIEProperties(graphic: graphic, text: NSAttributedString(string: "", attributes: [:]))
        }
        return nil
    }

    public static var defaultTextAttributes : [NSAttributedString.Key:Any] = {
        var attributes = [NSAttributedString.Key:Any]()
        let style : NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle

        style.alignment = .natural;

        attributes[.font] = NSFont.systemFont(ofSize: fontSize)
        attributes[.paragraphStyle] = style
        attributes[.foregroundColor] = NSColor.black

        return attributes
    }()

    public static var defaultTitleAttributes : [NSAttributedString.Key:Any] = {
        var attributes = [NSAttributedString.Key:Any]()
        let style : NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle

        style.alignment = .natural;

        attributes[.font] = NSFont.boldSystemFont(ofSize: fontSize)
        attributes[.paragraphStyle] = style
        attributes[.foregroundColor] = NSColor.black

        return attributes
    }()

    internal var _displayString : NSAttributedString? = nil
    open var displayString : NSAttributedString {
        if _displayString == nil {
            let string = NSMutableAttributedString()

            var hasOutputted = false
            var indent = false
            if let graphic = graphic as? AIEGraphic {
                for property in graphic.displayedProperties {
                    let value = property.value
                    if property.isTitle || value != nil {
                        if !hasOutputted {
                            hasOutputted = true
                        } else {
                            string.append(NSAttributedString(string: "\n", attributes: AIEProperties.defaultTextAttributes))
                        }
                        if !property.isTitle && indent {
                            string.append(NSAttributedString(string: "   ", attributes: AIEProperties.defaultTextAttributes))
                        }
                        string.append(NSAttributedString(string: property.title, attributes: AIEProperties.defaultTitleAttributes))
                        if !property.isTitle {
                            string.append(NSAttributedString(string: ": ", attributes: AIEProperties.defaultTitleAttributes))
                            if let value = value {
                                string.append(NSAttributedString(string: value, attributes: AIEProperties.defaultTextAttributes))
                            }
                        } else {
                            indent = true
                        }
                    }
                }
            }
            _displayString = string
        }
        return _displayString!
    }

    open override func draw(_ path: AJRBezierPath, with priority: DrawAspectPriority) -> DrawGraphicCompletionBlock? {
        if let title = graphic?.firstAspect(ofType: AIETitle.self, with: AIETitle.defaultPriority) as? AIETitle {
            var bounds = path.bounds
            bounds.size.height -= title.height
            bounds.origin.y += title.height
            bounds = bounds.insetBy(dx: 2.0, dy: 2.0)

            displayString.draw(in: bounds)
            //NSColor.red.set()
            //AJRBezierPath(crossedRect: bounds).stroke()
        }
        return nil
    }

    override open func willAdd(to graphic: DrawGraphic) {
        graphic.addObserver(self)
    }

    override open func willRemove(from graphic: DrawGraphic) {
        graphic.removeObserver(self)
    }

    // MARK: - AJRXMLCoding

    open class override var ajr_nameForXMLArchiving: String {
        return "aieProperties"
    }

    // MARK: - AJREditObserver

    public func object(_ object: Any, didEditKey key: String, withChange change: [AnyHashable : Any]) {
        _displayString = nil;
        graphic?.setNeedsDisplay()
    }

}
