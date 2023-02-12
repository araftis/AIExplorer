/*
 AIEImageDataSource.swift
 AIExplorer

 Copyright © 2023, AJ Raftis and AIExplorer authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this 
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the documentation 
   and/or other materials provided with the distribution.
 * Neither the name of AIExplorer nor the names of its contributors may be 
   used to endorse or promote products derived from this software without 
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
