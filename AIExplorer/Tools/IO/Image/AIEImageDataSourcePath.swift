//
//  AIEImageDataSourcePath.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/11/23.
//

import Draw

public extension AIEDataSourceIndentifier.image {
    static var path = AIEOptimizerIndentifier("image.path")
}

@objcMembers
open class AIEImageDataSourcePath: AIEImageDataSource {

    open var path : String? = nil

    // MARK: - AJRXMLCoding

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        if let path { coder.encode(path, forKey: "path") }
    }

    open override func decode(with coder: AJRXMLCoder) {
        coder.decodeString(forKey: "path") { value in
            self.path = value
        }
    }

}
