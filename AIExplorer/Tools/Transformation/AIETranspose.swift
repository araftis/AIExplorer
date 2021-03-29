
import Cocoa

@objcMembers
open class AIETranspose: AIEGraphic {

    open class override var ajr_nameForXMLArchiving: String {
        return "transpose-layer"
    }

}
