//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Анастасия Федотова on 19.01.2026.
//
import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func presentAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default) { _ in
            model.onTap()
        }
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
}
