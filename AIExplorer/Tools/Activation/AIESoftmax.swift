
import Cocoa
import Draw


public extension AJRInspectorIdentifier {
    static var aiSoftmax = AJRInspectorIdentifier("aiSoftmax")
}


@objcMembers
open class AIESoftmax: AIEGraphic {
    // MARK: - Properties
    open var axis : Int = -1
    
    // MARK: - Creation

    public convenience init(axis: Int) {
        self.init()

        self.axis = axis
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
        identifiers.append(.aiSoftmax)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeInteger(forKey: "axis") { (value) in
            self.axis = value
        }
        
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(axis, forKey: "axis")
    }

    
    open class override var ajr_nameForXMLArchiving: String {
        return "softmax-layer"
    }

}
