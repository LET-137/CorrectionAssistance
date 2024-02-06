//
//  GPTResponseView.swift
//  Sentence-correction
//
//  Created by 津本拓也 on 2023/12/23.
//

import SwiftUI


struct GPTResponseView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var botText: String
    @State var displayText: String = ""
    @State private var isTextComplete: Bool = false
    @State var copyFlg = false
    @State var isDisabled = true
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack {
                    Text(displayText)
                        .onReceive(timer, perform: { _ in
                            updateText()
                        })
                    HStack {
                        Spacer()
                        if copyFlg {
                            Text("コピーしました")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(5)
                                .onAppear(perform: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        self.copyFlg = false
                                    }
                                })
                        }
                        
                        if isTextComplete {
                            Button(action: {
                                UIPasteboard.general.string = displayText
                                copyFlg = true
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .padding()
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack {
                Image(systemName: "chevron.backward").bold()
                Text("戻る")
            }
        }))
        .disabled(isDisabled)
    }
    private func updateText() {
        if botText.isEmpty {
            isTextComplete = true
            isDisabled = false
            return
        }
        
        let nextTextIndex = botText.index(botText.startIndex, offsetBy: 1)
        displayText += String(botText[..<nextTextIndex])
        botText.removeSubrange(..<nextTextIndex)
    }
}


