//
//  BreedsRepository.swift
//  iOS-challenge
//
//  Created by 🐉 on 12/07/24.
//

import Foundation

enum Client { case FirebaseRTD, DogsAPI }

protocol BreedsListService {
    func requestBreedsList() async throws -> [Breed]
}

protocol ImageListService {
    func requestImageList(breed: String, subspecie: String?) async throws -> [String]
}

protocol BreedsRepositoryProtocol {
    func getBreedsList() async throws -> [Breed]
    func getImageList(breed: String, subspecie: String?) async throws -> [String]
}

struct BreedsRepository: BreedsRepositoryProtocol {
    struct Dependencies {
        let imageListSercice: ImageListService
        let breedsListService: BreedsListService
        init(breedsListService: BreedsListService = FirebaseRTDClient(), imageListSercice: ImageListService = DogAPIClient()) {
            self.imageListSercice = imageListSercice
            self.breedsListService = breedsListService
        }
    }
    
    let dependencies: Dependencies
    
    init(client: Client) {
        self.dependencies = Dependencies(
            breedsListService: {
                switch client {
                case .DogsAPI: DogAPIClient()
                case .FirebaseRTD: FirebaseRTDClient()
                }
            }(),
            imageListSercice: DogAPIClient()
        )
    }
    
    init(dependencies: Dependencies = Dependencies()) {
        self.dependencies = dependencies
    }

    func getBreedsList() async throws -> [Breed] {
        try await dependencies.breedsListService.requestBreedsList()
    }
    
    func getImageList(breed: String, subspecie: String?) async throws -> [String] {
        try await dependencies.imageListSercice.requestImageList(breed: breed, subspecie: subspecie)
    }
}
