

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
   
      if #available(iOS 14.0, *) {
          let providerFactory = AppCheckDebugProviderFactory()
          AppCheck.setAppCheckProviderFactory(providerFactory)
          } else {
              AppCheck.setAppCheckProviderFactory(DeviceCheckProviderFactory())
          }
      FirebaseApp.configure()
    return true
  }
}


@main
struct CorrectionAssistanceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var sheredData = SheredData()
    @State private var mainToggle = MainToggle(mainTitle: MainTitle())
    @State private var userToken = UserToken(token: Token())
    @State private var displayToken = DisplayToken(displayTokenToggle: DisplayTokenToggle())
    @State private var modalText = ModalText(userText: UserText())
    @State private var storeKitManager = StoreKitManager()
    @State private var tokenData = TokenData()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            topPageView()
                .environmentObject(sheredData)
                .environmentObject(mainToggle)
                .environmentObject(userToken)
                .environmentObject(displayToken)
                .environmentObject(modalText)
                .environmentObject(VertionGPTSwich())
                .environmentObject(StrGPTVertion(choiceGPT: .gpt3))
                .environmentObject(storeKitManager)
                .environmentObject(tokenData)
                .task {
                    await storeKitManager.upDatePurchaseProducts()
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                DataManager.shared.saveToFileSystem(textData: sheredData.textData)
            }
            
        }
    }
}
