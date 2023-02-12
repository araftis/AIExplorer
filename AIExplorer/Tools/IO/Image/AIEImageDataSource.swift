//
//  AIEImageDataSource.swift
//  AIExplorer
//
//  Created by AJ Raftis on 2/11/23.
//

import Cocoa

public extension AIEDataSourceIndentifier {

    // Just gives us place to scope our identifiers.
    struct image {
    }

}

@objcMembers
open class AIEImageDataSource: AIEDataSource, AJRXMLCoding {

    open var width : Int? = nil
    open var inspectedWidth : NSNumber? {
        get { return width == nil ? nil : NSNumber(value: width!) }
        set { if let newValue { width = newValue.intValue } else { width = nil } }
    }
    open var height : Int? = nil
    open var inspectedHeight : NSNumber? {
        get { return height == nil ? nil : NSNumber(value: height!) }
        set { if let newValue { height = newValue.intValue } else { height = nil } }
    }

    // MARK: - Creation

    required public override init() {
        super.init()
    }

    // MARK: - AJRXMLCoding

    open func encode(with coder: AJRXMLCoder) {
        if let width {
            coder.encode(width, forKey: "width")
        }
        if let height {
            coder.encode(height, forKey: "height")
        }
    }

    open func decode(with coder: AJRXMLCoder) {
        coder.decodeInteger(forKey: "width") { value in
            self.width = value
        }
        coder.decodeInteger(forKey: "height") { value in
            self.height = value
        }
    }

    open override var ajr_nameForXMLArchiving: String {
        return "aieImageDataSource"
    }

}
