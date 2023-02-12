/*
 AIEBranch.swift
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

public extension AJRInspectorIdentifier {
    static var aieBranch = AJRInspectorIdentifier("aieBranch")
}

@objcMembers
open class AIEBranch: AIEGraphic {

    // MARK: - AJRInspector

    open override func inspectorIdentifiers(forInspectorContent inspectorContentIdentifier: AJRInspectorContentIdentifier?) -> [AJRInspectorIdentifier] {
        var supers = super.inspectorIdentifiers(forInspectorContent: inspectorContentIdentifier)
        if inspectorContentIdentifier == .graphic {
            supers.append(.aieBranch)
        }
        return supers
    }

    // MARK: - DrawGraphic

    open override func createTitleAspect() -> AIETitle {
        let title = super.createTitleAspect()
        title.simpleAppearance = true
        title.verticalAlignment = .middle
        title.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .large))
        return title
    }
    
    open override func updatePath() -> Void {
        path.removeAllPoints()
        path.moveTo(x: frame.midX, y: frame.maxY)
        path.lineTo(x: frame.minX, y: frame.midY)
        path.lineTo(x: frame.midX, y: frame.minY)
        path.lineTo(x: frame.maxX, y: frame.midY)
        path.close();

        noteBoundsAreDirty()
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        // Our conditions are stored as part of the exit links. Keeps things cleaner that way, but leaving this method, because we'll probably add some properties, eventually.
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "aieBranch"
    }

    // MARK: - AIEGraphic
    
    open override var kind : Kind {
        return .flowControl
    }
    
}
