//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Анастасия Федотова on 10.02.2026.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    override func setUpWithError() throws {
        try super.setUpWithError()
                
        app = XCUIApplication()
        app.launch()
                
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
                
        app.terminate()
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testAlertAppearsAfterFinishingQuiz() {
        for _ in 0..<10 {
            app.buttons["Yes"].tap()
            sleep(1)
        }
        
        let alert = app.alerts["Game results"]
        
        XCTAssertTrue(alert.exists)
        
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        
        let alertButtonText = alert.buttons.firstMatch.label
        XCTAssertEqual(alertButtonText, "Сыграть ещё раз")
        
    }
    
    func testGameResultAlertDismissResetsQuiz() {
        for _ in 0..<10 {
            app.buttons["Yes"].tap()
            sleep(1)
        }
        
        let alert = app.alerts["Game results"]
        
        let alertDismissButton = alert.buttons.firstMatch
        alertDismissButton.tap()
        sleep(3)
        
        XCTAssertFalse(alert.exists)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
