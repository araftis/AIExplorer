
import Cocoa
import Draw

public extension AJRInspectorIdentifier {
    static var aiActivation = AJRInspectorIdentifier("aiActivation")
}

@objcMembers
open class AIEActivation: AIEGraphic {
    
    // MARK: - Properties
    open var type : Int = 0
    
    // MARK: - Creation

    public convenience init(type: Int) {
        self.init()

        self.type = type
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
        identifiers.append(.aiActivation)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeInteger(forKey: "type") { (value) in
            self.type = value
        }
        
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(type, forKey: "type")
    }

    
    
    open class override var ajr_nameForXMLArchiving: String {
        return "activation-layer"
    }
    
    

}
