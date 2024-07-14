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
    case request = "Request"
    var message: String { self.rawValue }
}

class DogAPIClient: BreedsListService, ImageListService {
    enum Endpoint {
        case breedList
        case imageList(breed: String, subspecie: String?)
        private var urlString: String {
            let base = "https://dog.ceo/api"
            switch self {
            case .breedList: return base + "/breeds/list/all"
            case .imageList(let breed, let subspecie):
                if let subspecie = subspecie { return base + "/breed/\(breed)/\(subspecie)/images" }
                else { return base + "/breed/\(breed)/images" }
            }
        }
        var url: URL {
            get throws {
                guard let url = URL(string: urlString) else { throw ApiError.invalidURL }
                return url
            }
        }
    }
    
    let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
      self.urlSession = urlSession
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
        let request = URLRequest(url: url)
        let (data, _) = try await urlSession.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        guard let response = json?["message"] as? T else { throw ApiError.invalidContentWrapper }
        return response
    }
}
