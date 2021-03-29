
import Cocoa

public enum AIEMathTag : Int {
    case arithmetic = 0
    case reduction = 1
    case matrixMultiplication = 2
    case fullyConnected = 3
    case gramMatrixGraph = 4
}

@objcMembers
open class AIEMathTool: AIETool {

    open override func fillColor(for graphic: AIEGraphic) -> NSColor {
        return NSColor(displayP3Red: 0.732, green: 0.270, blue: 0.899, alpha: 0.75)
    }

}
