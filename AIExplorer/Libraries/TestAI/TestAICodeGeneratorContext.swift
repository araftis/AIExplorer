//
//  TestAICodeGeneratorContext.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/6/23.
//

import Draw

// Class, because we need this to be mutable without hassle.
internal class TestAICodeGeneratorContext : AIEPythonCodeGeneratorContext {

    override func codeWriter(for object: Any?) -> AIECodeWriter? {
        if let object = object as? AIETensorFlowCodeWriter {
            return object.createTensorFlowCodeWriter()
        }
        return super.codeWriter(for: object)
    }

}
