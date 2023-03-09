/*
 AIEShapeTests.swift
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

import XCTest
import AIExplorer

internal class AIEXMLCodingTestObject : NSObject, AJRXMLCoding {
    
    
    public var shape : AIEShape = .zeroSize
    
    required override init() {
    }
    
    public init(shape: AIEShape) {
        self.shape = shape
    }
    
    func encode(with coder: AJRXMLCoder) {
        coder.encodeComment("Testing the encoding of AIEShape")
        coder.encode(shape, forKey: "shape")
    }
    
    func decode(with coder: AJRXMLCoder) {
        coder.decodeShape(forKey: "shape") { value in
            self.shape = value
        }
    }
    
}

final class AIEShapeTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testBasics() throws {
        let shape = AIEShape.zeroImage
        XCTAssert(shape == AIEShape.zeroImage)
        XCTAssert("\(shape)" == "{height=0; width=0; depth=0}")
    }
    
    func testStringConversion() {
        var shape = AIEShape(width: 1, height: 2, depth: 3)
        var newShape = AIEShapeFromString(AIEStringFromShape(shape))
        
        XCTAssert(shape == newShape)

        shape = AIEShape(labels: [.width, .height], values: [1, 2])
        newShape = AIEShapeFromString(AIEStringFromShape(shape))
        
        XCTAssert(shape == newShape)
    }

    func testXMLCoding() throws {
        let object = AIEXMLCodingTestObject(shape: AIEShape(width: 1, height: 2, depth: 3))
        let outputStream = OutputStream.toMemory()
        let coder = AJRXMLArchiver(outputStream: outputStream)

        // Finally test coding
        outputStream.open()
        coder.encodeRootObject(object, forKey: "object")
        outputStream.close()
        
        let string = outputStream.dataAsString(using: .utf8)
        XCTAssert(string != nil)
        print("result:\n\n\(string!)\n\n");
        
        let decoded = try? AJRXMLUnarchiver.unarchivedObject(with: string!.data(using: .utf8)!, topLevelClass: AIEXMLCodingTestObject.self)
        
        XCTAssert(decoded != nil)
        XCTAssert(decoded is AIEXMLCodingTestObject)
        if let decoded = decoded as? AIEXMLCodingTestObject {
            XCTAssert(decoded.shape.width == 1)
            XCTAssert(decoded.shape.height == 2)
            XCTAssert(decoded.shape.depth == 3)
        }
    }

}
