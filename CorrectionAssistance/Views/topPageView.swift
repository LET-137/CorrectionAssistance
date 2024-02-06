
import SwiftUI


struct topPageView: View {
    
    @State var contentViewAction: Bool = false
    @State var settingViewAction: Bool = false
    @State var isLinkActive: Bool = false
    @State var isModalSetting: Bool = false
    @State var selectedItem: TextData = TextData()
    @EnvironmentObject var sheredData: SheredData
    @EnvironmentObject var mainToggle: MainToggle
    @EnvironmentObject var userToken: UserToken
    @EnvironmentObject var displayToken: DisplayToken
    @EnvironmentObject var storeKitManager: StoreKitManager
    
    var testList: [TextData] = [TextData(textGPTtitle: "1",textGPTList: "testGPT",inputTextList: "test"),TextData(textGPTtitle: "2",textGPTList: "testGPT",inputTextList: "test"),TextData(textGPTtitle: "3",textGPTList: "testGPT",inputTextList: "test"),TextData(textGPTtitle: "4",textGPTList: "testGPT",inputTextList: "test"),TextData(textGPTtitle: "5",textGPTList: "testGPT",inputTextList: "test")]
    
    var currentList: [TextData] {
        mainToggle.mainTitle.isShowHomeFavo ? sheredData.textData : sheredData.favoList
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                
                NavigationStack {
                    VStack{
                        HStack{
                            Button("token +") {
                                userToken.token.tokens += 9
                            }
                            
                            Button("test") {
                                DataManager.shared.saveToFileSystem(textData: testList)
                                sheredData.textData = DataManager.shared.loadFromFileSystem()
                            }
                            
                            Button("token -") {
                                userToken.token.tokens -= 9
                            }
                        }
                        List {
                            ForEach(currentList) { textData in
                                
                                if let index = currentList.firstIndex(where: { $0.id == textData.id }) {
                                    HStack{
                                        NavigationCellView(textData: textData)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 5, alignment: .leading)
                                    .padding()
                                    .foregroundStyle(textData.cellColor ? Color.purple : Color .primary)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        self.selectedItem = textData
                                        isLinkActive = true
                                    }
                                }
                            }
                            .onDelete(perform: deleteItems)
                            
                            
                        }
                        .scrollContentBackground(.hidden)
                    }
                    
                    HStack{
                        Spacer()
                        Button(action: {
                            mainToggle.mainTitle.isShowHomeFavo = true
                        }, label: {
                            VStack{
                                Image(systemName: mainToggle.mainTitle.barListName)
                                    .foregroundColor(.blue)
                                    .bold()
                                Text("リスト一覧")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.blue)
                            }
                        })
                        Spacer()
                        Button(action: {
                            mainToggle.mainTitle.isShowHomeFavo = false
                        }, label: {
                            VStack{
                                Image(systemName: mainToggle.mainTitle.barFavoName)
                                    .foregroundColor(.blue)
                                    .bold()
                                Text("お気に入り")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.blue)
                            }
                        })
                        Spacer()
                    }
                    .frame(minWidth: UIScreen.main.bounds.width)
                    .padding()
                    .edgesIgnoringSafeArea(.bottom)
                    
                    
                    .navigationBarTitle("\(mainToggle.mainTitle.titleText)",displayMode: .inline)
                    .navigationBarItems(trailing: Button(action: {
                        contentViewAction.toggle()
                    }, label: {
                        Image(systemName: "square.and.pencil"
                        )} ))
                    
                    .sheet(isPresented: $settingViewAction, content: {
                        settingView().environmentObject(storeKitManager)
                    })
                    .navigationBarItems(leading: Button(action: {
                        settingViewAction.toggle()
                    }, label: {
                        Image(systemName: "gearshape")
                    }))
                    .navigationDestination(isPresented: $contentViewAction) {
                        ContentView(textData: $sheredData.textData)
                    }
                    .navigationDestination(isPresented: $isLinkActive) {
                        DetailView(textData: selectedItem)
                    }
                }
                
                if displayToken.displayTokenToggle.TokenToggle {
                    Text("トークン: \(userToken.token.tokens)").bold()
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                        .offset(y: -50)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        
    }
    
    func deleteItems(at offsets: IndexSet) {
        let idsToDelete = offsets.map { currentList[$0].id }
        sheredData.textData.removeAll { item in
            idsToDelete.contains(item.id)}
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        return formatter
    }()
    
    
    struct NavigationCellView: View {
        var textData: TextData
        
        var body: some View {
            
                VStack {
                    HStack {
                        Text(textData.textGPTtitle).bold()
                        Spacer()
                                            }
                    HStack {
                        Text(textData.date, formatter: dateFormatter)
                            .foregroundStyle(.gray)
                            .font(.system(size: 10))
                        Spacer()
                    }
                }
                
                Spacer()
                if textData.favoBool {
                    Image(systemName: "star.fill")
                        .foregroundColor(.blue)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            
        }
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/M/d"
            return formatter
        }()
    }
}
