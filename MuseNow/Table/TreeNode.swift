//
//  TreeNode.swift
//  MuseNow
//
//  Created by warren on 11/18/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class TreeNodes {

    static var shared = TreeNodes()

    var shownNodes = [TreeNode!]() // currently displayed nodes

    /**
        Renumber currently displayed table cells. Used for animating expand/collapse of children
     */
    func renumber(_ node:TreeNode) {

        var parenti = node.parent
        while parenti?.parent != nil {
            parenti = parenti?.parent
        }
        shownNodes.removeAll()
        parenti?.expanded = true // root always expanded
        renumbering(parenti)
    }

    private func renumbering(_ node:TreeNode!)  {

        if node.expanded {
            for child in node.children {
                child.row = shownNodes.count
                shownNodes.append(child)
                renumbering(child)
            }
        }
    }
}

enum TreeNodeType { case
    unknown,
    title,
    titleFader,
    titleMark,
    colorTitle,
    colorTitleMark,
    timeTitleDays,
    editTime,
    editTitle,
    editWeekday,
    editColor
}

class TreeNode {

    var type = TreeNodeType.titleMark
    var parent: TreeNode!
    var children = [TreeNode]()
    var level = 0
    var expanded = false
    var setting: Setting!
    var cell: TreeCell!
    var any: Any! // may contain Cal
    var row = -1
    var onRatio = CGFloat(1.0)

    var callback: ((TreeNode) -> ())?

      init (_ type_:TreeNodeType, _ parent_:TreeNode!,_ setting_: Setting ,_ width:CGFloat) {

        parent = parent_
        setting = setting_

        if let parent = parent {
            level = parent.level+1
            parent.children.append(self)
        }

        type = type_
        switch type {
        case .title:            cell = TreeTitleCell(self, width)
        case .titleFader:       cell = TreeTitleFaderCell(self, width)
        case .titleMark:        cell = TreeTitleMarkCell(self, width)
        case .colorTitle:       cell = TreeColorTitleCell(self, width)
        case .colorTitleMark:   cell = TreeColorTitleMarkCell(self, width)
        case .timeTitleDays:    cell = TreeTimeTitleDaysCell(self, width)
        case .editTime:         cell = TreeEditTimeCell(self, width)
        case .editTitle:        cell = TreeEditTitleCell(self, width)
        case .editWeekday:      cell = TreeEditWeekdayCell(self, width)
        case .editColor:        cell = TreeEditColorCell(self, width)
        case .unknown:          cell = TreeEditColorCell(self, width)
        }
    }
    func updateCallback() {
        callback?(self)
    }
      func updateOnRatioFromChildren() {
        if children.count > 0 {

            // only count children which have marks
            var markCount = CGFloat(0)
            var isOnCount = CGFloat(0)
            for child in children {
                switch child.type {
                    case .titleMark,
                         .colorTitleMark:
                        markCount += 1.0
                        isOnCount += child.setting.isOn() ? 1.0 : 0.0
                default: break // ignore non marked child
                }
            }
            if markCount > 0 {
                onRatio =  isOnCount/markCount
            }
            else {
                onRatio = CGFloat(setting.isOn() ? 1.0 : 0.0)
            }
        }
        else {
            onRatio = CGFloat(setting.isOn() ? 1.0 : 0.0)
        }
        setting.setOn(onRatio > 0) // synch setting with onRatio
    }

    func updateMyChildren() {
        if children.count > 0 {
            let myOn = onRatio > 0
            for child in children {
                child.updateOnFromParent(myOn)
            }
        }
    }
    func updateOnFromParent(_ parentOn:Bool) {
        if parentOn != setting.isOn() {
            let isOn = setting.flipSet()
            onRatio = isOn ? 1.0 : 0.0
            setting.setOn(onRatio > 0) // synch setting with onRatio
            updateMyChildren()
            cell?.updateOnRatio()
            callback?(self)
        }
    }

  
    func toggle() -> Bool {
        let isOn = setting.flipSet()
        onRatio = isOn ? 1.0 : 0.0
        setting.setOn(onRatio > 0) // synch setting with onRatio
        updateMyChildren()
        parent?.cell?.updateOnRatio()
        cell?.updateOnRatio()
        callback?(self)
        return isOn
    }

