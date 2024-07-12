//
//  DogAPIClient.swift
//  iOS-challenge
//
//  Created by 🐉 on 12/07/24.
//

import Foundation

enum ApiError: String, Error {
    case invalidURL = "Invalid URL"
    case invalidContentWrapper = "Invalid Content Wrapper"
    case invalidContent = "Invalid Content"
    var message: String { self.rawValue }
}

struct DogAPIClient: BreedsListService, ImageListService {
    enum Endpoint {
        case breedList
        case imageList(breed: String, subspecie: String?)
        private var urlString: String {
            switch self {
            case .breedList: return "https://dog.ceo/api/breeds/list/all"
            case .imageList(let breed, let subspecie):
                var elements = ["https://dog.ceo/api/breed", breed]
                if let subspecie = subspecie { elements.append(subspecie) }
                elements.append("images")
                return elements.joined(separator: "/")
            }
        }
        var url: URL {
            get throws {
                guard let url = URL(string: urlString) else { throw ApiError.invalidURL }
                return url
            }
        }
    }
    
    func requestBreedsList() async throws -> [Breed] {
        let url = try Endpoint.breedList.url
        let response: [String: Any] = try await requestFromAPI(with: url)
        return try response.map { element in
            guard let value = element.value as? [String] else { throw ApiError.invalidContent }
            return Breed(name: element.key.capitalized, subspecies: value.map(\.capitalized))
        }.sorted(by: { left, right in left.name < right.name })
    }
    
    func requestImageList(breed: String, subspecie: String?) async throws -> [String] {
        let url = try Endpoint.imageList(breed: breed, subspecie: subspecie).url
        return try await requestFromAPI(with: url)
    }
    
    private func requestFromAPI<T>(with url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        guard let response = json?["message"] as? T else { throw ApiError.invalidContentWrapper }
        return response
    }
}
