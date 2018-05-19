//
//  WatchMenu+old.swift
//  MuseNow
//
//  Created by warren on 5/14/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import WatchKit

extension WatchMenu {

    /**
     Menu of STT, hand stroked chars, popular commands
     - via WatchCon.menuAction
     */
    func recordMenu() { // was recordMenu()

        //let index = Anim.shared.getIndexForNote()
        let root = WKExtension.shared().rootInterfaceController!
        let suggestions = Actions.shared.getSuggestions()
        root.presentTextInputController(withSuggestions:suggestions, allowedInputMode: WKTextInputMode.plain) { results in
            guard let results = results else {  print("∿ no results"); return  }
            for result in results {
                if let inputText = result as? String {
                    self.oldMenuFinish(inputText, /*index*/ 0)
                }
            }
            //self.menuRecTimer = Timer.scheduledTimer(timeInterval: 1.0, target:self, selector: #selector(self.recordTimerDone),userInfo:nil, repeats:false)
        }
    }

    func oldMenuFinish(_ inputText:String,_ index: Int) {//  was recordMenuFinish
        Actions.shared.parseString(inputText, /*event*/ nil, index, isSender:true)
        //Crown.shared.updateCrown()
    }

    //    override func awake(withContext context: Any?) {
    //    }
    //
    //    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    //        let newCityNames = ["Saratoga", "San Jose"]
    //
    //        let newCityIndexes = NSIndexSet(indexesIn: NSMakeRange(rowIndex + 1, newCityNames.count))
    //
    //        // Insert new rows into the table.
    //        table.insertRows(at: newCityIndexes as IndexSet, withRowType: "default")
    //
    //        // Update the rows that were just inserted with the appropriate data.
    //        var newCityNumber = 0
    //
    //        for idx in 0 ... newCityIndexes.count-1 {
    //            let newCityName = newCityNames[newCityNumber]
    //            let row = table.rowController(at: idx) as! TableRowController
    //            row.rowLabel.setText(newCityName)
    //            newCityNumber += 1
    //        }
    //    }


}
