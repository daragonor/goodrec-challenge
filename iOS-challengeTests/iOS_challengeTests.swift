//
//  iOS_challengeTests.swift
//  iOS-challengeTests
//
//  Created by 🐉 on 11/07/24.
//

import XCTest
import Combine

final class iOS_challengeTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var mockedRepository: BreedsRepositoryProtocol!
    
    override func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        let dogsMockedAPIClient = DogAPIClient(urlSession: urlSession)
        mockedRepository = BreedsRepository(dependencies: .init(breedsListService: dogsMockedAPIClient, imageListSercice: dogsMockedAPIClient))
    }
    
    @MainActor
    func testBreedsListLoaded() {
        //Given
        let breedsViewModel = BreedsViewModel()
        let expectedFirstValue = Breed(name: "Australian", subspecies: [])
        let expect = expectation(description: "success")
        breedsViewModel.$state
            .dropFirst()
            .sink { state in
                expect.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        breedsViewModel.getListOfBreeds()
        
        //Then
        waitForExpectations(timeout: 2)
        switch breedsViewModel.state {
        case .loaded(let breeds):
            XCTAssertEqual(breeds.first?.name, expectedFirstValue.name)
        default:
            XCTFail()
        }
    }
    
    @MainActor
    func testGetBreedsListFromDogsAPI() {
        //Given
        let breedsViewModel = BreedsViewModel()
        let expectedFirstValue = Breed(name: "Affenpinscher", subspecies: [])
        let expect = expectation(description: "success")
        breedsViewModel.$state
            .sink { state in
                switch state {
                case .loaded(_):
                    expect.fulfill()
                default: break
                }
            }
            .store(in: &cancellables)
        
        //When
        breedsViewModel.changeClient(to: .DogsAPI)
        breedsViewModel.getListOfBreeds()
        //Then
        waitForExpectations(timeout: 2)
        switch breedsViewModel.state {
        case .loaded(let breeds):
            XCTAssertEqual(breeds.first?.name, expectedFirstValue.name)
        default:
            XCTFail()
        }
    }
    
    @MainActor
    func testGetImageList() {
        //Given
        let imageListViewModel = ImageListViewModel(breed: "Affenpinscher")
        let expectedFirstValue = "https://images.dog.ceo/breeds/affenpinscher/n02110627_10185.jpg"
        let expect = expectation(description: "success")
        imageListViewModel.$state
            .sink { state in
                switch state {
                case .loaded(_):
                    expect.fulfill()
                default: break
                }
            }
            .store(in: &cancellables)
        
        //When
        imageListViewModel.getImages()
        //Then
        waitForExpectations(timeout: 2)
        switch imageListViewModel.state {
        case .loaded(let images):
            XCTAssertEqual(imageListViewModel.title, "Affenpinscher")
            XCTAssertEqual(images.first, expectedFirstValue)
        default:
            XCTFail()
        }
    }
    
    func testGetBreedsListInitial() {
        //Given
        let breedsViewModel = BreedsViewModel()
        let expect = expectation(description: "success")
        breedsViewModel.$state
            .sink { state in
                expect.fulfill()
            }
            .store(in: &cancellables)
        //Then
        waitForExpectations(timeout: 2)
        XCTAssertEqual(breedsViewModel.state, .initial)
    }
    
    @MainActor
    func testGetBreedsListFailedContentWrapper() {
        //Given
        let json = """
        {
           "body": {
              "affenpinscher": ""
           }
        }
        """
        guard let url = try? DogAPIClient.Endpoint.breedList.url,
              let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
              let data = json.data(using: .utf8)
        else { XCTFail() ; return }
        MockURLProtocol.requestHandler = { _ in return (response, data) }
        let breedsViewModel = BreedsViewModel(repository: mockedRepository)
        let expect = expectation(description: "Success")
        breedsViewModel.$state
            .dropFirst()
            .sink { state in
                expect.fulfill()
            }
            .store(in: &cancellables)
        
        //When
        breedsViewModel.getListOfBreeds()
        
        //Then
        waitForExpectations(timeout: 2)
        switch breedsViewModel.state {
        case .error(let message):
            XCTAssertEqual(message, "Invalid Content Wrapper")
        default:
            XCTFail()
        }
    }
}
