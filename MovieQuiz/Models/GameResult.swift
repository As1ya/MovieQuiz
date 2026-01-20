//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Анастасия Федотова on 20.01.2026.
//
import Foundation

struct GameResult  {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ other: GameResult) -> Bool {
        return (correct > other.correct) || ((correct == other.correct) && (date > other.date))
    }
}
