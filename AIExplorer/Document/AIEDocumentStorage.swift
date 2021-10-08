/*
AIEDocumentStorage.swift
AIExplorer

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

import Draw

@objcMembers
open class AIEDocumentStorage: DrawDocumentStorage {

    // MARK: - Properties

    open var code = [AIECode]()
    open var aiLibrary : AIELibrary
    open var aiLanguage : AIELanguage
    open var sourceOutputURL : URL? = nil {
        willSet {
            if let current = sourceOutputURL {
                current.stopAccessingSecurityScopedResource()
            }
        }
        didSet {
            if let current = sourceOutputURL {
                if !current.startAccessingSecurityScopedResource() {
                    AJRLog.warning("Failed to get security access to: \(current)")
                }
            }
        }
    }

    // MARK: - Initialization

    public override init() {
        aiLibrary = AIELibrary.library(for: .tensorflow)!
        aiLanguage = aiLibrary.preferredLanguage
        super.init()
    }

    // MARK: - AJRXMLCoding

    open override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        coder.encode(aiLibrary.identifier.rawValue, forKey: "library")
        coder.encode(aiLanguage.identifier, forKey: "aiLanguage")
        if let url = sourceOutputURL {
            coder.encodeURLBookmark(url, forKey: "sourceOutputURL")
        }
    }

    open override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)
        coder.decodeString(forKey: "library") { (identifier) in
            if let library = AIELibrary.library(for: AIELibraryIndentifier(identifier)) {
                self.aiLibrary = library
            } else {
                self.aiLibrary = AIELibrary.library(for: .tensorflow)!
            }
        }
        coder.decodeString(forKey: "aiLanguage") { (identifier) in
            if let language = self.aiLibrary.language(for: identifier) {
                self.aiLanguage = language
            } else {
                self.aiLanguage = self.aiLibrary.preferredLanguage
            }
        }
        coder.decodeURLBookmark(forKey: "sourceOutputURL") { (url) in
            self.sourceOutputURL = url
        }
    }

}
