//  CalCell.swift


import UIKit
import EventKit

class CalCell: KoCell {
    
    var cal: Cal!
    var isShowCal = true
 
    @IBOutlet weak var bezel: UIView!
    @IBOutlet weak var color: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var mark: ToggleCheck!
    
    func setCellCalendar(_ calendar: Cal!,_ size:CGSize) {
        
        cal = calendar
        self.frame.size = size
        contentView.backgroundColor = cellColor
        
        let innerH = CGFloat(36)    // inner height
        let dotW = CGFloat(10)
        
        // dot
        color.image = UIImage.circle(diameter: dotW, color:UIColor(cgColor:cal.color))
        
        // title
        title.text = cal.title
        title.textColor = .white
        title.highlightedTextColor = .black
        
        // bezel for title
        bezel.layer.cornerRadius = innerH/4
        bezel.layer.borderWidth = 1
        bezel.layer.masksToBounds = true
        
        // bezel for mark
        mark.layer.cornerRadius = innerH/4
        mark.layer.borderWidth = 1
        mark.layer.masksToBounds = true
        mark.setMark(cal.isOn)
        
        setHighlight(false, animated:false)
    }
    
    override func setHighlight(_ isHighlight_:Bool, animated:Bool = true) {
        
        isHighlight = isHighlight_
        
        let index       = isHighlight ? 1 : 0
        let borders     = [cellColor.cgColor, UIColor.white.cgColor]
        let backgrounds = [cellColor.cgColor, UIColor.black.cgColor]
        
        if animated {
            animateViews([bezel,mark], borders, backgrounds, index, duration: 0.25)
        }
        else {
            bezel.layer.borderColor     = borders[index]
            mark.layer.borderColor      = borders[index]
            bezel.layer.backgroundColor = backgrounds[index]
            mark.layer.backgroundColor  = backgrounds[index]
        }
        if !isHighlight {
            isSelected = false
        }
    }
    
    override func touchMark() {
        
        isShowCal = !isShowCal
        mark?.setMark(isShowCal)
        
        Cals.shared.updateMark(cal.calId, isShowCal)
        Session.shared.sendMsg( [ "class" : "Cals",
                                  "calId" : cal.calId,
                                  "isOn"  : isShowCal])
    }
    
    override func touchTitle() {
    
    }
}

