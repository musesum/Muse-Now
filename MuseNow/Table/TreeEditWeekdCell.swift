import UIKit
import EventKit

class TreeEditWeekdCell: TreeEditCell {

    var weekdays = [UILabel]()
    var weekFrames = [CGRect]()
    var dayLabels = ["Sun","Mon","Tue","Wed","Thr","Fri","Sat"]

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ size:CGSize) {
        
        self.init()
        height = 64
        treeNode = treeNode_
        buildViews(size)
        setHighlight(true, animated:false)
    }

    func setLabel(_ label:UILabel!, isOn:Bool) {

        let textColor:UIColor = isOn ? .black     : .white
        let backColor:UIColor = isOn ? .lightGray : cellColor

        label.textColor = textColor
        label.backgroundColor = backColor
    }

    func buildLabel(_ index:Int, _ isOn:Bool) -> UILabel {

        let frame = weekFrames[index]
        let label = UILabel(frame:frame)

        setLabel(label, isOn: isOn)

        label.font = UIFont(name: "Menlo-Bold", size: 14)!
        label.textAlignment = .center

        //label.isHighlighted = true
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor.white.cgColor
        label.isUserInteractionEnabled = false

        label.text = dayLabels[index]
        return label
    }

    override func buildViews(_ size: CGSize) {
        
        super.buildViews(size)

        if let node = treeNode as? TreeRoutineItemNode,
            let item = node.routineItem {

            weekdays.removeAll()

            for i in 0 ..< 7 {
                let mask = 1 << (6 - i)
                let isOn = (item.daysOfWeek.rawValue & mask) != 0
                let label = buildLabel(i, isOn)
                weekdays.append(label)
                bezel.addSubview(label)
            }
        }
        selectionStyle = .none
    }

  
    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-2) * 2 * marginW
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH
        let bezelH = height - 2*marginH
        let bezelW = size.width - bezelX

        let weekW = ceil(bezelW / 7 * 2) / 2
        var weekX = CGFloat(0)

        leftFrame  = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)

        weekFrames.removeAll()
        for _ in 0..<7 {

            let wframe = CGRect(x: weekX,   y: 0,  width: weekW,  height: bezelH)
            weekX = weekX + weekW
            weekFrames.append(wframe)
        }
        bezelFrame = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews() {
        
        super.updateViews()

    }

    override func touchCell(_ point: CGPoint, highlight: Bool = true) {

        let location = CGPoint(x: point.x - bezelFrame.origin.x, y: point.y)

        for i in 0..<7 {
            if weekFrames[i].contains(location) {

                if let node = treeNode as? TreeRoutineItemNode,
                    let item = node.routineItem {

                    // flip day optionset
                    let mask = 1 << (6 - i)
                    let dow = item.daysOfWeek.rawValue ^ mask
                    item.daysOfWeek = DaysOfWeek(rawValue:dow)
                    item.updateLabelStrings()

                    // update lable
                    let isOn = (dow & mask) != 0
                    let label = weekdays[i]
                    setLabel(label, isOn: isOn)

                    if let parent = node.parent,
                        let cell = parent.cell as? TreeTimeTitleDaysCell {

                        cell.days.text = item.dowString

                    }
                    break
                }
            }
        }
    }
 }

















