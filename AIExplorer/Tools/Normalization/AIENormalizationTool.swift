
import Cocoa

public enum AIENormalizationTag : Int {
    case layerNormalization = 0
    case batchNormalization = 1
    case groupNormalization = 2
    case instanceNormalization = 3
    case dropout = 4
}

@objcMembers
open class AIENormalizationTool: AIETool {

    open override func fillColor(for graphic: AIEGraphic) -> NSColor {
        return NSColor(displayP3Red: 0.938, green: 0.673, blue: 0.136, alpha: 0.75)
    }

}
