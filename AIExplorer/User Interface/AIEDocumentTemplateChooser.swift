//
//  AIEDocumentTemplateChooser.swift
//  AIExplorer
//
//  Created by AJ Raftis on 3/7/21.
//

import Cocoa
import AJRFoundation

@objcMembers
open class AIEDocumentTemplateChooser: NSWindowController, NSWindowDelegate {

    internal var rooted = Set<AIEDocumentTemplateChooser>()

    // MARK: - Properties

    @IBOutlet open var okButton : NSButton!
    @IBOutlet open var cancelButton : NSButton!

    open class var chooser : AIEDocumentTemplateChooser {
        let chooser = AIEDocumentTemplateChooser()
        chooser.loadWindow()
        return chooser
    }

    open override func windowDidLoad() {
        super.windowDidLoad()
    }

    // MARK: - NSWindowController

    open override func loadWindow() {
        let bundle = Bundle(for: AIEDocumentTemplateChooser.self)
        if let nib = NSNib(nibNamed: "AIEDocumentTemplateChooser", bundle: bundle) {
            nib.instantiate(withOwner: self, topLevelObjects: nil)
        }
    }

    // MARK: - Actions

    open func run() -> Void {
        window?.makeKeyAndOrderFront(self)
        window?.center()
        rooted.insert(self)
    }

    @IBAction func ok(_ sender: Any?) -> Void {
        window?.orderOut(self)
        rooted.remove(self)
    }

    @IBAction func cancel(_ sender: Any?) -> Void {
        window?.orderOut(self)
        rooted.remove(self)
    }

    open func windowWillClose(_ notification: Notification) {
        rooted.remove(self)
    }

    // MARK: - Managing Templates

    public static var _templates : [AIEDocumentTemplate]! = nil
    public static var templates : [AIEDocumentTemplate] {
        if _templates == nil {
            _templates = [AIEDocumentTemplate]()
            let fileFinder = AJRFileFinder(subpath: "AIE Templates", andExtension: "nnt")
            fileFinder.addAllBundles()

            for path in fileFinder.findFiles() {
                _templates.append(AIEDocumentTemplate(url: URL(fileURLWithPath: path)))
            }
        }

        return _templates
    }

    public static var templateGroups : [String] {
        var groups = Set<String>()

        for template in templates {
            if let group = template.group {
                groups.insert(group)
            }
        }

        return groups.sorted()
    }

}

public extension NSObject {

    @IBAction func newDocumentFromTemplate(_ sender: Any?) -> Void {
        print("templates: \(AIEDocumentTemplateChooser.templates)")
        print("groups: \(AIEDocumentTemplateChooser.templateGroups)")
        AIEDocumentTemplateChooser.chooser.run()
    }

}
