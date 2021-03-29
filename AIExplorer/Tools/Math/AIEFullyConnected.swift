
import Cocoa
import Draw

public extension AJRInspectorIdentifier {
    static var aiFullyConnected = AJRInspectorIdentifier("aiFullyConnected")
}

@objcMembers
open class AIEFullyConnected: AIEGraphic {

    // MARK: - Properties
    open var dimension : Int = 0
    
    // MARK: - Creation

    public convenience init(dimension: Int) {
        self.init()

        self.dimension = dimension
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
        identifiers.append(.aiFullyConnected)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeInteger(forKey: "dimension") { (value) in
            self.dimension = value
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(dimension, forKey: "dimension")
    }

    
    open class override var ajr_nameForXMLArchiving: String {
        return "fully-connected-layer"
    }

}
