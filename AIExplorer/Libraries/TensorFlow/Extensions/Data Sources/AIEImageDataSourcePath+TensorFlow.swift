//
//  AIEImageDataSourcePath+Tensorflow.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/19/23.
//

import Foundation

extension AIEImageDataSourcePath : AIETensorFlowCodeWriter {

    func createTensorFlowCodeWriter() -> AIECodeWriter {
        return AIETensorFlowImageDataSourcePathWriter(object: self)
    }
    
    internal class AIETensorFlowImageDataSourcePathWriter : AIETypedCodeWriter<AIEImageDataSourcePath> {
        
        override func generateInitializationCode(context: AIECodeGeneratorContext) throws -> Bool {
            return false
        }
        
    }
    
}
