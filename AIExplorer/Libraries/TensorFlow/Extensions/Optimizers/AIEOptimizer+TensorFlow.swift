
import Foundation

internal protocol AIETensorFlowOptimizerCodeWriter : AIEMessageObject {
    
    func generateOptimizerCode(context: AIETensorFlowContext) throws -> Bool
    var variableName : String { get }

}
