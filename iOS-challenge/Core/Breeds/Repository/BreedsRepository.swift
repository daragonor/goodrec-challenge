//
//  BreedsRepository.swift
//  iOS-challenge
//
//  Created by 🐉 on 12/07/24.
//

import Foundation

protocol BreedsRepositoryProtocol {
    func getBreedsList() async throws -> [Breed]
    func getImageList(breed: String, subspecie: String?) async throws -> [String]
}

struct BreedsRepository: BreedsRepositoryProtocol {
    struct Dependencies {
        let dogApiClient: DogAPIClientProtocol
        let firebaseRtdClient: FirebaseRTDClientProtocol
        init(dogApiClient: DogAPIClientProtocol = DogAPIClient(), firebaseRtdClient: FirebaseRTDClientProtocol = FirebaseRTDClient()) {
            self.dogApiClient = dogApiClient
            self.firebaseRtdClient = firebaseRtdClient
        }
    }
    
    let dependencies: Dependencies
    
    init(dependencies: Dependencies = Dependencies()) {
        self.dependencies = dependencies
    }

    func getBreedsList() async throws -> [Breed] {
        try await dependencies.firebaseRtdClient.requestBreedsList()
    }
    
    func getImageList(breed: String, subspecie: String?) async throws -> [String] {
        try await dependencies.dogApiClient.requestImageList(breed: breed, subspecie: subspecie)
    }
}
