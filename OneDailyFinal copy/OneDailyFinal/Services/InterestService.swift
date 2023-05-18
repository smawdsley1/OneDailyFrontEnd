//
//  InterestService.swift
//  OneDailyFinal
//
//  Created by Student on 5/8/23.
//

import Foundation
import SwiftUI
import Combine

struct Interest: Codable, Identifiable {
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey{
        case id = "interestId"
        case name = "interestName"
    }
    
}

class InterestService{
    private let baseUrl = URL(string: "https://10.10.137.10:7285/api")!
    
    // Use the same custom URL session delegate and session as in UserController
    private let customURLSessionDelegate = CustomURLSessionDelegate()
    private lazy var session = URLSession(configuration: .default, delegate: customURLSessionDelegate, delegateQueue: nil)
    
    func fetchAllInterests() -> AnyPublisher<[Interest], Error> {
        let url = URL(string: "\(baseUrl)/Interest")!
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type:[Interest].self, decoder: JSONDecoder())
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func addUserInterests(username: String, interestIds: [Int]) -> AnyPublisher<Void, Error>{
        let url = URL(string: "\(baseUrl)/UserInterest/\(username)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try? JSONEncoder().encode(interestIds)
        request.httpBody = jsonData
        
        return session.dataTaskPublisher(for: request)
            .map{ _ in () }
            .mapError { error -> Error in
                error as Error
            }
            .eraseToAnyPublisher()
    }
    
}



