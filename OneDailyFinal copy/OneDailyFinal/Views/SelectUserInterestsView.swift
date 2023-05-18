//
//  SelectUserInterestsView.swift
//  OneDailyFinal
//
//  Created by Student on 5/8/23.
//

import Foundation
import SwiftUI
import Combine

struct SelectInterestsView: View {
    @ObservedObject var viewModel: UserInterestsViewModel

    var body: some View {
        List(viewModel.allInterests, id: \.id) { interest in
            Button(action: {
                toggleInterestSelection(interest)
            }) {
                HStack {
                    Text(interest.name)
                    Spacer()
                    if viewModel.selectedInterests.contains(interest.id) {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchAllInterests()
        }
        .navigationBarItems(trailing: Button("Save") {
            viewModel.saveSelectedInterests()
        })
    }

    private func toggleInterestSelection(_ interest: Interest) {
        if viewModel.selectedInterests.contains(interest.id) {
            viewModel.selectedInterests.remove(interest.id)
        } else {
            viewModel.selectedInterests.insert(interest.id)
        }
    }
}

class UserInterestsViewModel: ObservableObject {
    @Published var allInterests: [Interest] = []
    @Published var userInterests: [Interest] = []
    @Published var selectedInterests: Set<Int> = []
    private var cancellables: Set<AnyCancellable> = []

    let username: String
    let interestService: InterestService

    init(username: String, interestService: InterestService) {
        self.username = username
        self.interestService = interestService
    }

    func fetchAllInterests() {
        interestService.fetchAllInterests()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { interests in
                self.allInterests = interests
            })
            .store(in: &cancellables)
    }

    func saveSelectedInterests() {
        interestService.addUserInterests(username: username, interestIds: Array(selectedInterests))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            print("Error saving interests: \(error)")
                        case .finished:
                            print("Successfully saved interests")
                        }
                    }, receiveValue: { })
                    .store(in: &cancellables)
    }
}
