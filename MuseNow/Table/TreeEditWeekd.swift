import UIKit
import EventKit

class TreeEditTimeCell: TreeCell {

    // Time Picker
    var bgnTimePicker:  UIPickerView! // time of day to begin
    var bgnLabel:       UILabel! // time of day to begin
    var bgnTimeFrame    = CGRect.zero

    var endTimePicker:  UIPickerView! // time of day to begin
    var endLabel:       UILabel! // time of day to begin
    var endTimeFrame    = CGRect.zero

    var arrowLabel:     UILabel!
    var arrowFrame      = CGRect.zero

    var hours = ["00","01","02","03","04","05","06","07","08","09", "10","11","12","13","14","15","16","17","18","19", "20","21","22","23"]
    var mins = ["00","05","10","15","20","25","30","35","40","45","50","55"]

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ size:CGSize) {
        
        self.init()
        height = 64
        treeNode = treeNode_
        buildViews(size)
        setHighlight(false, animated:false)
    }

    override func buildViews(_ size: CGSize) {
        
        super.buildViews(size)
        buildTimePickerViews()

        // view
        bezel.addSubview(arrowLabel)
        bezel.addSubview(bgnLabel)
        bezel.addSubview(endLabel)
        bezel.addSubview(bgnTimePicker)
        bezel.addSubview(endTimePicker)

        updateTimePickerValues(animated:false)
    }

  
    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH
        let bezelH = height - 2*marginH
        let bezelW = size.width - bezelX

        let btimeX  = CGFloat(0)
        let timeW  = bezelW/2
        let etimeX  = btimeX + timeW

        leftFrame     = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        bgnTimeFrame  = CGRect(x: btimeX,  y: 0,      width: timeW,  height: bezelH)
        endTimeFrame  = CGRect(x: etimeX,  y: 0,      width: timeW,  height: bezelH)
        arrowFrame    = CGRect(x: 0,       y: 0,      width: bezelW, height: bezelH)
        bezelFrame    = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews() {
        
        super.updateViews()

    }

 }

















