import SwiftUI





struct FindMatchView: View {
    var username: String = ""
    
    @State private var potentialMatches: [PotentialMatch] = []
    private let matchService = MatchService()
    
    func sendMatchRequest(user2Username: String){
        matchService.postMatch(user1Username: self.username, user2Username: user2Username)
        {
            result in switch result {
            case .success(let match):
                print("Match successfully sent: \(match)")
            case .failure(let error):
                print("Error sending match: \(error)")
            }
        }
    }
    
    
    var body: some View {
        NavigationView {

            List(potentialMatches) { match in
                HStack {
                    VStack(alignment: .leading) {
                        Text(match.username)
                            .font(.headline)
                        Text("\(match.sharedInterests) shared interests")
                            .font(.subheadline)
                    }
                    Spacer()
                    Button("Send Match Request") {
                        sendMatchRequest(user2Username: match.username)
                    }
                }
            }
            .navigationTitle("Potential Matches")
            .onAppear {
                matchService.fetchPotentialMatches(username: username) { result in
                    switch result {
                    case .success(let matches):
                        DispatchQueue.main.async {
                            potentialMatches = matches
                        }
                    case .failure(let error):
                        print("Error fetching potential matches: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
