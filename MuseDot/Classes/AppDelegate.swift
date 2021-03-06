
import UIKit


@objc(MyApplication) class MyApplication: UIApplication {


    var touchScreen = TouchScreen.shared

//    override func sendEvent(_ event: UIEvent) {
//
//        if event.type == .touches,
//            touchScreen.redirectSendEvent(event) {
//        }
//        else {
//            super.sendEvent(event)
//        }
//    }
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var didStopActive = false // prevent multiple calls to startActive()
    
    internal func application(_ application: UIApplication,
                             continue userActivity: NSUserActivity,
                             restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let intent = userActivity.interaction?.intent as? DotIntent {

            print("\(#function) A DotIntent: " + MuseIntents.shared.intentStr(intent) )
            return true
        }
        else if userActivity.activityType == "DotIntent",
            let intent = userActivity.interaction?.intent as? DotIntent {

            print("\(#function) B DotIntent: " + MuseIntents.shared.intentStr(intent) )
            return true
        }
        else {
            print("\(#function) C")
            return false
        }

    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let window = self.window {
            window.makeKeyAndVisible()
        }
        return true
    }

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        if let window = self.window {
//            window.rootViewController = OnboardVC()
//            window.makeKeyAndVisible()
//        }
//        return true
//    }

    func applicationWillResignActive(_ application: UIApplication) { //Log("⟳☎︎ \(#function)")
        MainVC.shared?.active?.stopActive()
        didStopActive = true
    }
    func applicationDidBecomeActive(_ application: UIApplication) { //Log("⟳☎︎ \(#function)")
        if didStopActive {
            didStopActive = false
            MainVC.shared?.active?.startActive()
        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) { //Log("⟳☎︎ \(#function)")
    }
    func applicationWillEnterForeground(_ application: UIApplication) { //Log("⟳☎︎ \(#function)")
    }
    func applicationWillTerminate(_ application: UIApplication) { //Log("⟳☎︎ \(#function)")
    }

   
}

