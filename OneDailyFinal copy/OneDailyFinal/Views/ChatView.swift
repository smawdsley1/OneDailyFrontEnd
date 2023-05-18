import SwiftUI
import Combine

struct ClientMessage: Codable {
    var conversationId: Int
    var userId: Int
    var content: String
    var contentType: String

    enum CodingKeys: String, CodingKey {
        case conversationId = "conversationId"
        case userId = "userId"
        case content = "content"
        case contentType = "contentType"
    }
}

struct DisplayMessage: Identifiable {
    var id = UUID()
    var content: String
    var color: Color
}

struct ChatView: View {
    var username: String
    @State private var message = ""
    @State private var messages: [DisplayMessage] = []
    private var chatService = ChatService()
    private var userController = UserController()
    @State private var userId: Int = 0
    @State private var conversationId: Int = 0
    private let matchService = MatchService()
    @State private var matchExists = false

    public init(username: String) {
        self.username = username
    }
    
    var body: some View {
        VStack {
            List(messages) { message in
                Text(message.content)
                    .foregroundColor(message.color)
            }
            .onAppear {
                userController.getUserIdByUsername(username: username) { result in
                    switch result {
                    case .success(let fetchedUserId):
                        self.userId = Int(fetchedUserId)
                    case .failure(let error):
                        print("Error getting user id: \(error)")
                    }
                }
                
                chatService.getConversationId(username: username) { result in
                    switch result {
                    case .success(let fetchedConversationId):
                        self.conversationId = Int(fetchedConversationId)
                    case .failure(let error):
                        print("Error getting conversation id: \(error)")
                    }
                }
                
                loadMessages()
            }
            TextField("Enter your message...", text: $message)
                .padding()
            
            Button(action: {
                let messageObject = ClientMessage(conversationId: self.conversationId, userId: self.userId, content: self.message, contentType: "text")
                self.chatService.postMessage(messageObject) { result in
                    switch result {
                    case .success(let response):
                        print(response)
                        self.loadMessages()
                        self.message = ""
                    case .failure(let error):
                        print("Error posting message: \(error)")
                    }
                }
            }) {
                Text("Send")
            }

        }
    }
    
    private func loadMessages() {
        chatService.loadMessages(username: username) { result in
            switch result {
            case .success(let loadedMessages):
                messages = loadedMessages.map { message in
                    DisplayMessage(content: message.content, color: message.userId == self.userId ? .blue : .red)
                }
            case .failure(let error):
                print("Error loading messages: \(error)")
            }
        }
    }
    
    private func checkForMatchExistence(for user: String) {
        matchService.hasAcceptedMatch(username: user) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let hasAcceptedMatch):
                    self.matchExists = hasAcceptedMatch
                case .failure(let error):
                    print("Failed to check for accepted match: \(error)")
                }
            }
        }
    }
}
