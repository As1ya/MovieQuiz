//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Анастасия Федотова on 18.01.2026.
//
import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoaderProtocol
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoaderProtocol, delegate: QuestionFactoryDelegate?) {
            self.moviesLoader = moviesLoader
            self.delegate = delegate
        }
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
        /*
         private let questions: [QuizQuestion] = [
         QuizQuestion(image: "The Godfather",
         rating: 9.2,
         text: "Рейтинг этого фильма больше чем 6?",
         correctAnswer: true),
         QuizQuestion(image: "The Dark Knight",
         rating: 9,
         text: "Рейтинг этого фильма больше чем 6?",
         correctAnswer: true),
         QuizQuestion(image: "Kill Bill",
         rating: 8.1,
         text: "Рейтинг этого фильма больше чем 6?",
         correctAnswer: true),
         QuizQuestion(image: "The Avengers",
         rating: 8,
         text: "Рейтинг этого фильма больше чем 6?",
         correctAnswer: true),
         QuizQuestion(image: "Deadpool",
         rating: 8,
         text: "Рейтинг этого фильма больше чем 6?",
         correctAnswer: true),
         QuizQuestion(image: "The Green Knight",
         rating: 6.6,
         text: "Рейтинг этого фильма больше чем 6?",
         correctAnswer: true),
         QuizQuestion(image: "Old",
         rating: 5.8,
         text: "Рейтинг этого фильма больше чем 6?",
         correctAnswer: false),
         QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
         rating: 4.3,
         text: "Рейтинг этого фильма больше чем 6?",
         correctAnswer: false),
         QuizQuestion(image: "Tesla",
         rating: 5.1,
         text: "Рейтинг этого фильма больше чем 6?",
         correctAnswer: false),
         QuizQuestion(image: "Vivarium",
         rating: 5.8,
         text: "Рейтинг этого фильма больше чем 6?",
         correctAnswer: false)
         ] */
        
        
        func requestNextQuestion() {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                let index = (0..<self.movies.count).randomElement() ?? 0
                
                guard let movie = self.movies[safe: index] else { return }
                
                var imageData = Data()
                
                do {
                    imageData = try Data(contentsOf: movie.resizedImageURL)
                } catch {
                    print("Failed to load image: \(error)")
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.didFailToLoadData(with: error)
                    }
                    return
                }
                
                let rating = Float(movie.rating) ?? 0
                
                let textRating = "\(Int.random(in: 7...9)).\(Int.random(in: 0...9))"
                let threshold = Float(textRating) ?? 0
                
                let isGreater = Bool.random()
                let operatorText = isGreater ? "больше" : "меньше"
                
                let text = "Рейтинг этого фильма \(operatorText) чем \(textRating)?"
                let correctAnswer = isGreater ? rating > threshold : rating < threshold
                
                let question = QuizQuestion(image: imageData,
                                            text: text,
                                            correctAnswer: correctAnswer)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            }
        }
    }

