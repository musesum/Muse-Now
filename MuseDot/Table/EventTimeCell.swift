//  TimeCell.swift

import UIKit

class EventTimeCell: MuCell {
    

    @IBOutlet weak var time: UILabel!
    let rowHeight = CGFloat(44)
    let sectionHeight = CGFloat(36)
    
    func setCell(event event_: MuEvent!, _ size: CGSize) {

        selectionStyle = UITableViewCellSelectionStyle.none
        event = event_ // not really needed

        // time hour:Min
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let hourStr = dateFormatter.string(from: Date())

        time.text = hourStr
        time.textColor = .white
        time.backgroundColor = .black
        time.highlightedTextColor = .white
        time.font = UIFont(name: "Helvetica Neue", size: 22)!
        time.textColor = .white
        time.textAlignment = .center
        
        // bezel for time
        time.layer.cornerRadius = time.frame.height/2
        time.layer.borderColor = headColor.cgColor
        time.layer.borderWidth = 1
        time.layer.masksToBounds = true


        setHighlight(.forceHigh, animated:false)

    }
    
    override func setHighlight(_ highlighting_:Highlighting, animated:Bool = true) {

        if highlighting != highlighting_ {

            switch highlighting_ {
            case .high,.forceHigh: highlighting = .high ; isSelected = true
            default:               highlighting = .low  ; isSelected = false
            }
            let fromColor = highlighting == .high ?  UIColor.darkGray.cgColor :  UIColor.white.cgColor
            let toColor   = highlighting == .high ?  UIColor.white.cgColor    :  UIColor.darkGray.cgColor

            if animated {
                animateBorderColor(time,   fromColor, toColor, duration: 0.25)
            }
            else {
                time.layer.borderColor = toColor
            }
        }
        else {
            switch highlighting {
            case .high,.forceHigh: isSelected = true       
            default:               isSelected = false
            }
        }
    }
}
