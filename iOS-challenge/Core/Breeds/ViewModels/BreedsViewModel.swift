//
//  BreedsViewModel.swift
//  iOS-challenge
//
//  Created by 🐉 on 11/07/24.
//

import Foundation

class BreedsViewModel: ObservableObject {
    enum State { case initial, loaded(breeds: [Breed]), error(message: String) }
    
    @Published
    var state: State
    var repository: BreedsRepositoryProtocol
    
    init(repository: BreedsRepositoryProtocol = BreedsRepository()) {
        self.state = .initial
        self.repository = repository
    }
    
    @MainActor
    func getListOfBreeds() {
        Task {
            do {
                let list = try await repository.getBreedsList()
                state = .loaded(breeds: list)
            } catch {
                switch error as? ApiError {
                case .some(let error):
                    state = .error(message: error.message)
                case .none:
                    state = .error(message: "Unknown Error")
                }
            }
        }
    }

    func changeClient(to client: Client) {
        repository = BreedsRepository(client: client)
        state = .initial
    }
}
