//  Calendar.swift

import Foundation
import EventKit
import UIKit

/**
 Allow mark to be set from parent and/or child
 - parent: toggle ✓/☐ will set all children ✓/☐
 - child: toggle  ✓/☐ will parent to  ✓/-/☐
 */
public enum SetFrom: Int, Codable { case none, parent, child, both }

/**
 Optional info disclosure upon first expand
 - noInfo: do not show "i" icon
 - newInfo: white icon, auto show info on expand
 - oldInfo: gray icon, only show when touching icon
 */
enum ShowInfo: Int, Codable { case
    infoNone,       // no info attached to this celll
    information,    // not yet touched, so play bubble before expanding
    construction,
    purchase
}

public class TreeSetting: Codable {

    var member  = 0         // member of set (using OptionSet bit flags)
    var set     = 0         // OptionSet bit flags
    var setFrom = SetFrom.both // modifyable from { none,child,parent,both }
    var showInfo = ShowInfo.infoNone

    func isOn() -> Bool {
        return set & member != 0
    }
    func setOn(_ on:Bool) {
        if on {
            set |= member
        }
        else {
            set |= member
            set ^= member
        }
    }
    func flipSet() -> Bool {
        set ^= member
        return isOn()
    }

    init(set set_:Int, member member_:Int,_ setFrom_:SetFrom = .both, _ showInfo_:ShowInfo = .infoNone) {

        set      = set_
        setFrom  = setFrom_
        member   = member_
        showInfo = showInfo_
    }

}


