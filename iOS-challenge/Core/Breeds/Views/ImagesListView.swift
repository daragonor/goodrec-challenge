//
//  ImagesListView.swift
//  iOS-challenge
//
//  Created by 🐉 on 11/07/24.
//

import SwiftUI

struct ImageListView: View {
    @StateObject
    var viewModel: ImageListViewModel
    
    var body: some View {
        switch viewModel.state {
        case .initial:
            ProgressView()
                .onAppear {
                    viewModel.getImages()
                }
        case .loaded(let images):
            ScrollView {
                ForEach(images, id:\.self) { imageString in
                    AsyncImage(url: URL(string: imageString)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Image(systemName: "Placeholder Image")
                        }
                    }
                    .cornerRadius(15)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(viewModel.title)
        case .error(message: let message):
            Text(message)
        }
    }
}

#Preview {
    NavigationStack {
        ImageListView(viewModel: ImageListViewModel(breed: "Deerhound"))
    }
}

