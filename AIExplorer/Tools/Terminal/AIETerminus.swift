
import Draw

public extension AJRInspectorIdentifier {
    static var aieTerminus = AJRInspectorIdentifier("aieTerminus")
}

open class AIETerminus: AIEGraphic {
    
    // MARK: - Properties
    
    open var loss : AIELoss = AIELoss()
    open var optimizer : AIEOptimizer = AIEAdamOptimizer()
    
    // MARK: - AJRInspector

    open override func inspectorIdentifiers(forInspectorContent inspectorContentIdentifier: AJRInspectorContentIdentifier?) -> [AJRInspectorIdentifier] {
        var supers = super.inspectorIdentifiers(forInspectorContent: inspectorContentIdentifier)
        if inspectorContentIdentifier == .graphic {
            supers.append(.aieTerminus)
        }
        return supers
    }
    
    open var inspectedAllOptimizers : [AIEOptimizer.OptimizerPlaceholder] {
        return AIEOptimizer.allOptimizers
    }

    open var inspectedOptimizer : AIEOptimizer.OptimizerPlaceholder? {
        get {
            return AIEOptimizer.optimizer(forClass: type(of: optimizer))
        }
        set {
            if let newValue {
                optimizer = newValue.optimizerClass.init()
            }
        }
    }

    open var inspectedAllLosses : [AIELoss.LossPlaceholder] {
        return AIELoss.allLosses
    }

    open var inspectedLoss : AIELoss.LossPlaceholder? {
        get {
            return AIELoss.loss(forClass: type(of: loss))
        }
        set {
            if let newValue {
                loss = newValue.lossClass.init()
                if type(of: loss).propertiesToObserve.contains("classCount") {
                    if let inputShape,
                       inputShape.count == 2 {
                        loss.setValue(inputShape[1], forKey: "classCount")
                    }
                }
            }
        }
    }

    // MARK: - AIEGraphic

    open override var displayedProperties : [Property] {
        weak var weakSelf = self
        return [Property("Loss", {
                        if let self = weakSelf {
                            return self.loss.localizedName
                        }
                        return nil
                    }),
                Property("Optimizer", {
                        if let self = weakSelf {
                            return self.optimizer.localizedName
                        }
                        return nil
                    }),
        ]
    }

    open override func updatePath() -> Void {
        let insetX = frame.size.width / 4.0
        let insetY = insetX
        path.removeAllPoints()
        path.moveTo(x: frame.minX, y: frame.minY + insetY)
        path.lineTo(x: frame.minX + insetX, y: frame.minY)
        path.lineTo(x: frame.maxX - insetX, y: frame.minY)
        path.lineTo(x: frame.maxX, y: frame.minY + insetY)
        path.lineTo(x: frame.maxX, y: frame.maxY - insetY)
        path.lineTo(x: frame.maxX - insetX, y: frame.maxY)
        path.lineTo(x: frame.minX + insetX, y: frame.maxY)
        path.lineTo(x: frame.minX, y: frame.maxY - insetY)
        path.close();

        noteBoundsAreDirty()
    }

    // MARK: - AJRXMLCoding

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)
        
        coder.decodeObject(forKey: "loss") { value in
            if let value = value as? AIELoss {
                self.loss = value
            }
        }
        coder.decodeObject(forKey: "optimizer") { value in
            if let value = value as? AIEOptimizer {
                self.optimizer = value
            }
        }
    }

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        
        coder.encode(loss, forKey: "loss")
        coder.encode(optimizer, forKey: "optimizer")
    }

    open class override var ajr_nameForXMLArchiving: String {
        return "aieTerminus"
    }

    // MARK: - AIEGraphic
    
    open override var kind : Kind {
        return .flowControl
    }
    
}
