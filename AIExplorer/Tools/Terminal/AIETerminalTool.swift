
import Draw

open class AIETerminalTool: AIETool {

    open override func fillColor(for graphic: AIEGraphic) -> NSColor {
        return NSColor(displayP3Red: 255.0 / 255.0, green: 116.0 / 255.0, blue: 116.0 / 255.0, alpha: 0.5)
    }

}
