
import Draw

@objcMembers
open class AIEAdamOptimizer: AIEOptimizer {

    /// The coefficent for computing running averages of gradient.
    open var beta1: Float = 0.9
    /// The coefficent for computing running averages of square of gradient.
    open var beta2: Float = 0.999
    /// The epsilon value for improving numerical stability.
    open var epsilon: Float = 1e-07
    /// The initial timestep for the update.
    open var timeStep: Int = 1
    /// A Boolean value that indicates whether to use a variant of the algorithm.
    open var usesAMSGrad: Bool = false
    
    // MARK: - AJRXMLCoding
    
    open override func decode(with coder: AJRXMLCoder) {
        coder.decodeFloat(forKey: "beta1") { value in
            self.beta1 = value
        }
        coder.decodeFloat(forKey: "beta2") { value in
            self.beta2 = value
        }
        coder.decodeFloat(forKey: "epsilon") { value in
            self.epsilon = value
        }
        coder.decodeInteger(forKey: "timeStep") { value in
            self.timeStep = value
        }
        coder.decodeBool(forKey: "usesAMSGrad") { value in
            self.usesAMSGrad = value
        }
    }
    
    open override func encode(with coder: AJRXMLCoder) {
        if beta1 != 0.9 {
            coder.encode(beta1, forKey: "beta1")
        }
        if beta2 != 0.999 {
            coder.encode(beta2, forKey: "beta2")
        }
        if epsilon != 1e-07 {
            coder.encode(epsilon, forKey: "epsilon")
        }
        if timeStep != 1 {
            coder.encode(timeStep, forKey: "timeStep")
        }
        if usesAMSGrad {
            coder.encode(usesAMSGrad, forKey: "usesAMSGrad")
        }
    }
    
    open override var ajr_nameForXMLArchiving: String {
        return "aieAdamOptimizer"
    }
    
    // MARK: - AIEMessageObject
    
    open override var messagesTitle: String {
        return "Adam Optimizer"
    }
    
}
