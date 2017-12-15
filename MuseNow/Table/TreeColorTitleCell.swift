//  CalCell.swift


import UIKit
import EventKit

class TreeColorTitleCell: TreeTitleCell {

    var color: UIImageView!
    var colorFrame = CGRect.zero
    let colorW  = CGFloat(8)

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ tableVC_:UITableViewController) {
        self.init()
        tableVC = tableVC_
        treeNode = treeNode_
        let width = tableVC.view.frame.size.width
        frame.size = CGSize(width:width, height:height)
        buildViews(width)
    }

    override func buildViews(_ width:CGFloat) {

        super.buildViews(width)
        color = UIImageView(frame:colorFrame)
        
        bezel.addSubview(color)
    }

    override func updateFrames(_ width:CGFloat) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH
        let bezelW = width - bezelX

        let colorX = marginW
        let colorY = (bezelH - colorW) / 2

        let titleX = colorX + colorW + marginW
        let titleW = bezelW - titleX

        cellFrame  = CGRect(x: 0,      y: 0,      width: width,  height: height)
        leftFrame  = CGRect(x: leftX,  y: leftY,  width: leftW,  height: leftW)
        colorFrame = CGRect(x: colorX, y: colorY, width: colorW, height: colorW)
        titleFrame = CGRect(x: titleX, y: 0,      width: titleW, height: bezelH)
        bezelFrame = CGRect(x: bezelX, y: bezelY, width: bezelW, height: bezelH)
        autoExpand = false
    }

    override func updateViews(_ width:CGFloat) {

        updateFrames(width)
        
        self.frame  = cellFrame
        left.frame  = leftFrame
        color.frame = colorFrame
        title.frame = titleFrame
        bezel.frame = bezelFrame
    }

    // color dot
    func setColor(_ rgb: UInt32) {

        let rgb = MuColor.getUIColor(rgb)
        color.image = UIImage.circle(diameter: colorW, color:rgb)
        color.backgroundColor = .clear
    }
    func setColor(_ cgColor: CGColor) {
        color.image = UIImage.circle(diameter: colorW, cgColor:cgColor)
        color.backgroundColor = .clear
    }


 }
