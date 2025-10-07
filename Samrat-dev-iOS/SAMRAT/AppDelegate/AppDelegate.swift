import UIKit
import CoreData
import OneSignal
import IQKeyboardManager
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate,OSPermissionObserver, OSSubscriptionObserver,UNUserNotificationCenterDelegate, MessagingDelegate
{
    
    var window: UIWindow?
    var isFromCalender = false
    var isNavigateHome = false
    var singer_booking_id = ""
    var isFromBackPaymentScreen = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        // Initialize sign-in
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        //ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
        IQKeyboardManager.shared().isEnabled = true
        // Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        setNotificaationTag()
        // OneSignal initialization
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            print("Received Notification: ", notification!.payload.notificationID!)
            print("launchURL: ", notification?.payload.launchURL ?? "No Launch Url")
            print("content_available = \(notification?.payload.contentAvailable ?? false)")
            
            
            let myBookingVC = MyBookingVC()
            if let navigation = UIApplication.shared.windows.first?.rootViewController
                as? UINavigationController
            {
                self.isNavigateHome = true
                navigation.pushViewController(myBookingVC, animated: true)
            }
            
            
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            print("Message: ", payload!.body!)
            print("badge number: ", payload?.badge ?? 0)
            print("notification sound: ", payload?.sound ?? "No sound")
            
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true, ]
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: oneSignalId, handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
 
        OneSignal.getUserDevice()?.getUserId()
        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        
        OneSignal.add(self as OSPermissionObserver)
        
        OneSignal.add(self as OSSubscriptionObserver)
        
        devicePushToken = OneSignal.getUserDevice()?.getUserId() ?? ""
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: BASE_COLOR], for: .selected)
                
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        UITabBar.appearance().backgroundColor = UIColor.black
        
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        
        if UserDefaults.standard.bool(forKey: "isAlreadyLaunch") {
            setSemantricFlow()
        }
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in

            }
        }
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions:
            launchOptions)
        
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                //self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
            }
        }
        
        setupPush()
        
        registerForRemoteNotification()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {

        
    }
    
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        print("PermissionStateChanges: ", stateChanges!)
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        print("Subscribed for OneSignal push notifications!")
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let isHandleFB = ApplicationDelegate.shared.application(app, open: url, options: options)

        let isHandleGoogle = GIDSignIn.sharedInstance().handle(url)

      return (isHandleGoogle || isHandleFB)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
       // devicePushToken = deviceTokenString
        print(deviceTokenString)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        devicePushToken = fcmToken ?? ""
    }

    func setupPush()
    {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Handle user allowing / declining notification permission. Example:
            if (granted) {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            } else {
                print("User declined notification permissions")
            }
        }
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            // UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            // center.delegate  = self
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                if (granted)
                {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    
                }
            }
        }
        else{
            
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
            
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            #if !(arch(i386) || arch(x86_64))
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings: UNNotificationSettings) -> Void  in
                        guard settings.authorizationStatus == UNAuthorizationStatus.authorized else {
                            return
                        }
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    })
                }
            }
            #endif
        } else {
            #if !(arch(i386) || arch(x86_64))
            let notificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
            #endif
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        
        print("User declined notification didReceive")
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {

        print("User declined notification didReceiveRemoteNotification")
        print(userInfo)
        let state = UIApplication.shared.applicationState
        
//        let myBookingVC = MyBookingVC()
//         if let navigation = self.window?.rootViewController as? UINavigationController
//        {
//            navigation.pushViewController(myBookingVC, animated: true)
//        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let userInfo = notification.request.content.userInfo
        
        print(userInfo)
        
        completionHandler([.alert, .badge, .sound])
    }
  
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
