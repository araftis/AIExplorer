/*
 AIEDocumentTemplateChooser.swift
 AIExplorer

 Copyright © 2021, AJ Raftis and AIExplorer authors
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
import AJRInterface

// MARK: - UI Identifiers

extension NSUserInterfaceItemIdentifier {

    static var templateItem = NSUserInterfaceItemIdentifier("templateItem")
    static var headerItem = NSUserInterfaceItemIdentifier("headerItem")
    static var groupName = NSUserInterfaceItemIdentifier("groupName")

}

// MARK: - AIEDocumentTemplateChooserItemView

open class AIEDocumentTemplateChooserItemView : NSView {

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open var isSelected : Bool = false {
        didSet {
            self.needsDisplay = true
        }
    }

}

// MARK: - AIEDocumentTemplateChooserItem

open class AIEDocumentTemplateChooserItem : NSCollectionViewItem {

    open override func loadView() {
        if let nib = NSNib(nibNamed: "AIEDocumentTemplateChooserItem", bundle: Bundle(for: AIEDocumentTemplateChooser.self)) {
            nib.instantiate(withOwner: self, topLevelObjects: nil)
        }
    }

    open override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            (view as? AIEDocumentTemplateChooserItemView)?.isSelected = newValue
            super.isSelected = newValue
            if isSelected {
                self.imageView?.layer?.borderWidth = 3.0
                self.imageView?.layer?.borderColor = NSColor.selectedContentBackgroundColor.cgColor
                self.imageView?.layer?.cornerRadius = 2.0
            } else {
                self.imageView?.layer?.borderWidth = 0.0
            }
        }
    }

}

// MARK: - AIEDocumentTemplateChooserHeader

open class AIEDocumentTemplateChooserHeader : NSView {

    open var title : String = ""

    open override func draw(_ dirtyRect: NSRect) {
        var frame = self.bounds

        frame = frame.insetBy(dx: 20, dy: 0)

        NSColor.gray.set()
        AJRBezierPath.strokeLine(from: CGPoint(x: frame.minX, y: frame.minY), to: CGPoint(x: frame.maxX, y: frame.minY))

        let attributes : [NSAttributedString.Key:Any] = [.foregroundColor:NSColor.gray,
                                                         .font:NSFont.systemFont(ofSize: 14.0, weight: .bold),
                                                        ]
        frame.size.height -= 8.0
        title.draw(in: frame, with: attributes)
    }

}

// MARK: - AIEDocumentTemplateChooser

@objcMembers
open class AIEDocumentTemplateChooser: NSWindowController, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate, NSCollectionViewDelegate, NSCollectionViewDataSource {

    internal var rooted = Set<AIEDocumentTemplateChooser>()

    // MARK: - Properties

    @IBOutlet open var groupTable : NSTableView!
    @IBOutlet open var templateCollection : NSCollectionView!
    @IBOutlet open var descriptionText : NSTextView!
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

        if let indexPath = templateCollection.selectionIndexPaths.first {
            let group = AIEDocumentTemplate.groups[indexPath[0]]
            let template = AIEDocumentTemplate.templates(for: group)[indexPath[1]]
            if let newDocument = try? AIEDocument(fromTemplateURL: template.url) {
                NSDocumentController.shared.addDocument(newDocument)
                newDocument.makeWindowControllers()
                newDocument.showWindows()
            }
        }
    }

    @IBAction func cancel(_ sender: Any?) -> Void {
        window?.orderOut(self)
        rooted.remove(self)
    }

    // MARK: - NSWindowController

    open func windowWillClose(_ notification: Notification) {
        rooted.remove(self)
    }

    // MARK: - NSNibAwakening

    open override func awakeFromNib() {
        groupTable.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        templateCollection.register(AIEDocumentTemplateChooserHeader.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withIdentifier: .headerItem)
        templateCollection.register(AIEDocumentTemplateChooserItem.self, forItemWithIdentifier: .templateItem)
        let paths : Set<IndexPath> = [IndexPath(indexes: [0, 0])]
        templateCollection.selectionIndexPaths = paths
        self.collectionView(templateCollection, didSelectItemsAt: paths)
    }

    // MARK: - NSTableViewDataSource

    public func numberOfRows(in tableView: NSTableView) -> Int {
        return AIEDocumentTemplate.groups.count + 1
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let view = tableView.makeView(withIdentifier: .groupName, owner: self) as? NSTableCellView {
            let groups = AIEDocumentTemplate.groups
            if row == 0 {
                view.textField?.stringValue = "All"
            } else {
                view.textField?.stringValue = groups[row - 1]
            }
            return view
        }
        return nil
    }

    // MARK: - NSCollectionViewDataSource

    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return AIEDocumentTemplate.groups.count
    }

    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return AIEDocumentTemplate.templates(for: AIEDocumentTemplate.groups[section]).count
    }

    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .templateItem, for: indexPath)
        let group = AIEDocumentTemplate.groups[indexPath[0]]
        let template = AIEDocumentTemplate.templates(for: group)[indexPath[1]]

        item.textField?.stringValue = template.name
        if let image = template.image {
            item.imageView?.image = image
        }
        item.isSelected = collectionView.selectionIndexPaths.contains(indexPath)

        return item
    }

    public func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        print("kind: \(kind)")
        if let view = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .headerItem, for: indexPath) as? AIEDocumentTemplateChooserHeader {
            view.title = AIEDocumentTemplate.groups[indexPath[0]]
            return view
        }
        // Should never be reached, but we have to return something.
        return AJRXView()
    }

    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let indexPath = indexPaths.first {
            let group = AIEDocumentTemplate.groups[indexPath[0]]
            let template = AIEDocumentTemplate.templates(for: group)[indexPath[1]]
            let attributedString = NSMutableAttributedString()
            let plainAttributes : [NSAttributedString.Key:Any] =
                [
                    .font : NSFont.systemFont(ofSize: 14, weight: .regular)
                ]
            let boldAttributes : [NSAttributedString.Key:Any] =
                [
                    .font : NSFont.systemFont(ofSize: 14, weight: .bold)
                ]

            attributedString.append(NSAttributedString(string: template.name, attributes: boldAttributes))
            attributedString.append(NSAttributedString(string: "\n\n", attributes: plainAttributes))
            attributedString.append(NSAttributedString(string: template.templateDescription, attributes: plainAttributes))

            descriptionText.textStorage?.setAttributedString(attributedString)
        } else {
            descriptionText.string = ""
        }
    }

}

public extension NSObject {

    @IBAction func newDocumentFromTemplate(_ sender: Any?) -> Void {
        AIEDocumentTemplateChooser.chooser.run()
    }

}
