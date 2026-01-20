//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Анастасия Федотова on 19.01.2026.
//
import Foundation

protocol QuestionFactoryDelegate: AnyObject {              
    func didReceiveNextQuestion(question: QuizQuestion?)
}
