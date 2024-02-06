
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

