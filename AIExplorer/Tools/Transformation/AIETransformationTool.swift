
import Cocoa

@objcMembers
open class AIETransformationTool: AIETool {

    open override func fillColor(for graphic: AIEGraphic) -> NSColor {
        return NSColor(displayP3Red: 0.258, green: 0.697, blue: 0.861, alpha: 0.75)
    }

}
