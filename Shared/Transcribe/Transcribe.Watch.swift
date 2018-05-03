//
//  Transcribe.Watch.swift
//  MuseNow
//
//  Created by warren on 5/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

class Transcribe {
        static var shared = Transcribe()

    /**
    When app become active, process pending memo events while app was inactive
     */
    func processPendingEvents() {
        // Not available for Watch for iOS 11
    }

    func appleTranscribeEvent(_ event:MuEvent, _ done: @escaping CallVoid) { // Log("✏ Watch::\(#function)")
    }

    func waitTranscribe(_ event:MuEvent,_ done: @escaping CallVoid) { Log("✏ Watch::\(#function)")

        Actions.shared.doUpdateEvent(event, isSender:false)
        Session.shared.transferMemoEvent(event)
        Session.shared.sendMsg(["class": "WakeUp"])
        done()
    }
}
