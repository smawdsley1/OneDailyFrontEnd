import Foundation
import SwiftUI
import Combine

struct MatchView: View {
    var username: String
    @State private var pendingMatches = [MatchWithUsername]() // stores pending matches
    @State private var matchExists = false // if the user is already in a match
    private let matchService = MatchService()

    var body: some View {
        ScrollView {
            VStack {
                if matchExists { // Display match already exists message if matchExists is true
                    Text("Match already exists")
                    Button(action: {
                        matchService.deleteMatch(username: username) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success:
                                    print("Deleted match for \(username)")
                                    self.matchExists = false // Update matchExists to false after deleting
                                    loadPendingMatches(for: username) // Reload pending matches after deleting
                                case .failure(let error):
                                    print("Failed to delete match: \(error)")
                                }
                            }
                        }
                    }) {
                        Text("Try Someone New")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    if pendingMatches.isEmpty{
                        Text("No Pending Matches")
                    }
                    ForEach(pendingMatches, id: \.id) { match in
                        HStack {
                            Text("Match with \(match.user1Username)")
                            Spacer()
                            Button(action: {
                                matchService.acceptMatch(id: Int(match.id), username: username) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success:
                                            print("Accepted match \(match.id)")
                                            loadPendingMatches(for: username) // reload pending matches after accepting
                                        case .failure(let error):
                                            print("something bad happened, the server left the following note: \(error)")
                                        }
                                    }
                                }
                            }) {
                                Text("Accept")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Button(action: {
                                matchService.declineMatch(id: Int(match.id)) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success:
                                            print("Declined match \(match.id)")
                                            loadPendingMatches(for: username) // reload pending matches after declining
                                        case .failure(let error):
                                            print("Failed to decline match: \(error)")
                                        }
                                    }
                                }
                            }) {
                                Text("Decline")
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            checkForMatchExistence(for: username) // Check if a match already exists for the user
            loadPendingMatches(for: username)
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
    
    private func loadPendingMatches(for user: String) {
        matchService.fetchPendingMatches(username: user) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let matches):
                    self.pendingMatches = matches
                    self.printPendingMatches()
                case .failure(let error):
                    print("Failed to load pending matches: \(error)")
                    self.pendingMatches = []
                }
            }
        }
    }
    
    private func printPendingMatches() {
        print("Pending Matches:")
        for match in pendingMatches {
            print("Match ID: \(match.id)")
            print("Username: \(match.user1Username)")
            print("----------------------")
        }
    }
}
