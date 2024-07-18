//
//  FirebaseRTDClient.swift
//  iOS-challenge
//
//  Created by 🐉 on 11/07/24.
//

import Foundation
import FirebaseDatabase

struct FirebaseRTDClient: BreedsListService {
    var ref: DatabaseReference? = Database.database().reference()
    
    func requestBreedsList() async throws -> [Breed] {
        do {
            let snapshot = try await ref?.getData()
            let dict = snapshot?.value as? [String: Any]
            guard let response = dict?["message"] as? [String: Any] else { throw ApiError.invalidContentWrapper }
            return try response.map { element in
                guard let value = element.value as? [String] else { throw ApiError.invalidContent }
                return Breed(name: element.key.capitalized, subspecies: value.map(\.capitalized))
            }
            .sorted(by: { left, right in left.name < right.name })
        } catch {
            throw ApiError.invalidContent
        }
        
    }
}
