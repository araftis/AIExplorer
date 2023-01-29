
import Foundation

extension AIEConvolution : AIETensorFlowCodeWriter {

    internal func generateCode(context: AIETensorFlowContext) throws -> Bool {
        try appendShapes(context: context)
        try context.output.indent(2).write("\(variableName) = layers.Conv2D(\(outputFeatureChannels)")
        if size.width == size.height {
            try context.output.write(", \(size.height)")
        } else {
            try context.output.write(", (\(size.height), \(size.width))")
        }
        if stride.width < 0 || stride.height < 0 {
            context.add(message: AIEMessage(type: .error, message: "The width and height of stride must both be positive integers.", on: self))
        } else if (stride.width == 0 && stride.height != 0) || (stride.width != 0 && stride.height == 0) {
            context.add(message: AIEMessage(type: .error, message: "If the stride width or height is >= 1, then both the width and height must be >= 1.", on: self))
        } else if stride.width > 1 && stride.height > 1 {
            // We don't need to output if stride = 1, since that's the default.
            try context.output.write(", strides=(\(stride.width), \(stride.height))")
        }
        if dilation.width < 0 || dilation.height < 0 {
            context.add(message: AIEMessage(type: .error, message: "The width and height of dilation must both be positive integers.", on: self))
        } else if (dilation.width == 0 && dilation.height != 0) || (dilation.width != 0 && dilation.height == 0) {
            context.add(message: AIEMessage(type: .error, message: "If the dilation width or height is >= 1, then both the width and height must be >= 1.", on: self))
        } else if dilation.width > 1 && dilation.height > 1 {
            try context.output.write(", dilation_rate=(\(dilation.width), \(dilation.height))")
        }
        if paddingPolicy == .same {
            try context.output.write(", padding=\"same\"")
        } else if paddingPolicy == .usePaddingSize {
            // Not sure how to handle this with TensorFlow just yet.
            context.add(message: AIEMessage(type: .warning, message: "We don't handle the padding policy \"Use Padding Size\" in TensorFlow yet.", on: self))
        }
        try context.output.write(")")
        try appendParent(context: context)
        try context.output.write("\n")
        try progressToChild(context: context)
        
        return true
    }
}

