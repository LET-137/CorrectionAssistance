//
//  ContentView.swift
//  Sentence-correction
//
//  Created by 津本拓也 on 2023/12/10.
//

import SwiftUI
import Combine



enum AlertType:Identifiable {
    case tokenCheck
    case textCheck
    case correctionCheck
    case editerDelete
    
    var id: Int {
        switch self {
        case .tokenCheck:
            return 1
        case .textCheck:
            return 2
        case .correctionCheck:
            return 3
        case .editerDelete:
            return 4
        }
    }
}



struct ContentView: View {
    
    @Binding var textData: [TextData]
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userToken: UserToken
    @EnvironmentObject var modalText: ModalText
    @EnvironmentObject var vertionGPTSwich: VertionGPTSwich
    @State var userInputText: String = ""
    @State var inputTitle: String = ""
    @State var inputText: String = ""
    @State var botText: String = ""
    @State var displayText: String = ""
    @State var GPTResponseBool = false
    @State var contactGpt = false
    @State var correctionCheckAlert = false
    @State var textEditerDelete = false
    @State var showAlertType: AlertType?
    
    let tokenConsumption: Int = 1
    let textLimit: Int = 1500
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack{
            VStack {
                if contactGpt {
                    ProgressView()
                }
                //                HStack {
                //                    Text("　\(vertionGPTSwich.title)").bold()
                //                        .foregroundStyle(.purple)
                ////                    Spacer()
                //                }
                HStack {
                    Text("文字数: \(modalText.userText.inputTextCorrection.count) / 使用トークン: \(vertionGPTSwich.consumptionToken * modalText.userText.resultToken)").bold()
                }
                .foregroundColor(vertionGPTSwich.isGPT ? .purple : .primary)
                TextField("タイトルを入力してください",text: $modalText.userText.textTitle)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(RoundedRectangle(cornerRadius: 0) .stroke(Color.gray,lineWidth: 1))
                    .padding()
                
                TextEditor(text: $modalText.userText.inputTextCorrection)
                    .onChange(of: modalText.userText.inputTextCorrection) { oldValue , newValue in
                        modalText.userText.resultToken = textNumbersCalculation(text: newValue)
                        if modalText.userText.inputTextCorrection.count > textLimit {
                            modalText.userText.inputTextCorrection = String(modalText.userText.inputTextCorrection.prefix(textLimit))
                        }
                    }
                
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                //                    .edgesIgnoringSafeArea(.all)
                    .overlay(alignment: .topLeading) {
                        if modalText.userText.inputTextCorrection.isEmpty {
                            Text("添削する文章を入力してください\n500文字ごとに\(vertionGPTSwich.consumptionToken)トークンを消費します\n最大入力文字数は\(textLimit)文字です。")
                                .allowsHitTesting(false)
                                .foregroundColor(Color(uiColor: .placeholderText))
                                .padding(8)
                        }
                    }
            }
            .foregroundColor(Color.primary)
            //            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            .navigationDestination(isPresented: $GPTResponseBool) {
                GPTResponseView(botText: $botText)
            }
            
