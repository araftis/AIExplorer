
import Cocoa
import Draw


public extension AJRInspectorIdentifier {
    static var aiLoss = AJRInspectorIdentifier("aiLoss")
}

@objcMembers
open class AIELoss: AIEGraphic {

    // MARK: - Properties
    open var loss_type : Int = 0
    open var optimization_type : Int = 0
    open var learning_rate : Double = 0.001

    // MARK: - Creation

    public convenience init(loss_type: Int) {
        self.init()

        self.loss_type = loss_type
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
        identifiers.append(.aiLoss)
        return identifiers
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)

        coder.decodeInteger(forKey: "loss_type") { (value) in
            self.loss_type = value
        }
        
        coder.decodeInteger(forKey: "optimization_type") { (value) in
            self.loss_type = value
        }
        
        //coder.decodeInteger(forKey: "learning_rate") { (value) in
        //    self.loss_type = value
        //}
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)

        coder.encode(loss_type, forKey: "loss_type")
        coder.encode(loss_type, forKey: "optimization_type")
        //coder.encode(loss_type, forKey: "learning_rate")

    }

    
    open class override var ajr_nameForXMLArchiving: String {
        return "loss-layer"
    }

}
