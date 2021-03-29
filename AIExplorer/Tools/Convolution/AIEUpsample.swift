
import Draw

public extension AJRInspectorIdentifier {
    static var aiUpsample = AJRInspectorIdentifier("aiUpsample")
}

@objcMembers
open class AIEUpsample: AIEGraphic {

    // MARK: - Properties
    open var width : Int = 0
    open var height : Int = 0
    open var depth : Int = 0
    open var step : Int = 0

    // MARK: - Creation

    public convenience init(width: Int, height: Int, depth: Int, step : Int) {
        self.init()

        self.width = width
        self.height = height
        self.depth = depth
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
        identifiers.append(.aiUpsample)
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
        coder.decodeInteger(forKey: "depth") { (value) in
            self.depth = value
        }
        coder.decodeInteger(forKey: "step") { (value) in
            self.step = value
        }
        
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(width, forKey: "width")
        coder.encode(height, forKey: "height")
        coder.encode(depth, forKey: "depth")
        coder.encode(depth, forKey: "step")
    }

    
    open class override var ajr_nameForXMLArchiving: String {
        return "upsample-layer"
    }

}
