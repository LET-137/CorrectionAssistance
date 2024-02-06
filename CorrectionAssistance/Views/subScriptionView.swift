//
//  subScriptionView.swift
//  Sentence-correction
//
//  Created by 津本拓也 on 2024/01/07.
//

import SwiftUI
import StoreKit
import UIKit
import FirebaseFirestore

struct SubscriptionList:Identifiable {
    var id = UUID()
    var title: String
    var price: String
}

enum BillingErrorType: Identifiable {
    case lordProducts
    case purchase
    case appStoreSync
    case appTransaction
    
    var id: Int {
        switch self{
        case .lordProducts:
            return 1
        case .purchase:
            return 2
        case .appStoreSync:
            return 3
        case .appTransaction:
            return 4
        }
    }
}


struct subScriptionView: View {
    @EnvironmentObject var storeKitManager: StoreKitManager
    
    @EnvironmentObject var userToken: UserToken
    @Binding var isShowSubscription: Bool
    @State var offset = CGFloat.zero
    @State var buyToken: Int = 0
    @State var isShowBillingError = false
    @State var billingErrorCheckAlert: BillingErrorType?
    
    let subscriptionList: [SubscriptionList] = [SubscriptionList(title: "トークン数: 20",price: "￥300"),SubscriptionList(title: "トークン数: 50",price: "￥500"),SubscriptionList(title: "トークン数: 100",price: "￥800")]
    
    var body: some View {
        
        NavigationStack {
            VStack{
                List {
                    Section() {
                        Text("トークンを購入")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.blue)
                            .frame(maxHeight: 50)
                        ForEach(storeKitManager.products) { product in
                            Button {
                                Task {
                                    do {
                                        try await storeKitManager.purchase(product)
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        label: {
                            Text("\(product.displayPrice) - \(product.displayName)")
                        }
                        }
                        .frame(height: 40)
                        .foregroundColor(.primary)
//                        ForEach(Array(subscriptionList.indices), id: \.self) { index in
//                            HStack {
//                                Text("\(subscriptionList[index].title)")
//                                Spacer()
//                                Text(subscriptionList[index].price)
//                            }
//                            .onTapGesture {
//                                storeKitManager.lordProducts()
//                                productsCheck(index: index)
////                                                                    buyProduct(storeManager.products[index])
////                                                                    buyToken = buyTokenNumber(productIDIndex: index)
////                                                                    UserDefaults.standard.set(buyToken,forKey: "buyToken")
//                            }
//                        }
                    }
                    
                    
                    Section() {
                        Text("ユーザー情報")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.blue)
                        HStack {
                            Text("所持トークン数: \(userToken.token.tokens)")
                            //                            Spacer()
                            //                            Text("\(userToken.token.tokens)")
                        }
                        .frame(height: 40)
                        .foregroundColor(.primary)
                    }
                    
                    Section() {
                        HStack{
                            Spacer()
                            Button("キャンセル") {
                                isShowSubscription = false
                            }
                            .foregroundColor(.blue)
                            .contentShape(Rectangle())
                            Spacer()
                        }
                    }
                    Section(){
                        Button("復元") {
                            Task {
                                do {
                                    try await AppStore.sync()
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    }
                }
                .scrollDisabled(true)
            }
            .task {
                Task {
                    do {
                        try await storeKitManager.lordProducts()
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .navigationBarTitle(Text("トークン購入"), displayMode: .inline)
//        .onChange(of: storeManager.buyTokenShow) { oldValue, newValue in
//            if newValue {
//                buyToken = UserDefaults.standard.integer(forKey: "buyToken")
//                userToken.token.tokens = buyTokenCalculation(token: buyToken)
//                UserDefaults.standard.set(userToken.token.tokens, forKey: "NumberOftokens")
//                buyToken = 0
//                UserDefaults.standard.set(buyToken, forKey: "buyToken")
//                guard let data = storeManager.fetchReceipt() else {
//                    print("no")
//                    return
//                }
//                let base64Encode = data.base64EncodedString(options: [])
//                print(base64Encode)
//            }
//        }
       
        
//        .alert(isPresented: $storeManager.purchaseCheck) {
//            Alert(title: Text("エラー"))
//        }
        .alert(item: $billingErrorCheckAlert) { billingErrorCheckAlert in
            switch billingErrorCheckAlert {
            case .lordProducts:
                return Alert(title: Text("商品情報を取得できません"),
                             dismissButton: .default(Text("OK")))
            default:
                return Alert(title: Text("購入エラー"),
                             dismissButton: .default(Text("OK")))
            }
        }
    }
    
    
    
//    private func loadProducts() {
//        StoreManager.shared.requestProducts()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            DispatchQueue.main.async {
//                self.storeManager.products = StoreManager.shared.products
//            }
//        }
//    }
    private func productsCheck(index: Int) {
        guard storeKitManager.products != [] else {
            billingErrorCheck(errorType: "lordProducts")
            
            return
        }
//        buyProduct(storeKitManager.products[index])
        buyToken = buyTokenNumber(productIDIndex: index)
        UserDefaults.standard.set(buyToken,forKey: "buyToken")
    }
    
//    private func buyProduct(_ product: SKProduct) {
//        storeKitManager.purchase(product)
//    }
    
    private func buyTokenNumber(productIDIndex: Int) -> Int {
        switch productIDIndex {
        case 0:
            return 20
        case 1:
            return 50
        case 2:
            return 100
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func buyTokenCalculation(token: Int) -> Int {
        let resultToken = userToken.token.tokens + buyToken
        return resultToken
    }
    
    func billingErrorCheck(errorType: String) {
        if errorType == "lordProducts" {
            billingErrorCheckAlert = .lordProducts
        } else if errorType == "purchase" {
            billingErrorCheckAlert = .purchase
        } else if errorType == "appStoreSync" {
            billingErrorCheckAlert = .appStoreSync
        } else if errorType == "appTransaction" {
            billingErrorCheckAlert = .appTransaction
        }
    }
}
