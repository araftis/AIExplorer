
import Cocoa
import Draw

public extension AJRInspectorIdentifier {
    static var aiLayerNormalization = AJRInspectorIdentifier("aiLayerNormalization")
}


@objcMembers
open class AIELayerNormalization: AIEGraphic {
    
    // MARK: - Properties
    open var epsilon : Float = 0.001

    // MARK: - Creation

    public convenience init(epsilon: Float) {
        self.init()

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
        identifiers.append(.aiLayerNormalization)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        //coder.decodeFloat(forKey: "epsilon", setter: <#T##((Float) -> Void)?##((Float) -> Void)?##(Float) -> Void#>) { (value) in
        //    self.epsilon = value
        //}
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(epsilon, forKey: "epsilon")
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "layer-normalization"
    }

}
