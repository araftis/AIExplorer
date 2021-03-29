
import Draw

@objcMembers
open class AIEDocumentStorage: DrawDocumentStorage {

    // MARK: - Properties

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
