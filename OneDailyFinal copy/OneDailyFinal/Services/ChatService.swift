import Foundation

class ChatService {
    private let baseUrl = URL(string: "https://10.10.137.10:7285/api/message/")!
    private let customURLSessionDelegate = CustomURLSessionDelegate()
    private lazy var session = URLSession(configuration: .default, delegate: customURLSessionDelegate, delegateQueue: nil)
    
    func postMessage(_ message: ClientMessage, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let encoded = try? JSONEncoder().encode(message) else {
            print("Failed to encode message")
            return
        }
        
        var request = URLRequest(url: baseUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encoded
        
        let task = self.session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
            }
            
            if let error = error {
                print("HTTP Request Error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    completion(.success(data))
                }
                return
            }
            
            completion(.failure(NSError(domain: "Unknown error", code: 0, userInfo: nil)))
        }
        task.resume()
    }
    
    func loadMessages(username: String, completion: @escaping (Result<[ClientMessage], Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)GetByUsername/\(username)") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
            }
            
            if let error = error {
                print("HTTP Request Error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let data = data {
                print("Response Data: \(String(data: data, encoding: .utf8) ?? "")")
                
                do {
                    let messages = try JSONDecoder().decode([ClientMessage].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(messages))
                    }
                } catch {
                    print("Failed to decode messages: \(error)")
                    completion(.failure(error))
                }
                return
            }
            
            completion(.failure(NSError(domain: "Unknown error", code: 0, userInfo: nil)))
        }
        task.resume()
    }
    
    func getConversationId(username: String, completion: @escaping (Result<Int64, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)GetConversationId/\(username)") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
            }

            if let error = error {
                print("HTTP Request Error: \(error)")
                completion(.failure(error))
                return
            }

            if let data = data {
                do {
                    let conversationId = try JSONDecoder().decode(Int64.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(conversationId))
                    }
                } catch {
                    print("Failed to decode conversation ID: \(error)")
                    completion(.failure(error))
                }
                return
            }

            completion(.failure(NSError(domain: "Unknown error", code: 0, userInfo: nil)))
        }
        task.resume()
    }

}
