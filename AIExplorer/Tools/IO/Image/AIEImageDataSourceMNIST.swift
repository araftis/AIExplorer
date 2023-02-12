//
//  AIEImageDataSourceMNIST.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/11/23.
//

import Draw

public extension AIEDataSourceIndentifier.image {
    static var mnist = AIEOptimizerIndentifier("image.MNIST")
}

@objcMembers
open class AIEImageDataSourceMNIST: AIEImageDataSource {

    open override var width: Int? {
        get { return super.width }
        set { super.width = 28 }
    }
    open override var height: Int? {
        get { return super.height }
        set { super.height = 28 }
    }

}
