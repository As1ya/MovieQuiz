import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private properties
    private let presenter = MovieQuizPresenter()
    private var correctAnswersCount: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol!
    private var isInteractionLocked = false
    
    // MARK: - Constants
    enum ResultAlertConstants {
        static let messageTemplate = """
        Ваш результат: %d/%d
        Количество сыгранных игр: %d
        Рекорд: %d/%d
        Дата рекорда: %@
        Средняя точность: %.2f%%
        """
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticService = StatisticService()
        
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)

        showLoadingIndicator()
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }

        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard !isInteractionLocked else { return }
        handleAnswerResult(givenAnswer: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard !isInteractionLocked else { return }
        handleAnswerResult(givenAnswer: false)
    }
    
    // MARK: - Private logic
    private func handleAnswerResult(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        setButtonsEnabled(false)
        isInteractionLocked = true
        
        let isCorrect = currentQuestion.correctAnswer == givenAnswer
        
        if isCorrect {
            correctAnswersCount += 1
        }
        
        showAnswerResult(isCorrect: isCorrect)
        presenter.switchToNextQuestion()
    }
    

    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let bestGame = statisticService.bestGame
        
        let message = String(
            format: ResultAlertConstants.messageTemplate,
            correctAnswersCount,
            presenter.questionsAmount,
            statisticService.gamesCount,
            bestGame.correct,
            bestGame.total,
            bestGame.date.dateTimeString,
            statisticService.totalAccuracy
        )
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            onTap: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswersCount = 0
                self.imageView.layer.borderWidth = 0
                self.setButtonsEnabled(true)
                self.isInteractionLocked = false
                self.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.presentAlert(model: alertModel)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswersCount, total: presenter.questionsAmount)
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "", // not used yet
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            imageView.layer.borderWidth = 0
            setButtonsEnabled(true)
            isInteractionLocked = false
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func setButtonsEnabled(_ enabled: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
        yesButton.alpha = enabled ? 1.0 : 0.6
        noButton.alpha = enabled ? 1.0 : 0.6
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true 
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() 
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
        ) { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswersCount = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.presentAlert(model: model)
    }
    
    internal func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            self?.hideLoadingIndicator()
            self?.questionFactory?.requestNextQuestion()
        }
    }

    internal func didFailToLoadData(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showNetworkError(message: error.localizedDescription)
        }
    }
}

