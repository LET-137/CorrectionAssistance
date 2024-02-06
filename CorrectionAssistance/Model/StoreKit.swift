//
//  StoreKit2.swift
//  Sentence-correction
//
//  Created by 津本拓也 on 2024/01/29.
//

import Foundation
import SwiftUI
import StoreKit
import FirebaseFirestore

class StoreKitManager: ObservableObject {
//    let db = Firestore.firestore()
//    商品IDを取得
//    var productIDs: [String] = [
//        "SubscriptionToken100",
//        "SubscriptionToken60",
//        "SubscriptionToken20"
//    ]
    var productIDs: [String] = []
    
    @Published var products: [Product] = []
    @Published private(set) var purchaseProductIDs = Set<String>()
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = observeTransactionUpdates()
    }
    deinit {
        updates?.cancel()
    }
    
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                await self.upDatePurchaseProducts()
            }
        }
    }
    
    func tes() {
        let db = Firestore.firestore()
            db.collection("subscriptionTokens").getDocuments() { querySnapshot, err in
                if let err = err {
                    print(err)
                } else {
                    for document in querySnapshot!.documents {
                        guard let token = document.get("tokens") as? [String] else {
                            continue
                        }
                        self.productIDs = token
                    }
                }
        }
    }
    
    
//    商品情報をロード
    func lordProducts() async throws {
        tes()
        let furchedProduts = try await Product.products(for: productIDs)
        DispatchQueue.main.async {
            self.products = furchedProduts
            let sortedProducts = self.products.sorted() { $0.displayPrice < $1.displayPrice }
            self.products = sortedProducts
        }
    }
    
//    購入処理
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(Transaction)):
            
            await Transaction.finish()
            await self.upDatePurchaseProducts()
            
        case let .success(.unverified(_, error)):
            break
        case .pending:
            break
        case .userCancelled:
            break
        @unknown default:
            break
        }
    }
    

    func upDatePurchaseProducts() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                Task {
                    for await result in Transaction.currentEntitlements {
                        guard case .verified(let transaction) = result else {
                            continue
                        }
                        
                        if transaction.revocationDate == nil {
                            self.purchaseProductIDs.insert(transaction.productID)
                        } else {
                            self.purchaseProductIDs.remove(transaction.productID)
                        }
                    }
                    continuation.resume()
                }
            }
        }
    }
}
