//
//  FirebaseData.swift
//  CorrectionAssistance
//
//  Created by 津本拓也 on 2024/02/06.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct SubScriptionToken: Identifiable {
    var id: String
    var tokens: [String]
}

class TokenData: ObservableObject {
    @Published var subScriptionTokens = [SubScriptionToken]()

    private var db = Firestore.firestore()

    func fetchData() {
        db.collection("group").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents or error: \(error?.localizedDescription ?? "")")
                return
            }

            self.subScriptionTokens = documents.map { (queryDocumentSnapshot) -> SubScriptionToken in
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                let tokens = data["tokens"] as? [String] ?? []
                return SubScriptionToken(id: id, tokens: tokens)
            }
        }
    }
}
