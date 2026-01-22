//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Анастасия Федотова on 19.01.2026.
//
import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let onTap: () -> Void
}
