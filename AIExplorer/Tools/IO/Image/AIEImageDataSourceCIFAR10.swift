//
//  AIEImageDataSourceCIFAR10.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/11/23.
//

import Draw

public extension AIEDataSourceIndentifier.image {
    static var cifar10 = AIEOptimizerIndentifier("image.CIFAR10")
}

@objcMembers
open class AIEImageDataSourceCIFAR10: AIEImageDataSource {

    open override var width: Int? {
        get { return super.width }
        set { super.width = 32 }
    }
    open override var height: Int? {
        get { return super.height }
        set { super.height = 32 }
    }

}
