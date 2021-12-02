//
//  AIEMessagesInspector.swift
//  AIExplorer
//
//  Created by AJ Raftis on 11/1/21.
//

import Draw
import Foundation

public extension NSUserInterfaceItemIdentifier {
    static var messageView = NSUserInterfaceItemIdentifier("messageView")
}

open class AIEMessagesInspector: DrawStructureInspector, NSOutlineViewDataSource, NSOutlineViewDelegate {

    @IBOutlet open var tabView : NSTabView!
    @IBOutlet open var messagesLabel : NSTextField!
    @IBOutlet open var messagesTable : NSOutlineView!
    
    var orderedMessages = [AIEMessageObject]()
    var groupedMessages = [AnyHashable:[AIEMessage]]()
    
    deinit {
        messagesToken?.invalidate()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupDocument()
    }
    
    open override func documentDidLoad(_ document: DrawDocument) {
        super.documentDidLoad(document)
        setupDocument()
    }
    
    open override func viewDidAppear() {
        super.viewDidAppear()
        setupDocument()
    }
    
    internal var messagesToken : AJRInvalidation?
    open func setupDocument() -> Void {
        if let document = document as? AIEDocument {
            weak var weakSelf = self
            messagesToken = document.addObserver(self, forKeyPath: "messages", options: .initial, block: { document, KeyPath, change in
                weakSelf?.messagesDidChange()
            })
        }
        messagesTable.doubleAction = #selector(doubleSelect(_:))
        messagesTable.target = self
    }
    
    open func messagesDidChange() -> Void {
        var infoCount = 0
        var warningCount = 0
        var errorCount = 0
        if let document = document as? AIEDocument {
            let messages = document.messages
            orderedMessages.removeAll()
            groupedMessages.removeAll()
            for message in messages {
                if let object = message.object {
                    var bucket = groupedMessages[object as! AnyHashable]
                    if bucket == nil {
                        bucket = [AIEMessage]()
                        orderedMessages.append(object)
                    }
                    bucket?.append(message)
                    groupedMessages[object as! AnyHashable] = bucket
                }
                switch message.type {
                case .info:
                    infoCount += 1
                case .warning:
                    warningCount += 1
                case .error:
                    errorCount += 1
                }
            }
            if groupedMessages.count > 0 {
                tabView.selectTabViewItem(at: 1)
                messagesTable.reloadData()
                for (object, _) in groupedMessages {
                    messagesTable.expandItem(object)
                }
            }
            // Now, show an appropriate badge for "worse" type.
            if errorCount > 0 {
                badge = AJRImages.image(named: "AJRBadgeErrorMini", in: AJRInterfaceBundle())
            } else if warningCount > 0 {
                badge = AJRImages.image(named: "AJRBadgeWarningMini", in: AJRInterfaceBundle())
            } else if infoCount > 0 {
                badge = AJRImages.image(named: "AJRBadgeInfoMini", in: AJRInterfaceBundle())
            } else {
                badge = nil
            }
        } else {
            tabView.selectTabViewItem(at: 0)
            badge = nil
        }
    }
    
    // MARK: - NSOutlineViewDataSource
    
    open func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item is AIEMessage {
            return orderedMessages.count
        } else if let item = item as? AIEMessageObject {
            if let messages = groupedMessages[item as! AnyHashable] {
                return messages.count
            }
            return 0
        } else if item == nil {
            return groupedMessages.count
        }
        return 0
    }
    
    open func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return false
    }
    
    open func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? AIEMessageObject,
           let messages = groupedMessages[item as! AnyHashable] {
            return messages.count > 0
        }
        return false
    }
    
    open func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? AIEMessageObject {
            if let messages = groupedMessages[item as! AnyHashable] {
                return messages[index]
            }
            return 0
        } else if item == nil {
            return orderedMessages[index]
        }
        return 0
    }

    open func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let view = outlineView.makeView(withIdentifier: .messageView, owner: nil) as? NSTableCellView {
            if let item = item as? AIEMessageObject {
                view.textField?.stringValue = item.messagesTitle
                view.imageView?.image = item.messagesImage
            } else if let item = item as? AIEMessage {
                view.textField?.stringValue = item.message
                var image : NSImage? = nil
                switch item.type {
                case .info:
                    image = AJRImages.image(named: "AJRBadgeInfoSmall", in: AJRInterfaceBundle())
                case .warning:
                    image = AJRImages.image(named: "AJRBadgeWarningSmall", in: AJRInterfaceBundle())
                case .error:
                    image = AJRImages.image(named: "AJRBadgeErrorSmall", in: AJRInterfaceBundle())
                }
                view.imageView?.image = image
            }
            return view
        }
        return nil
    }
    
    // MARK: - NSOutlineViewDelegate
    
    open func outlineViewSelectionDidChange(_ notification: Notification) {
        let indexes = messagesTable.selectedRowIndexes
        var graphicsToSelect = Set<AIEGraphic>()
        for index in indexes {
            let item = messagesTable.item(atRow: index)
            if let item = item as? AIEGraphic {
                graphicsToSelect.insert(item)
            } else if let item = item as? AIEMessage,
                      let object = item.object as? AIEGraphic {
                graphicsToSelect.insert(object)
            }
        }
        if graphicsToSelect.count > 0 {
            document?.clearSelection()
            document?.addGraphics(toSelection: graphicsToSelect as NSSet)
        }
    }

    // MARK: - Actions

    @IBAction open func doubleSelect(_ sender: Any?) -> Void {
        // We just hand focus over to the main editor.
        document?.makeSelectionOrVisiblePageFirstResponderAndScrollToVisible(true)
    }

}
