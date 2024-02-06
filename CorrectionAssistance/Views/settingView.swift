

import SwiftUI
import StoreKit
import UIKit


struct ListItem {
    var id: Int
    var title: String
}

struct settingView: View {
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 1.0, alpha: 1.0).withAlphaComponent(1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            settingListView()
        }
        .scrollContentBackground(.hidden)
        //        .tint(.white)
        
    }
    
    
    struct settingListView: View {
        let settingItems: [ListItem] = [ListItem(id: 1, title: "トークンを購入")]
        let privacyListItems: [ListItem] = [ListItem(id: 1, title: "プライバシーポリシー"),ListItem(id: 2, title: "お問い合わせ"),ListItem(id: 3, title: "ヘルプ")]
        let dataListItems: [ListItem] = [ListItem(id: 1, title: "リストを全て削除")]
        let testList: [ListItem] = [ListItem(id: 1, title: "test")]
        
        let harfTest = ["a","b"]
        let harfTest2 = ["c"]
        
        @State var testToggle = false
        let allDataInitialization: TextData = TextData()
        @State var dataDeleteAlert = false
        @State var dataDeleteExecution = false
        @State var isShowSetting = false
        @State var isShowSubscription = false

        @Environment(\.presentationMode) var presentationMode
        @EnvironmentObject var sheredData: SheredData
        @EnvironmentObject var displayToken: DisplayToken
        @EnvironmentObject var userToken: UserToken
        @EnvironmentObject var vertionGPTSwich: VertionGPTSwich
//        @EnvironmentObject var storeManager: StoreManager
        
        
        var body: some View {
            List {
                Section(header: Text("トークン")) {
                    Toggle(isOn: $displayToken.displayTokenToggle.TokenToggle) {
                        
                        Text("トークン数を常に表示")
                    }
                    .onChange(of: displayToken.displayTokenToggle.TokenToggle) { oldValue,
                        newValue in
                        UserDefaults.standard.set(newValue, forKey: "displayToken")
                    }
                    HStack{
                        Text("残りトークン数")
                        Spacer()
                        Text("\(userToken.token.tokens)")
                            .foregroundStyle(Color.gray)
                    }
                    ForEach(settingItems, id: \.id) { item in
                        HStack{
                            Text(item.title)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            destinationToggle(item: item.title)
                        }
                        
                    }
//                    .navigationDestination(isPresented: $isShowSetting) {
//                        settingListView2()
//                    }
//
                    .fullScreenCover(isPresented: $isShowSubscription) {
                        subScriptionView(isShowSubscription: $isShowSubscription)
//                            .presentationBackground(Color.clear)
                        
                    }
                   
                }
                
                Section(header: Text("AI機能")) {
                    Toggle(isOn: $vertionGPTSwich.isGPT) {
                        Text("高性能AI機能を使用する")
                            .foregroundColor(.purple)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                        Text("スイッチをオンにすると、GPT-4が使用可能となり、トークンの消費量は通常の2倍に増加します。\n通常よりも応答速度が落ちます。長文を入力すると、処理時間が長引くことに注意してください。")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                }
                .onChange(of: vertionGPTSwich.isGPT) { oldValue, newValue in
                    UserDefaults.standard.set(newValue, forKey: "vertionGPTSwich")
                }
                
                Section(header: Text("データ")) {
                    ForEach(dataListItems,id: \.id) { item in
                        HStack {
                            
                            Text(item.title)
                                .foregroundStyle(Color.red)
                                .alert(isPresented: $dataDeleteAlert) {
                                    Alert(title: Text("リストをすべて削除"), message: Text("リストをすべて削除しますか？"), primaryButton: .default(Text("削除")){
                                        dataDeleteExecution = true
                                        allDataDelete(delete: dataDeleteExecution)
                                    }, secondaryButton: .cancel(Text("キャンセル")))
                                }
                            Text("リスト一覧、お気に入りに保存されているデータを削除します")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            //                                .alert(isPresented: $dataDeleteExecution) {
                            //                                    Alert(title: Text("削除完了"), message: "リストをすべて削除しました", dismissButton: Text("OK"))
                            //                                }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dataDeleteAlert = true
                        }
                    }
                }
                
                Section(header: Text("プライバシー")) {
                    ForEach(privacyListItems, id: \.id) { item in
                        HStack{
                            destinationLink(for: item.title)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
            }
            .navigationBarTitle("設定", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("完了").bold()
                    .foregroundStyle(Color.white)
            }))
            
            .overlay(
                Group {
                    if isShowSubscription {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                self.isShowSubscription = false
                            }
                    }
                }
            )
           
        }
        
        func allDataDelete(delete: Bool) {
            if delete {
                sheredData.textData = []
                DataManager.shared.initializaSave(textData: sheredData.textData)
            }
        }
        
        
        func destinationToggle(item: String) {
            switch item {
            case "設定":
                isShowSetting = true
            case "トークンを購入":
                isShowSubscription = true
            default:
                break
            }
        }
        
        @ViewBuilder
        func destinationLink(for item: String) -> some View {
            switch item {
            case "プライバシーポリシー":
                Link(destination: URL(string: "https://let-137.github.io/privacy_policy_Sentence_correction/")!) {
                    Text(item)
                }
            case "お問い合わせ":
                Link(destination: URL(string: "https://let-137.github.io/Support_page_Sentence_correction/")!) {
                    Text(item)
                }
            case "ヘルプ":
                Link(destination: URL(string: "https://let-137.github.io/Help_Sentence_correction/")!) {
                    Text(item)
                }
            default:
                EmptyView()
            }
        }
        
    }
    
        
}
