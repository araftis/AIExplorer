//
//  AIEImageDataSource+TensorFlow.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/19/23.
//

import Foundation

extension AIEImageDataSourceCIFAR10 : AIETensorFlowCodeWriter {
    
    internal func generateInitializationCode(context: AIETensorFlowContext) throws -> Bool {
        try context.writeIndented("self.dataSource = dataSource")
        try progressToChild(context: context)
        return true
    }

    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        return false
    }
    
    internal var destinationObjects: [AIEGraphic] {
        return []
    }
    
    internal var variableName: String {
        return "dataSource"
    }
    
    internal var inputShape: [Int]? {
        return nil
    }
    
    internal var outputShape: [Int] {
        return []
    }
    
    internal var kind: AIEGraphic.Kind {
        return .support
    }
}