            .navigationBarTitle("\(vertionGPTSwich.mainTitle)", displayMode: .inline)
            
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                HStack {
                    Image(systemName: "chevron.backward").bold()
                    Text("戻る")
                }
            }))
            
            .navigationBarItems(trailing: Button(action: {
                textEditerDelete = false
                checkConditions(textEditerDelete: textEditerDelete)
            }
                                                ){
                Text("添削")
            })
            .navigationBarItems(trailing: Button( action: {
                ContentView.keybordEnd()
            }, label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .scaleEffect(1.0)
                //                    .padding(.horizontal, -10)
            }))
            .navigationBarItems(trailing: Button(action: {
                textEditerDelete = true
                checkConditions(textEditerDelete: textEditerDelete)
            }, label: {
                Image(systemName: "eraser.line.dashed")
            }))
        }
        
        .alert(item: $showAlertType) { alertType in
            switch alertType {
            case .tokenCheck:
                return Alert(title: Text("トークン数確認"),
                             message: Text("トークンが不足しています"),
                             dismissButton: .default(Text("OK")))
                
            case .textCheck:
                return Alert(title: Text("確認"),
                             message: Text("文章が入力されていません"),
                             dismissButton: .default(Text("OK")))
                
            case .correctionCheck:
                return Alert(title: Text("『 \(vertionGPTSwich.consumptionToken * modalText.userText.resultToken) 』トークンを消費して添削を実行しますか？"),
                             message: Text("所持トークン: \(userToken.token.tokens)"),
                             primaryButton: .destructive(Text("実行")) {
                    if modalText.userText.textTitle == "" {
                        inputTitle = "No title"
                    } else {
                        inputTitle = modalText.userText.textTitle
                    }
                    userInputText = modalText.userText.inputTextCorrection
                    inputText =  "Please revise the text \(modalText.userText.inputTextCorrection) for business use. A response with only the revised content is required; no other information is necessary. Ensure the response is in Japanese."
                    //                    inputText =  "ビジネスで使う文章として「\(modalText.userText.inputTextCorrection)」を添削して。返答は添削した内容のみでよい。それ以外はいらない。"
                    contactGpt = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        
                        Task {
                            botText = try await
                            APIRequester().CorrectionGPT(question: inputText)
                            if !botText.isEmpty {
                                let cellsColorBool = vertionGPTSwich.isGPT
                                let newData = TextData(textGPTtitle: inputTitle, textGPTList: botText, inputTextList: userInputText, date: Date(), favoBool: false, cellColor: cellsColorBool)
                                
                                textData.insert(newData, at: 0)
                                userToken.token.tokens = tokenCalculation(item: userToken.token.tokens)
                                UserDefaults.standard.set(userToken.token.tokens,
                                                          forKey: "NumberOftokens")
                                modalText.userText.textTitle = ""
                                modalText.userText.inputTextCorrection = ""
                                GPTResponseBool.toggle()
                            }
                        }
                    }
                },secondaryButton: .cancel())
                
            case .editerDelete:
                return Alert(title: Text("テキスト削除"), message: Text("入力中の文章をすべて削除しますか？"), primaryButton: .destructive( Text("削除")) {
                    modalText.userText.inputTextCorrection = ""
                }, secondaryButton: .cancel(Text("キャンセル")))
            }
        }
        .disabled(contactGpt)
    }
    
    func checkConditions(textEditerDelete: Bool) {
        if textEditerDelete {
            showAlertType = .editerDelete
        } else if userToken.token.tokens < vertionGPTSwich.consumptionToken  {
            showAlertType = .tokenCheck
        } else if modalText.userText.inputTextCorrection == "" {
            showAlertType = .textCheck
        } else {
            showAlertType = .correctionCheck
        }
    }
    
    func tokenCalculation(item: Int) -> Int{
        let result = item - vertionGPTSwich.consumptionToken * modalText.userText.resultToken
        return result
    }
    
    func textNumbersCalculation(text: String) -> Int {
        return Int((floor(Double((modalText.userText.inputTextCorrection.count + 499))) / 500))
    }
    
    
    
    class APIRequester: ObservableObject {
        var vertionGPTSwich = VertionGPTSwich()
        
        private struct RequestBody: Encodable {
            let model: String
            let messages: [Message]
            let temperature: Float
            
            struct Message: Encodable {
                let role: String
                let content: String
            }
        }
        
        private struct APIResponse: Decodable {
            let choices:  [Choice]
            
            struct Choice: Decodable {
                let message: Message
                
                struct Message: Decodable {
                    let content:String
                }
            }
        }
        
        enum Error: Swift.Error {
            case invalidResponse
        }
        
        func CorrectionGPT(question: String) async throws -> String {
            var request = URLRequest(
                url: URL(string: "https://api.openai.com/v1/chat/completions")!
            )
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(openKey)", forHTTPHeaderField: "Authorization")
            request.timeoutInterval = 180
            request.httpBody = try JSONEncoder().encode(
                //                RequestBody(model: "gpt-3.5-turbo", messages: [RequestBody.Message(
                //                RequestBody(model: "gpt-4-1106-preview", messages: [RequestBody.Message(
                RequestBody(model: "\(vertionGPTSwich.model)", messages: [RequestBody.Message(
                    role: "user", content: question)], temperature: 0.7)
            )
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(APIResponse.self, from: data)
            guard let content = response.choices.first?.message.content else {
                throw Error.invalidResponse }
            return content
        }
    }
}


