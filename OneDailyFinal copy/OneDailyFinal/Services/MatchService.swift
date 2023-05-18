import Foundation

// for posting a match
// change we just want the two usernames and the rest should be
// handled serverside

struct MatchRequest: Codable {
    let user1Username: String
    let user2Username: String
}

struct Match: Codable {
    let matchId: Int64?
    let user1Username: String
    let user2Username: String
    let user1Status: Int?
    let user2Status: Int?
    let matchStatus: String?

    enum CodingKeys: String, CodingKey {
        case matchId
        case user1Username
        case user2Username
        case user1Status
        case user2Status
        case matchStatus
    }

    init(user1Username: String, user2Username: String) {
        self.matchId = nil
        self.user1Username = user1Username
        self.user2Username = user2Username
        self.user1Status = nil
        self.user2Status = nil
        self.matchStatus = nil
    }
}



// model for potential matches
struct PotentialMatch: Codable, Identifiable {
    let id: Int64
    let username: String
    let sharedInterests: Int
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case username
        case sharedInterests
    }
}

struct PendingMatch: Codable, Identifiable{
    let id: Int64
    let username: String
    let statusId: Int64
    enum CodingKeys: String, CodingKey {
        case id = "matchId"
        case username
        case statusId
    }
}

// this handles the list
struct MatchWithUsername: Codable, Identifiable {
    let id: Int64
    let user1Username: String
    let user2Username: String
    enum CodingKeys: String, CodingKey {
        case id = "matchId"
        case user1Username
        case user2Username
    }
}

class MatchService {
    // basic stuff for the whole class
    // just the url and session setup
    private let baseUrl = URL(string: "https://10.10.137.10:7285/api/match")!
    private let customURLSessionDelegate = CustomURLSessionDelegate()
    private lazy var session = URLSession(configuration: .default, delegate: customURLSessionDelegate, delegateQueue: nil)
    

    
    func acceptMatch(id: Int, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
            let url = URL(string: "\(baseUrl)/AcceptMatch/\(id)/\(username)")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"

            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if !(200...299).contains(httpResponse.statusCode) {
                        completion(.failure(NSError(domain: "Invalid status code", code: httpResponse.statusCode, userInfo: nil)))
                        return
                    }

                    completion(.success(()))
                }
            }
            task.resume()
        }

        func declineMatch(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
            let url = URL(string: "\(baseUrl)/DeclineMatch/\(id)")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"

            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if !(200...299).contains(httpResponse.statusCode) {
                        completion(.failure(NSError(domain: "Invalid status code", code: httpResponse.statusCode, userInfo: nil)))
                        return
                    }

                    completion(.success(()))
                }
            }
            task.resume()
        }

    
    func postMatch(user1Username: String, user2Username: String, completion: @escaping (Result<Match, Error>) -> Void) {
        let url = URL(string: "\(baseUrl)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let matchRequest = MatchRequest(user1Username: user1Username, user2Username: user2Username)
        let jsonData = try? JSONEncoder().encode(matchRequest)
        request.httpBody = jsonData

           let task = session.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }

               if let httpResponse = response as? HTTPURLResponse, let data = data {
                   if !(200...299).contains(httpResponse.statusCode) {
                       completion(.failure(NSError(domain: "Invalid status code", code: httpResponse.statusCode, userInfo: nil)))
                       return
                   }

                   do {
                       let createdMatch = try JSONDecoder().decode(Match.self, from: data)
                       completion(.success(createdMatch))
                   } catch {
                       completion(.failure(error))
                   }
               }
           }
           task.resume()
       }
    
    
    func fetchPendingMatches(username: String, completion: @escaping (Result<[MatchWithUsername], Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/PendingMatches/\(username)")!

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    do {
                        let pendingMatches = try JSONDecoder().decode([MatchWithUsername].self, from: data)
                        completion(.success(pendingMatches))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NSError(domain: "Invalid status code", code: httpResponse.statusCode, userInfo: nil)))
                }
            }
        }
        task.resume()
    }

    func deleteMatch(username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/DeleteMatch/\(username)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(NSError(domain: "Invalid status code", code: httpResponse.statusCode, userInfo: nil)))
                    return
                }

                completion(.success(()))
            }
        }
        task.resume()
    }

    
    func hasAcceptedMatch(username: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            let url = URL(string: "\(baseUrl)/HasAcceptedMatch/\(username)")!

            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        do {
                            let hasAcceptedMatch = try JSONDecoder().decode(Bool.self, from: data)
                            completion(.success(hasAcceptedMatch))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        completion(.failure(NSError(domain: "Invalid status code", code: httpResponse.statusCode, userInfo: nil)))
                    }
                }
            }
            task.resume()
        }
    
    func fetchPotentialMatches(username: String, completion: @escaping (Result<[PotentialMatch], Error>) -> Void) {
        var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
        urlComponents.path = "/api/match/sharedinterests"
        urlComponents.queryItems = [URLQueryItem(name: "username", value: username)]
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        print(url)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, let data = data {
                let jsonString = String(data: data, encoding: .utf8)
                            print("JSON response: \(jsonString ?? "nil")")

                if !(200...299).contains(httpResponse.statusCode) {
                    do {
                        let errorResponse = try JSONDecoder().decode([String: String].self, from: data)
                        print("Error response: \(errorResponse)")
                    } catch {
                        print("Error decoding error response: \(error.localizedDescription)")
                    }
                    completion(.failure(NSError(domain: "Invalid status code", code: httpResponse.statusCode, userInfo: nil)))
                    return
                }

                do {
                    let potentialMatches = try JSONDecoder().decode([PotentialMatch].self, from: data)
                    completion(.success(potentialMatches))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
