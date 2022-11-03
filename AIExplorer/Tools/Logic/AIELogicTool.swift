//
//  AIELogicTool.swift
//  AIExplorer
//
//  Created by AJ Raftis on 11/2/22.
//

import Draw

@objcMembers
open class AIELogicTool: AIETool {

    // MARK: - AIETool
    
    open override func graphic(with point: NSPoint, document: DrawDocument, page: DrawPage) -> DrawGraphic {
        let graphic = super.graphic(with: point, document: document, page: page) as! AIEGraphic

        if let titleAspect = graphic.firstAspect(of: AIETitle.self) {
            titleAspect.simpleAppearance = true
            titleAspect.title = "0"
            titleAspect.verticalAlignment = .middle
        }

        return graphic
    }
    
    open override func fillColor(for graphic: AIEGraphic) -> NSColor {
        return NSColor(calibratedWhite: 1.0, alpha: 0.75)
    }

}
