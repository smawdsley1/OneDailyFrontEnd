import Foundation

struct SignInUser: Codable {
    let username: String
    let password: String
}

struct SignUpUser: Codable {
    let username: String
    let passwordHash: String
    let email: String
}

struct UpdateUser: Codable{
    let UserId: Int64
    let FirstName: String?
    let LastName: String?
    let Username: String?
    let Email: String?
    let DateOfBirth: String?
    let Bio: String?
    let ProfilePicture: String?
    
    enum CodingKeys: String, CodingKey {
           case UserId = "userId"
           case FirstName = "firstName"
           case LastName = "lastName"
           case Username = "username"
           case Email = "email"
           case DateOfBirth = "dateOfBirth"
           case Bio = "bio"
           case ProfilePicture = "profilePicture"
       }
}

enum UserError: Error {
    case invalidData
    case networkError
    case usernameUnavailable
    
    var errorDescription: String? {
        switch self {
        case .usernameUnavailable:
            return "Username is unavailable."
        default:
            return nil
        }
    }
}

class CustomURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

class UserController {
    private let baseUrl = URL(string: "https://10.10.137.10:7285/api/user/")!
    private let customURLSessionDelegate = CustomURLSessionDelegate()
    private lazy var session = URLSession(configuration: .default, delegate: customURLSessionDelegate, delegateQueue: nil)
    
    func signInUser(username: String, password: String, completion: @escaping (Result<Void, UserError>) -> Void) {
        let user = SignInUser(username: username, password: password)
        guard let data = try? JSONEncoder().encode(user) else {
            completion(.failure(.invalidData))
            return
        }
        var request = URLRequest(url: baseUrl.appendingPathComponent("signin")) 
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error signing in user: \(error.localizedDescription)")
                completion(.failure(.networkError))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Error response: \(responseString)")
                    }
                    print("Error signing in user: HTTP status code \(httpResponse.statusCode)")
                    completion(.failure(.networkError))
                    return
                }
                completion(.success(()))
            }
        }
        task.resume()
    }
    
    func getUserIdByUsername(username: String, completion: @escaping (Result<Int64, UserError>) -> Void) {
            let url = baseUrl.appendingPathComponent("getUserIdByUsername/\(username)")

            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error getting user ID: \(error.localizedDescription)")
                    completion(.failure(.networkError))
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, let data = data {
                    if !(200...299).contains(httpResponse.statusCode) {
                        completion(.failure(.networkError))
                        return
                    }
                    
                    do {
                        let fetchedUserId = try JSONDecoder().decode(Int64.self, from: data)
                        completion(.success(fetchedUserId))
                    } catch {
                        print("Error decoding user ID data: \(error.localizedDescription)")
                        completion(.failure(.invalidData))
                    }
                }
            }
            task.resume()
        }
    
    func registerUser(username: String, passwordHash: String, email: String, completion: @escaping (Result<Void, UserError>) -> Void) {
           let user = SignUpUser(username: username, passwordHash: passwordHash, email: email)
           guard let data = try? JSONEncoder().encode(user) else {
               completion(.failure(.invalidData))
               return
           }
           var request = URLRequest(url: baseUrl)
           request.httpMethod = "POST"
           request.httpBody = data
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           let task = session.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("Error registering user: \(error.localizedDescription)")
                   completion(.failure(.networkError))
                   return
               }
               if let httpResponse = response as? HTTPURLResponse {
                   if httpResponse.statusCode == 500 {
                       completion(.failure(.usernameUnavailable))
                       return
                   } else if !(200...299).contains(httpResponse.statusCode) {
                       if let data = data, let responseString = String(data: data, encoding: .utf8) {
                           print("Error response: \(responseString)")
                       }
                       print("Error registering user: HTTP status code \(httpResponse.statusCode)")
                       completion(.failure(.networkError))
                       return
                   }
                   completion(.success(()))
               }
           }
           task.resume()
       }
    
    func fetchUser(username: String, completion: @escaping (Result<UpdateUser, UserError>) -> Void) {
            let url = baseUrl.appendingPathComponent("ByUsername/\(username)")


            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    completion(.failure(.networkError))
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, let data = data {
                    if !(200...299).contains(httpResponse.statusCode) {
                        completion(.failure(.networkError))
                        return
                    }

                    do {
                        let fetchedUser = try JSONDecoder().decode(UpdateUser.self, from: data)
                        completion(.success(fetchedUser))
                        
                    } catch {
                        print("Error decoding user data: \(error.localizedDescription)")
                        completion(.failure(.invalidData))
                    }
                }
            }
            task.resume()
        }
    
    func updateUser(updateUser: UpdateUser, completion: @escaping (Result<Void, UserError>) -> Void) {
            guard let data = try? JSONEncoder().encode(updateUser) else {
                completion(.failure(.invalidData))
                return
            }

            var request = URLRequest(url: baseUrl.appendingPathComponent("\(updateUser.UserId)"))
            request.httpMethod = "PUT"
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = session.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("Error updating user: \(error.localizedDescription)")
                    completion(.failure(.networkError))
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if !(200...299).contains(httpResponse.statusCode) {
                        completion(.failure(.networkError))
                        return
                    }
                    completion(.success(()))
                }
            }
            task.resume()
        }

}
