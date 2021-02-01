//
//  AIECodeGenerator.swift
//  AIExplorer
//
//  Created by AJ Raftis on 1/31/21.
//

import Cocoa
import AJRFoundation

@objcMembers
open class AIECodeGenerator: NSObject {

    open var language : String
    open var root : AIEGraphic

    // MARK: - Creation

    /**
     Creates a new code generated based on `language` rooted on `root`.
     */
    public required init(for language: String, root: AIEGraphic) {
        self.language = language
        self.root = root
        super.init()
    }

    // MARK: - Code Generation

    /**
     Generates the desired source code to `outputStream`. If an error occurs during generation, this method throws an error.
     */
    public func generate(to outputStream: OutputStream) throws -> Void {
    }

}
