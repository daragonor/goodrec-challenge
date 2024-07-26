//
//  BreedsView.swift
//  iOS-challenge
//
//  Created by 🐉 on 11/07/24.
//

import SwiftUI

struct BreedsView: View {
    var twoColumnGrid = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
    
    @StateObject
    var viewModel: BreedsViewModel

    var body: some View {
        NavigationStack {
            switch viewModel.state {
            case .initial:
                ProgressView()
            case .loaded(let breeds):
                breedsList(list: breeds)
                    .navigationTitle("Breeds list")
                    .toolbar(content: breedsToolbar)
            case .error(message: let message):
                Text(message)
            }
        }
        .task {
            viewModel.getListOfBreeds()
        }
    }
    
    func breedsList(list: [Breed]) -> some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: twoColumnGrid, content: {
                    ForEach(list, id: \.self) { breed in
                        NavigationLink(
                            value: breed,
                            label: { CardView(breed: breed) }
                        ).contextMenu {
                            Section("Subsepcies") {
                                ForEach(breed.subspecies, id: \.self) { subspecie in
                                    NavigationLink(subspecie) {
                                        ImageListView(viewModel: .init(breed: breed.name, subspecie: subspecie))
                                    }
                                }
                            }
                        }
                    }
                })
                .navigationDestination(for: Breed.self) { breed in
                    ImageListView(viewModel: .init(breed: breed.name))
                }
                .padding()
            }
        }
    }
    
    func breedsToolbar() -> some View {
        Menu(content: {
            Button(action: {
                viewModel.changeClient(to: .FirebaseRTD)
            }, label: {
                Text("Firebase")
            })
            Button(action: {
                viewModel.changeClient(to: .DogsAPI)
            }, label: {
                Text("DogsAPI")
            })
        }, label: {
            Image(systemName: "server.rack")
        })
    }
}

struct CardView: View {
    let breed: Breed
    var body: some View {
        VStack(alignment: .leading) {
            Text(breed.name)
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            if !breed.subspecies.isEmpty {
                VStack {
                    Divider()
                    HStack {
                        Text(breed.subspecies.joined(separator: ", "))
                        Spacer()
                        Image(systemName: "dog.circle")
                    }
                    .foregroundStyle(.white)
                    .font(.caption)
                }
                
            }
        }
        .frame(height: 60)
        .padding()
        .background(.blue)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 3)
    }
}

#Preview {
    BreedsView(viewModel: BreedsViewModel())
}
