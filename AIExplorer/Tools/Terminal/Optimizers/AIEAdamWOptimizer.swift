
import Draw

public extension AIEOptimizerIndentifier {
    static var adamW = AIEOptimizerIndentifier("adamW")
}

@objcMembers
open class AIEAdamWOptimizer: AIEAdamOptimizer {

    // MARK: - AJRXMLCoding
    
    open override var ajr_nameForXMLArchiving: String {
        return "aieAdamWOptimizer"
    }
    
   // MARK: - AIEMessageObject
    
    open override var messagesTitle: String {
        return "AdamW Optimizer"
    }
    
}
