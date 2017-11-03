import EventKit
import UIKit

/// KoEvents are are view upon EventKit calendar events and reminders
/// including a special timeEvent that changes every minute
class KoEvents {
    
    static let shared = KoEvents()
    static var eventsChangedTime = TimeInterval(0)
    let session = Session.shared
    let memos = Memos.shared
    let marks = Marks.shared

    var calendars = [EKCalendar]()
    var events = [KoEvent]()
    var timeEvent: KoEvent!
    var timeEventIndex : Int = -1   // index of timeEvent in koEvents

    let eventStore = EKEventStore()

    /// Main entry for updating events
    /// - via: Actions.doRefresh

    func updateEvents(_ completion: @escaping () -> Void) {
        //updateFakeEvents(completion)
        updateRealEvents(completion)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(EkNotification(notification:)), name: Notification.Name.EKEventStoreChanged, object: eventStore)
    }
    
    @objc private func EkNotification(notification: NSNotification) {
        printLog("📅 notification:\(notification.name.rawValue)")
    }

    func getRealEvents(_ completion: @escaping (
        _ ekEvents      : [KoEvent],
        _ ekReminders   : [KoEvent]) -> Void) -> Void  {
        
        let queue = DispatchQueue(label: "com.muse.getRealEvents", attributes: .concurrent, target: .main)
        let group = DispatchGroup()
        
        var ekEvents    : [KoEvent] = []
        var ekReminders : [KoEvent] = []

        // ekevents
        group.enter()
        queue.async (group: group) {
            self.getEkEvents() { result in
                ekEvents = result
                group.leave()
            }
        }
        // ekreminders
        group.enter()
        queue.async (group: group) {
            self.getEkReminders() { result in
                ekReminders = result
                group.leave()
            }
        }
        // memos
        group.enter()
        queue.async (group: group) {
            self.memos.unarchiveMemos() {
                group.leave()
            }
        }
        // marks
        group.enter()
        queue.async (group: group) {
            self.marks.unarchiveMarks() {
                group.leave()
            }
        }
        // events + reminders done
        group.notify(queue: queue, execute: {
            completion(ekEvents,ekReminders)
        })
    }
    
    ///  Get EventKit events after getting permission

    func getEkEvents(completion: @escaping (_ result:[KoEvent]) -> Void) {
        
        let store = EKEventStore()
        
        store.requestAccess(to: .event) { (accessGranted: Bool, error: Error?) in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    print("there was an errror \(error.localizedDescription)")
                }
                if accessGranted == true {
                    self.readEkEvents(store,completion)
                }
                else {
                    completion ([])
                }
            }
        }
    }

    func readEkEvents(_ store: EKEventStore, _ completion: @escaping (_ result:[KoEvent]) -> Void) {
        
        let store = EKEventStore()
        
        Cals.shared.unarchiveCals(store) {
            
            let (bgnTime,endTime) = KoDate.prevNextWeek() // previous and next week date range
            var events: [KoEvent] = [] // events
            
            let ekCals = Cals.shared.ekCals
            let idCal = Cals.shared.idCal
            var routineCals = [EKCalendar]() //  = ekVals.filter {  $0.title.hasPrefix("Routine") }
            var otherCals = [EKCalendar]() // = ekVals.filter { !$0.title.hasPrefix("Routine") }
            for ekCal in ekCals {
                if let cali = idCal[ekCal.calendarIdentifier], cali.isOn {
                    if ekCal.title.hasPrefix("Routine") { routineCals.append(ekCal) }
                    else                                { otherCals.append(ekCal ) }
                }
            }
            
            if routineCals.count > 0 {
                let pred = store.predicateForEvents(withStart: bgnTime!, end: endTime!, calendars:routineCals)
                for klioEvent in store.events(matching: pred) {
                    events.append(KoEvent(klioEvent,.routine))
                }
            }
            if otherCals.count > 0 {
                let pred = store.predicateForEvents(withStart: bgnTime!, end: endTime!, calendars:otherCals)
                let ekEvents = store.events(matching: pred)
                
                for ekEvent in ekEvents {
                    events.append(KoEvent(ekEvent))
                }
            }
            events.sort { $0.bgnTime < $1.endTime }
            completion(events)
        }
    }

    /// Get EventKit reminder after getting permission
    func getEkReminders(completion: @escaping (_ result:[KoEvent]) ->Void) -> Void {
        
        let store = EKEventStore()
        
        store.requestAccess(to: .reminder) { (accessGranted: Bool, error: Error?) in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    print("there was an errror \(error.localizedDescription)")
                }
                if accessGranted {
                    var events: [KoEvent] = []
                    let (bgnTime,endTime) = KoDate.prevNextWeek()
                    let pred = store.predicateForIncompleteReminders(withDueDateStarting: bgnTime!, ending:endTime!, calendars: nil)
                    
                    store.fetchReminders(matching: pred, completion: { (reminders:[EKReminder]?) in
                        
                        for rem in reminders! {
                            let mkRem = KoEvent(reminder: rem)
                            events.append(mkRem)
                        }
                        completion(events)
                    })
                }
                else {
                    completion([])
                }
            }
        }
    }
    
    
      func addEvent(_ event:KoEvent) {
        events.append(event)
        if event.type == .memo {
            memos.addEvent(event)
        }
        events.sort { lhs, rhs in
            return lhs.bgnTime < rhs.bgnTime
        }
    }
    
    func updateEvent(_ updateEvent:KoEvent) {
        
        var index = events.binarySearch({$0.bgnTime < updateEvent.bgnTime})

        while index < events.count {
            let event = events[index]
            if events[index].bgnTime != updateEvent.bgnTime {
                return
            }
            if event.eventId == updateEvent.eventId {
                event.title = updateEvent.title
                event.sttApple = updateEvent.sttApple
                event.sttSwm = updateEvent.sttSwm
                return
            }
            index += 1
        }
    }
    
    /// real events used for production
    func updateRealEvents(_ completion: @escaping () -> Void) -> Void {
        
        getRealEvents() { ekEvents, ekReminds in
            
            self.events.removeAll()
            self.events = ekEvents + ekReminds + self.memos.items //+ self.getNearbyEvents() //???
            self.sortTimeEventsStart()
            self.applyMarks()
            self.marks.synchronize()
            self.memos.synchronize()
            Cals.shared.synchronize()
            completion()
        }
    }

    /// fake events used for testing
    func updateFakeEvents(_ completion: @escaping () -> Void) -> Void {
        
        getFakeEvents() { events_ in

            self.events.removeAll()
            self.events = events_
            self.sortTimeEventsStart()
            self.marks.synchronize()
            self.memos.synchronize()
            Cals.shared.synchronize()
            completion()
        }
    }
    
    /// After retrieving events and reminders
    /// add a timer event, sort, and start timeEventTimer
    func sortTimeEventsStart() {
        if timeEvent == nil {
            timeEvent = KoEvent(.time, "Time")
        }
        events.append(timeEvent)
        events.sort { lhs, rhs in
            return lhs.bgnTime < rhs.bgnTime
        }
    }
    
    /// find nearest time index
    /// - calls: Collection+Search binarySearch

    func getTimeIndex(_ insertTime: TimeInterval) -> Int {
        let result = events.binarySearch({$0.bgnTime < insertTime})
        return result
    }

    /// attempt to get next mark, if non then next event
    ///  previous marked event, or previus event of none were marked
    func getLastNextEvents() -> (KoEvent?, KoEvent?) {
        var lastEvent: KoEvent!
        var nextEvent: KoEvent!

        let timeNow = Date().timeIntervalSince1970
        for event in events {
            if event.bgnTime < timeNow {
                if event.mark {
                    lastEvent = event
                }
                // if there are no marked previous events then save this one
                if lastEvent == nil {
                    lastEvent = event
                }
            }
            else if nextEvent == nil {
                nextEvent = event
                if nextEvent.mark {
                    nextEvent = event
                    break
                }
            }
        }
        return (lastEvent, nextEvent)
    }
    func minuteTimerTick() {
        
        if timeEvent == nil { return }
        if timeEventIndex < 0 {
            timeEventIndex = getTimeIndex(timeEvent.bgnTime-1)
        }
        if timeEventIndex >= events.count-1 { return }
        
        timeEvent.bgnTime = trunc(Date().timeIntervalSince1970/60)*60
        timeEvent.endTime = timeEvent.bgnTime
        
        if events[timeEventIndex+1].bgnTime < timeEvent.bgnTime {
            
            events.remove(at: timeEventIndex)
            
            for index in timeEventIndex ..< events.count {
                if events[index].bgnTime > timeEvent.bgnTime-1 {
                    events.insert(timeEvent, at: index)
                    timeEventIndex = index
                    break
                }
            }
        }
    }
    
}





























