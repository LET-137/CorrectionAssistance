//
//  FavoriteButton.swift
//  Sentence-correction
//
//  Created by 津本拓也 on 2024/01/02.
//

import SwiftUI

struct FavoriteButton: View {
    @Binding var isSet: Bool
    
    var body: some View {
        Button(action: {
            isSet.toggle()
        }, label: {
            Label("toggle Favorite",systemImage: isSet ? "star.fill" : "star")
        })
    }
}

