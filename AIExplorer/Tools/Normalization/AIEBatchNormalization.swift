//
//  AIEBatchNormalization.swift
//  AIExplorer
//
//  Created by AJ Raftis on 1/19/21.
//

import Cocoa
import Draw

public extension AJRInspectorIdentifier {
    static var aiBatchNormalization = AJRInspectorIdentifier("aiBatchNormalization")
}


@objcMembers
open class AIEBatchNormalization: AIEGraphic {
    
    // MARK: - Properties
    open var momentum : Float = 0.99
    open var epsilon : Float = 0.001

    // MARK: - Creation

    public convenience init(momentum: Float, epsilon: Float) {
        self.init()

        self.momentum = momentum
        self.epsilon = epsilon
    }

    public required init() {
        super.init()
    }

    public required init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    // MARK: - AJRInspector

    open override var inspectorIdentifiers: [AJRInspectorIdentifier] {
        var identifiers = super.inspectorIdentifiers
        identifiers.append(.aiBatchNormalization)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        //coder.decodeFloat(forKey: "momentum", setter: <#T##((Float) -> Void)?##((Float) -> Void)?##(Float) -> Void#>) { (value) in
        //    self.momentum = value
        //}
        //coder.decodeFloat(forKey: "epsilon", setter: <#T##((Float) -> Void)?##((Float) -> Void)?##(Float) -> Void#>) { (value) in
        //    self.epsilon = value
        //}
        
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(momentum, forKey: "momentum")
        coder.encode(epsilon, forKey: "epsilon")
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "batch-normalization"
    }

}
