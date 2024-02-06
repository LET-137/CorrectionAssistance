
import Foundation
import SwiftUI
import Combine




class UserToken: ObservableObject {
    @Published var token: Token
    init(token: Token) {
        self.token = token
    }
}
struct Token {
    var tokens: Int = UserDefaults.standard.integer(forKey: "NumberOftokens")
}



class VertionGPTSwich: ObservableObject {
    @Published var isGPT: Bool = UserDefaults.standard.bool(forKey: "vertionGPTSwich")
    var model: String {
        return isGPT ? "gpt-4-1106-preview" : "gpt-3.5-turbo"
    }
//    var title: String {
//        return isGPT ? "高性能AI機能を使用中" : ""
//    }
    var vertionStr: String {
        return isGPT ? "gpt-4-1106-preview" : "gpt-3.5-turbo"
    }
    var consumptionToken: Int {
        return isGPT ? 2 : 1
    }
    var mainTitle: String {
        return isGPT ? "高性能AI" : "通常AI"
    }
}



enum GPTType: Identifiable {
    case gpt3
    case gpt4
    
    var id: Int {
        switch self {
        case .gpt3:
            return 1
        case .gpt4:
            return 2
        }
    }
}
class StrGPTVertion: ObservableObject {
    @Published var choiceGPT: GPTType
    init(choiceGPT: GPTType) {
        self.choiceGPT = choiceGPT
    }
}




class DisplayToken: ObservableObject {
    @Published var displayTokenToggle: DisplayTokenToggle
    
    init(displayTokenToggle: DisplayTokenToggle) {
        self.displayTokenToggle = displayTokenToggle
    }
}
struct DisplayTokenToggle {
    var TokenToggle: Bool = UserDefaults.standard.bool(forKey: "displayToken")
}



class SheredData: ObservableObject {
//    @Published var favoBool = false
    @Published var textData: [TextData] = DataManager.shared.loadFromFileSystem()
    
    var favoList: [TextData] {
        textData.filter { $0.favoBool}
    }
}
struct TextData: Codable,Identifiable {
    var id = UUID()
    var textGPTtitle: String = ""
    var textGPTList: String = ""
    var inputTextList: String = ""
    var date: Date = Date()
    var favoBool: Bool = false
    var cellColor: Bool = false
}



class ModalText: ObservableObject {
    @Published var userText: UserText
    init(userText: UserText) {
        self.userText = userText
    }
}
struct UserText {
    var textTitle: String = ""
    var inputTextCorrection: String = ""
    var resultToken: Int = 0
}



class MainToggle: ObservableObject {
    @Published var mainTitle: MainTitle
    
    init(mainTitle: MainTitle) {
        self.mainTitle = mainTitle
    }
}
struct MainTitle {
    var isShowHomeFavo: Bool = true
    var titleText: String {
        return isShowHomeFavo ? "リスト一覧" : "お気に入り"
    }
    var barFavoName: String {
        return isShowHomeFavo ?  "star" : "star.fill"
    }
    var barListName: String {
        return isShowHomeFavo ? "list.bullet.clipboard.fill" : "list.bullet.clipboard"
    }
    
}

//class SubscriptionModalView: ObservableObject {
//    @Published var isShowSubscription = false
//}

class DataManager {
    static let shared = DataManager()
    
    
func saveToFileSystem(textData: [TextData], idsToSave: [UUID]? = nil) {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("TextList.txt")
            
            do {
                let dataToSave: [TextData]
                if let ids = idsToSave {
                                // idsに基づいてフィルタリング
                                dataToSave = textData.filter { ids.contains($0.id) }
                            } else {
                                // idsが指定されていない場合は全データを保存
                                dataToSave = textData
                            }
                
                let data = try JSONEncoder().encode(dataToSave)
                try data.write(to: fileURL)
            } catch {
                print("Error saving to file system: \(error)")
            }
        }
    }
  
    func loadFromFileSystem() -> [TextData] {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("TextList.txt")
            
            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let loadedTextData = try JSONDecoder().decode([TextData].self, from: data)
                    return loadedTextData
                } catch {
                    print("Error loading from file system: \(error)")
                }
            } else {
                print("File does not exist at path: \(fileURL.path)")
            }
        }
        return[]
    }
    
    func initializaSave(textData: [TextData]) {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("TextList.txt")
            
            do {
                let dataToSave: [TextData]
                dataToSave = textData
                let data = try JSONEncoder().encode(dataToSave)
                try data.write(to: fileURL)
            } catch {
                print("Error clearing file: \(error)")
            }
        }

        
        
    }
    
}

    

extension View {
    static func keybordEnd() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

