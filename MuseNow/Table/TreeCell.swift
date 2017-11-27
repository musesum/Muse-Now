//  CalCell.swift


import UIKit
import EventKit

class TreeCell: MuCell {

    var treeNode: TreeNode!
    var left: UIImageView!
    var bezel: UIView!

    var leftFrame  = CGRect.zero
    var bezelFrame = CGRect.zero

    let leftW = CGFloat(24)     // width (and height) of left disclosure image
    let innerH = CGFloat(36)    // inner height
    let marginW = CGFloat(8)    // margin between elements
    let marginH = CGFloat(4)    //

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ width:CGFloat) {

        self.init()
        frame.size = CGSize(width:width, height:height)
        treeNode = treeNode_
        buildViews(frame.size)
    }
    
    func buildViews(_ size:CGSize) {

        updateFrames(size)

        contentView.backgroundColor = .black
        backgroundColor = .black

        // left

        left = UIImageView(frame:leftFrame)
        left.image = UIImage(named:"DotArrow.png")
        left.alpha = 0.0 // refreshNodeCells() will setup left's alpha for the whole tree

        // make this cell searchable within static cells
        PagesVC.shared.treeTable.cells[treeNode.setting.title] = self

        // bezel for title
        bezel = UIView(frame:bezelFrame)
        bezel.backgroundColor = .clear
        bezel.layer.cornerRadius = innerH/4
        bezel.layer.borderWidth = 1
        bezel.layer.masksToBounds = true

        contentView.addSubview(left)
        contentView.addSubview(bezel)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .black

        bezel.frame = bezelFrame
    }
    /**
     adjust display (such as a check mark) based on ratio of children that are set on
    */
    func updateOnRatio() {
        // override
    }
    func updateLeft(animate:Bool) {

        var transform = CGAffineTransform.identity
        var alpha = CGFloat(0.0)

        if let treeNode = treeNode {

            var expandable = false

            switch treeNode.type {

            case .unknown,
                 .title,
                 .titleMark,
                 .colorTitle,
                 .colorTitleMark:    expandable = treeNode.children.count > 0

            case .timeTitleDays:     expandable = true

            case .titleFader,
                 .editTime,
                 .editTitle,
                 .editWeekday,
                 .editColor:         expandable = false
            }
            if expandable {

                let angle = CGFloat(treeNode.expanded ? Pi/3 : 0)
                transform = CGAffineTransform(rotationAngle: angle)
                alpha = treeNode.expanded ? 1.0 : 0.25
            }
            print ("\(treeNode.setting?.title ?? "unknown") \(treeNode.type):\(expandable) ")
        }

        if animate {
            UIView.animate(withDuration: 0.25, animations: {
                self.left.transform = transform
                self.left.alpha = alpha
            })
        }
        else {
            left.transform = transform
            left.alpha = alpha
        }
    }

    func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (size.height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = (size.height - innerH) / 2
        let bezelH = size.height - 2*marginH

        let bezelW = size.width - marginW - bezelX

        leftFrame  = CGRect(x:leftX, y:leftY, width: leftW, height: leftW)
        bezelFrame = CGRect(x:bezelX, y:bezelY, width: bezelW, height: bezelH)
       }

    func updateViews() {

        let size = PagesVC.shared.treeTable.view.frame.size
        updateFrames(size)
        buildViews(size)
    }

    override func setHighlight(_ isHighlight_:Bool, animated:Bool = true) {
        
        if isHighlight != isHighlight_ {
            isHighlight = isHighlight_

            let index       = isHighlight ? 1 : 0
            let borders     = [UIColor.black.cgColor, UIColor.white.cgColor]
            let backgrounds = [UIColor.clear.cgColor, UIColor.black.cgColor]

            if animated {
                animateViews([bezel], borders, backgrounds, index, duration: 0.25)
            }
            else {
                bezel.layer.borderColor     = borders[index]
                bezel.layer.backgroundColor = backgrounds[index]
            }
        }
        isSelected = isHighlight
    }

    override func touchCell(_ location: CGPoint, highlight: Bool = true) {

        // when collapsing sibling, self may also get collapsed, so need to know original state to determine highlight
        let wasExpanded = treeNode.expanded

        // collapse siblings
        var siblingCollapsing = false
        if treeNode.parent != nil {
            for sib in treeNode.parent.children {
                if sib.expanded {
                    sib.cell.touchFlipExpand(highlight:false)
                    siblingCollapsing = true
                    break
                }
            }
        }
        // expand self
        if treeNode.children.count > 0,
            wasExpanded == treeNode.expanded {

            if siblingCollapsing {
                // wait until sibling has finshed collapasing before expanding self
                let _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: {_ in
                    self.touchFlipExpand(highlight:highlight)
                })
                return
            }
            else {
                return touchFlipExpand(highlight:highlight)
            }
        }
        // either no siblings were collapsed or I'm not one of the siblings with children
        if !siblingCollapsing || treeNode.children.count == 0 {
            PagesVC.shared.treeTable.updateTouchCell(self, reload:false, highlight: true)
        }
    }

    /**
     collapse sibling and its currently expanded child, grandchild etc
     */
    func collapseAllTheWayDown() {

        treeNode.expanded = false
        updateLeft(animate:true)
        for childNode in treeNode.children {
            if childNode.expanded,
                let childCell = childNode.cell {
                childCell.collapseAllTheWayDown()
            }
        }
    }

    func touchFlipExpand(highlight:Bool) {
        
        let oldCount = TreeNodes.shared.shownNodes.count

        if treeNode.expanded == true {
            collapseAllTheWayDown()
        }
        else {
            treeNode.expanded = true
            updateLeft(animate:true)
        }
        TreeNodes.shared.renumber(treeNode)
        PagesVC.shared.treeTable.updateTouchCell(self, reload:true, highlight:highlight, oldCount)
    }
}

