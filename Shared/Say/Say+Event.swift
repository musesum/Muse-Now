//  Say+Event.swift
//  Created by warren on 4/24/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation

extension Say {

    /**
    Announce change between future and past tense
    */
    func sayFuturePast(_ isFuture: Bool) {
        let title = isFuture ? "future" : "past"
        updateDialog(nil, type:.sayDirection, spoken:title, title:title)
    }
        
    /**
     Announce a dot event based on type, via:
     - Scene.scanning ⟶ Dots+Say.say[First|Next]Dot
     - Scene.touchDialPan ⟶ Dots+Action.updateViaPan
     - Scene+action.crownAction ⟶ Dots+Action.crownNextEventOrHour
     */
    func sayDotEvent(_ event: MuEvent!, isTouching:Bool) {
        
        switch event.type {
        case .time: sayCurrentTime(event, isTouching) // announce time
        case .memo: sayRecording(event)    // play recording
        default:
            if event.mark { sayElapseTime(event) } // elapsed time for marked events
            else          { sayBeginTime(event)  } // begin time for unmarked events
        }
    }

    /**
     Announce current time
     - via: sayDotEvent
     */
    func sayCurrentTime(_ event:MuEvent!, _ isTouching:Bool) {
        
        let dateFormatter = DateFormatter()

        // announce day of week for position in dial (ignored if duplicate)
        if isSayTimeNow {

            dateFormatter.dateFormat = "EEEE"
            let txt = dateFormatter.string(from:Date())
            updateDialog(event, type:.sayDayOfWeek, spoken:txt, title:txt)
        }
        
        // announce curren time
        dateFormatter.dateFormat = "h:mm a"
        let spoken = "Now " + dateFormatter.string(from:Date())
        let title = isTouching ? "" : "Muse Now"
        updateDialog(event, type:.sayTimeNow, spoken:spoken, title:title)
    }
    
    /**
     play audio recording, optionally play its time
     - via: Say+Event.sayDotEvent
     */
    func sayRecording(_ event: MuEvent!) {
        
        updateDialog(event, type:.sayMemo, spoken:event.eventId, title:event.title)
        
        if isSayTimeElapsed {
            
            let timeNow = Date().timeIntervalSince1970
            let prefix = timeNow < event.bgnTime ? "in " : ""
            let suffix = timeNow < event.bgnTime ? "" : " ago"
            let elapse = prefix + MuDate.elapseTime(event.bgnTime) + suffix

            updateDialog(event, type:.sayEventTime, spoken:elapse, title:elapse)

        }
    }
    
    /**
     announce elapsed time to or from event's begin time
     - via: Scene.update.scanning
     */
    func sayElapseTime(_ event:MuEvent!) {
        
        updateDialog(event, type:.sayEventTitle, spoken:event.title, title:event.title)

       if isSayEventTime {
        
            let timeNow = Date().timeIntervalSince1970
            let prefix = timeNow < event.bgnTime ? "in " : ""
            let suffix = timeNow < event.bgnTime ? "" : " ago"
            let elapse = prefix + MuDate.elapseTime(event.bgnTime) + suffix
        
            updateDialog(event, type:.sayEventTime, spoken:elapse, title:elapse)
        }
    }
    
    /**
     Announce a marked dot's first occurring event
     - via: Scene.update.scanning
     */
    func sayBeginTime(_ event: MuEvent!) {
        
        updateDialog(event, type:.sayEventTitle, spoken:event.title, title:event.title)
        
        if isSayEventTime {
            
            let timeNow = Date().timeIntervalSince1970
            let prefix = timeNow < event.bgnTime ? "begins " : "began "
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let date = Date(timeIntervalSince1970:event.bgnTime)
            let title = dateFormatter.string(from:date)
            let spoken = prefix + title
            updateDialog(event, type:.sayEventTime,  spoken:spoken,   title:title)
        }
    }
    
    /**
     announce an unmarked dot's time
     - via: Scene.update.scanning
     */
    func sayDotTime(_ event: MuEvent!) {
        
        if isSayDayOfWeek {
            let txt  = dayHour.getDowSpeak()
            updateDialog(event, type:.sayDayOfWeek, spoken:txt, title:txt)
        }
        if isSayTimeHour {
            
            let txt = dayHour.getHourSpeak()
            updateDialog(event, type:.sayDotTime, spoken:txt, title:txt)
        }
    }

}