    /**
     Wait for table update before setting child highlight
     */
    func setCellHighlight(_ highlight:Bool) {
        let _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: {_ in
            self.cell?.setHighlight(highlight, animated: true) ; printLog("⿳ \(#function):  self.cell?.setHighlight(\(highlight))")
        })
    }
    /**
    After building hierarchy
     - refresh left arrows to show if any children
     - refresh grayed check to show how many checked children
     */
    func refreshNodeCells() {
        updateOnRatioFromChildren()
        cell?.updateOnRatio()
        cell?.updateLeft(animate: false)
        for child in children {
            child.refreshNodeCells()
        }
    }
}

class TreeCalendarNode: TreeNode {

    init (_ parent_:TreeNode!,_ title_:String, _ cal:Cal!,_ width:CGFloat) {

        super.init(.colorTitleMark, parent_, Setting(set:1,member:1,title_), width)

        if let cell = cell as? TreeColorTitleMarkCell {
            cell.setColor(cal.color)
        }
        any = cal.calId // any makes a copy of Cal, so use calID, instead
        callback = { treeNode in

            if let calId = treeNode.any as? String,
                let cal = Cals.shared.idCal[calId],
                let isOn = treeNode.setting?.isOn() {
                cal.updateMark(isOn)
            }
        }
    }
}
class TreeDialColorNode: TreeNode {

    init (_ parent_:TreeNode!,_ title_:String,_ width:CGFloat) {

        super.init(.titleFader, parent_, Setting(set:0,member:1,title_), width)

        if let cell = cell as? TreeTitleFaderCell {

            // intialize fader
            if let value = Settings.shared.root["dialColor"] as? Float{
                cell.fader.setValue(value)
            }
            // callback when starting fade, so freeze scrolling
            cell.fader.updateBegan = {
                PagesVC.shared.treeTable.tableView.isScrollEnabled = false
                PagesVC.shared.scrollView?.isScrollEnabled = false
            }
            // callback when ending fade, so free scrolling
            cell.fader.updateEnded = {
                PagesVC.shared.treeTable.tableView.isScrollEnabled = true
                PagesVC.shared.scrollView?.isScrollEnabled = true
            }
            // callback to set dial color
            cell.fader.updateValue = { value in
                Actions.shared.dialColor(value, isSender: true)
                let phrase = String(format:"%.2f",value)
                Say.shared.updateDialog(nil, .phraseSlider, spoken:phrase, title:phrase)
            }
        }
    }
}

class TreeActNode: TreeNode {
    init (_ parent_:TreeNode!,_ title_:String, _ set:Int, _ member: Int,_ onAct:DoAction,_ offAct:DoAction,_ width: CGFloat) {
        super.init(.titleMark, parent_, Setting(set:0,member:1,title_), width)

        // callback to set action message based on isOn()
         callback = { treeNode in
            Actions.shared.doAction(treeNode.setting.isOn() ? onAct : offAct )
        }
    }
}

class TreeRoutineCategoryNode: TreeNode {
    init (_ parent_:TreeNode!,_ title_:String, _ width:CGFloat) {
        super.init(.colorTitle, parent_, Setting(set:0,member:1,title_), width)
    }
}
class TreeRoutineItemNode: TreeNode {
    var routineItem: RoutineItem!
    init (_ type_: TreeNodeType,_ parent_:TreeNode!,_ item:RoutineItem, _ width:CGFloat) {
        routineItem = item
        super.init(type_, parent_, Setting(set:0, member:1, item.title), width)
        // callback to refresh display for changes
        callback = { treeNode in
            Actions.shared.doAction(.refresh)
        }
    }
}

