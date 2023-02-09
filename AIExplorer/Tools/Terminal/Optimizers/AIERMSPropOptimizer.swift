
import Draw

@objcMembers
open class AIERMSPropOptimizer: AIEOptimizer {

    /// A hyper-parameter that specifies the momentum factor.
    var momentumScale: Float = 0.0
    /// The constant for smoothing.
    var alpha: Float = 0.99
    /// The epsilon value you use to improve numerical stability.
    var epsilon: Float = 1e-8
    /// A Boolean that indicates whether you compute the centered RMSProp.
    var isCentered: Bool = false
    
    // MARK: - AJRXMLCoding
    
    open override func decode(with coder: AJRXMLCoder) {
        coder.decodeFloat(forKey: "momentumScale") { value in
            self.momentumScale = value
        }
        coder.decodeFloat(forKey: "alpha") { value in
            self.alpha = value
        }
        coder.decodeFloat(forKey: "epsilon") { value in
            self.epsilon = value
        }
        coder.decodeBool(forKey: "isCentered") { value in
            self.isCentered = value
        }
    }
    
    open override func encode(with coder: AJRXMLCoder) {
        if momentumScale != 0.9 {
            coder.encode(momentumScale, forKey: "momentumScale")
        }
        if alpha != 0.999 {
            coder.encode(alpha, forKey: "alpha")
        }
        if epsilon != 1e-07 {
            coder.encode(epsilon, forKey: "epsilon")
        }
        if isCentered {
            coder.encode(isCentered, forKey: "isCentered")
        }
    }
    
}
