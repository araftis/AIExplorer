//
//  AIEImageDataSource+TensorFlow.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/19/23.
//

import Foundation

extension AIEImageDataSourceCIFAR10 : AIETensorFlowCodeWriter {
    
    func createTensorFlowCodeWriter() -> AIECodeWriter {
        return AIETensorFlowCIFAR10Writer(object: self)
    }
    
    internal class AIETensorFlowCIFAR10Writer : AIETypedCodeWriter<AIEImageDataSourceCIFAR10> {
        
        override func generateInitializationCode(context: AIECodeGeneratorContext) throws -> Bool {
            try context.write("self.dataSource = dataSource")
            try progressToChild(context: context)
            return true
        }
        
    }
    
}
