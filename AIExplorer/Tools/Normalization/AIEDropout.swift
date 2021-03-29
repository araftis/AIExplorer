
import Draw

public extension AJRInspectorIdentifier {
    static var aiDropout = AJRInspectorIdentifier("aiDropout")
}


@objcMembers
open class AIEDropout: AIEGraphic {

    // MARK: - Properties
    open var rate : Float = 0.2

    // MARK: - Creation

    public convenience init(rate: Float) {
        self.init()

        self.rate = rate
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
        identifiers.append(.aiDropout)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        //coder.decodeFloat(forKey: "rate", setter: <#T##((Float) -> Void)?##((Float) -> Void)?##(Float) -> Void#>) { (value) in
        //    self.rate = value
        //}

        
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(rate, forKey: "rate")
    }
    
    open class override var ajr_nameForXMLArchiving: String {
        return "dropout-layer"
    }

}
