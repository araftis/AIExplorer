
import Cocoa
import Draw

public extension AJRInspectorIdentifier {
    static var aiReduction = AJRInspectorIdentifier("aiReduction")
}

@objcMembers
open class AIEReduction: AIEGraphic {
 
    // MARK: - Properties
    open var width : Int = 0
    open var height : Int = 0
    open var step : Int = 0

    // MARK: - Creation

    public convenience init(width: Int, height: Int, depth: Int, step : Int) {
        self.init()

        self.width = width
        self.height = height
        self.step = step
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
        identifiers.append(.aiReduction)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeInteger(forKey: "width") { (value) in
            self.width = value
        }
        coder.decodeInteger(forKey: "height") { (value) in
            self.height = value
        }
        coder.decodeInteger(forKey: "step") { (value) in
            self.step = value
        }
        
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(width, forKey: "width")
        coder.encode(height, forKey: "height")
        coder.encode(step, forKey: "step")
    }
    open class override var ajr_nameForXMLArchiving: String {
        return "reduction-layer"
    }

}
