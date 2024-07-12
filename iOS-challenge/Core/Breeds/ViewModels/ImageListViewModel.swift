//
//  ImageListViewModel.swift
//  iOS-challenge
//
//  Created by 🐉 on 11/07/24.
//

import Foundation

class ImageListViewModel: ObservableObject {
    enum State { case initial, loaded(images: [String]), error(message: String) }
    
    @Published
    var state: State = .initial
    var breed: String
    var subspecie: String?
    var repository: BreedsRepositoryProtocol
    
    lazy var title: String = {
        var title = breed.capitalized
        if let subspecie = subspecie { title += ": \(subspecie.capitalized)"}
        return title
    }()
    
    init(breed: String, subspecie: String? = nil, repository: BreedsRepositoryProtocol = BreedsRepository()) {
        self.breed = breed.lowercased()
        self.subspecie = subspecie?.lowercased()
        self.repository = repository
    }
    
    @MainActor
    func getImages() {
        Task {
            do {
                let list = try await repository.getImageList(breed: breed, subspecie: subspecie)
                state = .loaded(images: list)
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
}
