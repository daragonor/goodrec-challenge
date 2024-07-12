//
//  iOS_challengeTests.swift
//  iOS-challengeTests
//
//  Created by 🐉 on 11/07/24.
//

import XCTest
import Combine

final class iOS_challengeTests: XCTestCase {
    
    var breedsViewModel = BreedsViewModel()
    var cancellables = Set<AnyCancellable>()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor 
    func testGetBreedsList() throws {
        //Given
        let expectedFirstValue = Breed(name: "Australian", subspecies: [])
        let expect = expectation(description: "success")
        breedsViewModel.$state
            .dropFirst()     // << skip initial value !!
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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
