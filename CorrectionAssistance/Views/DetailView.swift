//
//  DetailView.swift
//  Sentence-correction
//
//  Created by 津本拓也 on 2023/12/17.
//

import SwiftUI



struct DetailView: View {
    var textData: TextData
    var textListIndex: Int {
        sheredData.textData.firstIndex(where: { $0.id == textData.id })!
    }
    
    @EnvironmentObject var sheredData: SheredData
    @State var titleChange = false
    @State var titleSave = false
    @State var textGPTListCopy = false
    @State var inputTextCopy = false
    @State var textTitle: String = ""
    @State var favoBoolAlert = false
    
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack {
                    TextField("タイトル", text: $textTitle)
                        .frame(height: 50)
                        .overlay(RoundedRectangle(cornerRadius: 0) .stroke(Color.gray,lineWidth: 1))
                        .padding()
                    HStack {
                        Text("｜添削完了テキスト")
                            .bold()
                        Spacer()
                    }
                    HStack {
                        Text(sheredData.textData[textListIndex].textGPTList)
                            .padding()
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        if textGPTListCopy {
                            Text("添削完了テキストをコピーしました")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(5)
                                .onAppear(perform: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        self.textGPTListCopy = false
                                    }
                                })
                        }
                        
                        Button(action: {
                            UIPasteboard.general.string = textData.textGPTList
                            textGPTListCopy = true
                        }) {
                            Image(systemName: "doc.on.doc")
                                .padding()
                        }
                        
                    }
                    HStack{
                        Text("｜初稿テキスト")
                            .bold()
                        Spacer()
                    }
                    HStack{
                        Text(textData.inputTextList)
                            .padding()
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        if inputTextCopy {
                            Text("初稿テキストをコピーしました")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(5)
                                .onAppear(perform: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        self.inputTextCopy = false
                                    }
                                })
                        }
                        
                        Button(action: {
                            UIPasteboard.general.string = textData.inputTextList
                            inputTextCopy = true
                        }) {
                            Image(systemName: "doc.on.doc")
                                .padding()
                        }
                        
                    }
                }
            }
        }
        .navigationBarItems(trailing: Button(action: {
            titleChange = true
            ContentView.keybordEnd()
        }, label: {
            Image(systemName: "arrow.clockwise")
        }))
        .navigationBarItems(trailing: Button( action: {
            ContentView.keybordEnd()
        }, label: {
            Image(systemName: "keyboard.chevron.compact.down")
        }))
        .navigationBarItems(trailing: Button( action: {
            sheredData.textData[textListIndex].favoBool.toggle()
        }, label: {
            Image(systemName: sheredData.textData[textListIndex].favoBool ? "star.fill" : "star")
        }
                                            ))
        .alert("タイトル変更",isPresented: $titleChange) {
            Button("変更",role: .destructive) {
                
                sheredData.textData[textListIndex].textGPTtitle = textTitle
                titleSave = true
            }
            Button("キャンセル",role: .cancel) { }
        } message: {
            Text("タイトルを変更しますか？")
        }
        
        .alert("変更完了",isPresented: $titleSave) {
            Button("OK",role: .cancel) {
            }}message: {
                Text("タイトルを変更しました")
            }
            .onAppear {
                textTitle = textData.textGPTtitle
            }
    
    }
}
