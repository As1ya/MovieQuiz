//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Анастасия Федотова on 17.02.2026.
//
import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrect: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func changeStateButton(isEnabled: Bool)
}

