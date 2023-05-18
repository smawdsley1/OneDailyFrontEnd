import SwiftUI

struct MainPageView: View {
    var username: String
    
    var body: some View {
        TabView {
            Text("Welcome, \(username)!")
                .font(.largeTitle)
                .padding()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .background(.blue)

            
            FindMatchView(username: username)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Find Match")
                }

            // PendingMatchView
            MatchView( username: username)
                .tabItem {
                    Image(systemName: "exclamationmark.bubble.fill")
                    Text("Pending Matches")
                }
                
            
            ChatView(username: username)
                .tabItem {
                    Image(systemName: "bubble.right.fill")
                    Text("Chat")
                }
            
            EditAccountView(username: username)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Edit Profile")
                }
        }
        .accentColor(.purple)
    }
}
