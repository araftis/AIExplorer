
import Draw

@objc
open class AIESGDOptimizer: AIEOptimizer {
    
    /// A hyper-parameter that specifies the momentum factor.
    var momentumScale: Float = 0.0
    /// The constant for smoothing.
    var usesNesterovMomentum: Bool = false
    
    // MARK: - AJRXMLCoding
    
    open override func decode(with coder: AJRXMLCoder) {
        coder.decodeFloat(forKey: "momentumScale") { value in
            self.momentumScale = value
        }
        coder.decodeBool(forKey: "usesNesterovMomentum") { value in
            self.usesNesterovMomentum = value
        }
    }
    
    open override func encode(with coder: AJRXMLCoder) {
        if momentumScale != 0.9 {
            coder.encode(momentumScale, forKey: "momentumScale")
        }
        if usesNesterovMomentum {
            coder.encode(usesNesterovMomentum, forKey: "usesNesterovMomentum")
        }
    }
    
}
