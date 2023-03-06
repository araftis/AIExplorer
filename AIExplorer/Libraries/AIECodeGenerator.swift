/*
 AIECodeGenerator.swift
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
import AJRFoundation

// NOTE: This is all a little awkward to set up, but it makes usage at the call sites much easier.
public extension Dictionary where Key == String {
    
    subscript<T>(_ key: AIECodeGenerator.InfoKey<T>) -> T! {
        get {
            return self[key.key] as? T
        }
        set {
            self[key.key] = newValue as? Value
        }
    }
    
}

public extension AIECodeGenerator.InfoKey {
    static var codeName : AIECodeGenerator.InfoKey<String> {
        return AIECodeGenerator.InfoKey(key: "codeName")
    }
    static var url : AIECodeGenerator.InfoKey<URL?> {
        return AIECodeGenerator.InfoKey(key: "url")
    }
    static var role : AIECodeGenerator.InfoKey<AIECodeDefinition.Role> {
        return AIECodeGenerator.InfoKey(key: "role")
    }
    static var `extension` : AIECodeGenerator.InfoKey<String> {
        return AIECodeGenerator.InfoKey(key: "extension")
    }
    static var batchSize : AIECodeGenerator.InfoKey<Int> {
        return AIECodeGenerator.InfoKey(key: "batchSize")
    }
}

@objcMembers
open class AIECodeGenerator: NSObject {

    public class InfoKey<T> {
        public var key : String
        public init(key: String) {
            self.key = key
        }
    }
    
    open class var simpleDateFormatter : DateFormatter {
        let formatter = DateFormatter()

        formatter.dateStyle = .short
        formatter.timeStyle = .none

        return formatter
    }

    open class var yearDateFormatter : DateFormatter {
        let formatter = DateFormatter()

        formatter.dateFormat = "YYYY"

        return formatter
    }

    open weak var library : AIELibrary?
    open var info : [String:Any]
    open var language : AIELanguage
    open var roots : [AIEGraphic]

    // MARK: - Creation

    /**
     Creates a new code generated based on `language` rooted on `root`.
     */
    public required init(library: AIELibrary?, info: [String:Any], for language: AIELanguage, roots: [AIEGraphic]) {
        self.library = library
        self.info = info
        self.language = language
        self.roots = roots
        super.init()
    }

    // MARK: - Code Generation

    /**
     */
    open func fileNames(forBaseName baseName: String) -> [String] {
        return language.fileNames(forBaseName: baseName)
    }

    /**
     Generates the desired source code to `outputStream`.

     This method both accumulates errors into `messages` as well as throws. When overriding and implementing this method, you should use `messages` for errors, warning, and info (rarely) issues with the object model. For example, incorrectly initialized nodes in the neural network or nonsense connections between notes. On the other hand, you should throw an error when something critically bad happens, like failing to write to the output stream.
     */
    open func generate(to outputStream: OutputStream, accumulatingMessages messages: inout [AIEMessage]) throws -> Void {
    }

    // MARK: - Conveniences

    open func iterateNode(in node: AIEGraphic, using block: (_ node: AIEGraphic) throws -> Void) rethrows -> Void {
        var iterator = node.makeIterator()

        while let node = iterator.next() {
            try block(node as! AIEGraphic)
        }
    }

    open func iterateRoots(using block: (_ root: AIEGraphic) throws -> Void) rethrows -> Void {
        for root in roots {
            try block(root)
        }
    }

    open func iterateAllNodes(using block: (_ node: AIEGraphic) throws -> Void) rethrows -> Void {
        try iterateRoots { node in
            try iterateNode(in: node, using: block)
        }
    }
    
    /**
     Loops over all root nodes in the document and generates an error message if there's any root nodes that aren't I/O nodes.
     
     I/O nodes are subclasses of `AIEIO`, so the basic check is generate a error for anything that's an `AIEGraphic`, but that is not an `AIEIO` node.
     
     - parameter context: Our code generation context.
     */
    open func validateRootNodes(in context: AIECodeGeneratorContext) -> Void {
        iterateRoots { root in
            if !(root is AIEIO) {
                context.add(message: AIEMessage(type: .error, message: "Network roots must begin on an IO node.", on: root))
            }
        }
    }

}
