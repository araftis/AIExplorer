//
//  AIEShapeTests.swift
//  AIExplorerTests
//
//  Created by AJ Raftis on 2/19/23.
//

import XCTest
import AIExplorer

internal class AIEXMLCodingTestObject : NSObject, AJRXMLCoding {
    
    
    public var shape : AIEShape = .zero
    
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
        let shape = AIEShape.zero
        XCTAssert(shape == AIEShape.zero)
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
