import UIKit

class ToggleDot: UIView {
    
    var dot = UIView(frame: CGRect(x:11, y:11, width:14, height:14))
    var onRatio = Float(0)
    var event : MuEvent!
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        initToggleDot()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initToggleDot()
    }
    
     func initToggleDot() {
        
        // set border color for highl
        layer.cornerRadius = self.frame.height/2
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        
        // make dot
        dot.layer.cornerRadius = dot.frame.height/2
        dot.layer.masksToBounds = true
        dot.backgroundColor = .clear
        self.addSubview(dot)
    }

    func setMark(_ onRatio_:Float) {
        onRatio = onRatio_
        dot.backgroundColor = onRatio > 0 ? .white : .clear
        event?.mark = onRatio > 0
    }

    func toggle() {
        setMark(onRatio > 0 ? 0 : 1)
    }
}

class ToggleCheck: UIView {
    
    enum MarkType { case none, dash, check }
    var check : UIImageView!
    var event : MuEvent!
    var mark = MarkType.none
    var onRatio = Float(0)
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        initToggleDot()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initToggleDot()
    }
    
    func initToggleDot() {
    
        let height = self.frame.height
        
        // set border color for highl
        layer.cornerRadius = height/4
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        
        // make check
        check = UIImageView(image: UIImage(named: "icon-check.png")!)
        check.frame = CGRect(x:0, y:0, width:height, height:height)
        self.addSubview(check)
        
    }
    
    func setMark(_ onRatio_:Float) {

        onRatio = onRatio_

        if onRatio == 1.0 {
            check.image = UIImage(named: "icon-check.png")!
            check.isHidden = false
        }
        else if onRatio > 0.0 {
            check.image = UIImage(named: "icon-dash.png")!
            check.isHidden = false
        }
        else {
            check.isHidden = true
        }
    }

    func toggle() {
        setMark(onRatio > 0 ? 0 : 1)
    }
    
}
