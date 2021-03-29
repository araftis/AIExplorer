
import Draw

public extension AJRInspectorIdentifier {
    static var aiImageIO = AJRInspectorIdentifier("aiImageIO")
}

@objcMembers
open class AIEImageIO: AIEGraphic {

    // MARK: - Properties
    open var width : Int = 0
    open var height : Int = 0
    open var depth : Int = 0

    // MARK: - Creation

    public convenience init(width: Int, height: Int, depth: Int) {
        self.init()

        self.width = width
        self.height = height
        self.depth = depth
    }

    public required init() {
        super.init()
    }

    public required init(frame: NSRect) {
        super.init(frame: frame)
    }

    // MARK: - AJREditableObject

    open override class func populateProperties(toObserve propertiesSet: NSMutableSet!) {
        propertiesSet.add("width")
        propertiesSet.add("height")
        propertiesSet.add("depth")
        super.populateProperties(toObserve: propertiesSet)
    }

    // MARK: - AJRInspector

    open override var inspectorIdentifiers: [AJRInspectorIdentifier] {
        var identifiers = super.inspectorIdentifiers
        identifiers.append(.aiImageIO)
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
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(width, forKey: "width")
        coder.encode(height, forKey: "height")
        coder.encode(depth, forKey: "depth")
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "image-io"
    }

}
