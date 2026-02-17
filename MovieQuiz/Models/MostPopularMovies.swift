//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Анастасия Федотова on 07.02.2026.
//
import Foundation

// MARK: - MostPopularMovies

struct MostPopularMovies: Codable {
    
    // MARK: - Public Properties
    
    let errorMessage: String
    let items: [MostPopularMovie]
}

// MARK: - MostPopularMovie

struct MostPopularMovie: Codable {
    
    // MARK: - Public Properties
    
    let title: String
    let rating: String
    let imageURL: URL
    
    // MARK: - Computed Properties
    
    var resizedImageURL: URL {
            let urlString = imageURL.absoluteString
            let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
            
            guard let newURL = URL(string: imageUrlString) else {
                return imageURL
            }
            
            return newURL
        }
        
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey {
    case title = "fullTitle"
    case rating = "imDbRating"
    case imageURL = "image"
    }
}
