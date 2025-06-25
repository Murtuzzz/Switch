import UIKit
import AVFoundation

class Level15ViewController: UIViewController {
    
    // MARK: - Properties
    private var gridButtons: [UIButton] = []
    private var activeLightButtonTag: Int? // The currently lit button
    private var currentLevel: Int = 1
    private var score: Int = 0
    private var audioPlayer: AVAudioPlayer?
    private var reactionTimer: Timer? // Timer for player reaction
    private var timeRemaining: TimeInterval = 0.0
    private let initialTimeLimit: TimeInterval = 1.5 // Фиксированное время реакции для уровня 15
    private let timeDecrementPerLevel: TimeInterval = 0.1 // Не используется в Level15 (время фиксированное)
    private let successfulTapsPerLevel: Int = 5 // How many successful taps to advance
    private let maxScore: Int = 20 // Максимальный счет для завершения уровня 15
    
    private var levelLabel: UILabel!
    private var instructionsLabel: UILabel!
    private var scoreLabel: UILabel!
    private var timerLabel: UILabel!
    private var progressView: UIProgressView!
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()
    
    private var gridStackView: UIStackView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsManager.shared.applyBackground(to: view)
        setupCloseButton()
        setupUI()
        prepareAudioPlayer()
        startLevel() // Запускаем игру автоматически
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Дополнительная проверка на случай, если игра не запустилась в viewDidLoad
        if reactionTimer == nil && activeLightButtonTag == nil {
            startLevel()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(containerView)
        
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .systemGreen
        progressView.trackTintColor = .systemGray5
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.progress = 0.0
        view.addSubview(progressView)
        
        levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.text = LocalizationManager.Levels.level15.localized
        levelLabel.font = .systemFont(ofSize: 24, weight: .bold)
        levelLabel.textColor = .label
        view.addSubview(levelLabel)
        
        instructionsLabel = UILabel()
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.text = LocalizationManager.GameMessages.tapButton.localized
        instructionsLabel.font = .systemFont(ofSize: 18, weight: .medium)
        instructionsLabel.textColor = .label
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        view.addSubview(instructionsLabel)
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = LocalizationManager.Stats.score.localized(with: 0)
        scoreLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        scoreLabel.textColor = .label
        view.addSubview(scoreLabel)
        
        timerLabel = UILabel()
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.text = LocalizationManager.Stats.timePlaceholder.localized
        timerLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        timerLabel.textColor = .label
        view.addSubview(timerLabel)
        
        createGridButtons()
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            containerView.widthAnchor.constraint(equalToConstant: 350),
            containerView.heightAnchor.constraint(equalToConstant: 450),
            
            levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            progressView.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            instructionsLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            instructionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            scoreLabel.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 20),
            scoreLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            timerLabel.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 20),
            timerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }
    
    private func createGridButtons() {
        gridStackView = UIStackView()
        gridStackView.axis = .vertical
        gridStackView.spacing = 10
        gridStackView.distribution = .fillEqually
        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(gridStackView)
        
        let rows = 3
        let cols = 3
        
        for row in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.distribution = .fillEqually
            gridStackView.addArrangedSubview(rowStack)
            
            for col in 0..<cols {
                let button = UIButton(type: .system)
                button.tag = row * cols + col // Unique tag for each button
                button.backgroundColor = .lightGray
                button.layer.cornerRadius = 15
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.2
                button.layer.shadowOffset = CGSize(width: 0, height: 2)
                button.layer.shadowRadius = 4
                button.addTarget(self, action: #selector(gridButtonTapped), for: .touchUpInside)
                rowStack.addArrangedSubview(button)
                gridButtons.append(button)
            }
        }
        
        NSLayoutConstraint.activate([
            gridStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            gridStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 40),
            gridStackView.widthAnchor.constraint(equalToConstant: 300),
            gridStackView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    // MARK: - Game Logic
    private func startLevel() {
        score = 0
        updateScoreLabel()
        updateLevelLabel()
        updateProgress()
        startNewRound()
    }
    
    private func startNewRound() {
        // Reset all buttons to default color
        gridButtons.forEach { $0.backgroundColor = .lightGray }
        enableAllButtons()
        
        // Stop any existing timer
        reactionTimer?.invalidate()
        
        // Фиксированное время реакции 1.5 секунды для уровня 15 (не уменьшается с подуровнями)
        timeRemaining = initialTimeLimit
        updateTimerLabel()
        
        // Randomly select a button to light up
        let randomIndex = Int.random(in: 0..<gridButtons.count)
        activeLightButtonTag = gridButtons[randomIndex].tag
        highlightButton(tag: activeLightButtonTag!, color: .systemBlue)
        
        // Start reaction timer
        reactionTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.timeRemaining -= 0.01
            if self.timeRemaining <= 0 {
                timer.invalidate()
                self.roundFailed() // Time ran out
            } else {
                self.updateTimerLabel()
            }
        }
    }
    
    @objc private func gridButtonTapped(_ sender: UIButton) {
        playSound()
        reactionTimer?.invalidate() // Stop the timer
        
        if sender.tag == activeLightButtonTag {
            score += 1
            updateScoreLabel()
            updateProgress() // Обновляем прогресс после каждого попадания
            animateButtonPress(button: sender, color: .systemGreen) { [weak self] in
                guard let self = self else { return }
                self.disableAllButtons() // Disable all buttons to prevent multiple taps
                
                if self.score % self.successfulTapsPerLevel == 0 && self.score != 0 {
                    self.currentLevel += 1
                    self.updateLevelLabel()
                    if self.score >= self.maxScore { // Game completed after reaching max score
                        self.showGameCompletedAlert()
                    } else {
                        self.startNewRound()
                    }
                } else {
                    self.startNewRound()
                }
            }
        } else {
            animateButtonPress(button: sender, color: .systemRed) { [weak self] in
                guard let self = self else { return }
                self.roundFailed() // Wrong button tapped
            }
        }
    }
    
    private func roundFailed() {
                    instructionsLabel.text = LocalizationManager.GameMessages.incorrect.localized
        disableAllButtons()
        reactionTimer?.invalidate()
        score = 0 // Reset score on failure
        updateScoreLabel()
        updateProgress() // Обновляем прогресс после сброса счета
        
        // Briefly show correct button if player tapped wrong or timed out
        if let activeTag = activeLightButtonTag, let correctButton = gridButtons.first(where: { $0.tag == activeTag }) {
            highlightButton(tag: correctButton.tag, color: .systemOrange) // Quick flash of correct button
        }
        
        // Небольшая задержка перед перезапуском, чтобы игрок увидел правильную кнопку
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.instructionsLabel.text = LocalizationManager.GameMessages.tapButton.localized
            self.startLevel() // Restart level on failure
        }
    }
    
    private func showGameCompletedAlert() {
        let alert = UIAlertController(
            title: "🎉 " + LocalizationManager.GameOver.title.localized,
            message: LocalizationManager.GameOver.completed.localized(with: score),
            preferredStyle: .alert
        )
        
        let mainMenuAction = UIAlertAction(title: LocalizationManager.GameOver.mainMenu.localized, style: .default) { [weak self] _ in
            self?.returnToMainMenu()
        }
        
        let restartAction = UIAlertAction(title: LocalizationManager.GameOver.restart.localized, style: .default) { [weak self] _ in
            self?.restartGame()
        }
        
        alert.addAction(mainMenuAction)
        alert.addAction(restartAction)
        
        present(alert, animated: true)
    }
    
    private func returnToMainMenu() {
        // Navigate back to the main menu
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        } else {
            // If presented modally, dismiss and return to MainViewController
            self.dismiss(animated: true) {
                // Create and present MainViewController
                let mainVC = MainViewController()
                mainVC.modalPresentationStyle = .fullScreen
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = mainVC
                    window.makeKeyAndVisible()
                }
            }
        }
    }
    
    private func restartGame() {
        // Restart from Level 1
        let level1VC = Level1ViewController()
        level1VC.modalPresentationStyle = .fullScreen
        present(level1VC, animated: true)
    }
    
    private func highlightButton(tag: Int, color: UIColor) {
        guard tag < gridButtons.count else { return }
        let button = gridButtons[tag]
        
        // Only light up, do not fade out automatically
        UIView.animate(withDuration: 0.1, animations: { // Quick flash for target
            button.backgroundColor = color
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            // Keep it lit, it will fade out when user interacts or round fails
            button.transform = .identity // Reset transform after initial light up
        }
    }
    
    private func animateButtonPress(button: UIButton, color: UIColor, completion: @escaping () -> Void) {
        let originalColor = button.backgroundColor
        UIView.animate(withDuration: 0.15, animations: { // Light up
            button.backgroundColor = color
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            // Fade out immediately after light up
            UIView.animate(withDuration: 0.3) { // Fade out
                button.backgroundColor = originalColor
                button.transform = .identity
            } completion: { _ in
                completion()
            }
        }
    }
    
    private func updateLevelLabel() {
        levelLabel.text = LocalizationManager.Levels.level15.localized
    }
    
    private func updateScoreLabel() {
        scoreLabel.text = LocalizationManager.Stats.score.localized(with: score)
    }
    
    private func updateTimerLabel() {
        timerLabel.text = LocalizationManager.Stats.timeSeconds.localized(with: max(0, timeRemaining))
    }
    
    private func updateProgress() {
        // Прогресс основан на общем количестве очков от 0 до maxScore
        let progress = Float(score) / Float(maxScore)
        UIView.animate(withDuration: 0.3) {
            self.progressView.progress = progress
        }
    }
    
    private func enableAllButtons() {
        gridButtons.forEach { $0.isEnabled = true }
    }
    
    private func disableAllButtons() {
        gridButtons.forEach { $0.isEnabled = false }
    }
    
    // MARK: - Audio
    private func prepareAudioPlayer() {
        audioPlayer = SettingsManager.shared.createAudioPlayer()
        audioPlayer?.prepareToPlay()
    }
    
    private func playSound() {
        audioPlayer?.play()
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        closeButton.setTitleColor(.label, for: .normal)
        //closeButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        closeButton.layer.cornerRadius = 22
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOpacity = 0.15
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        closeButton.layer.shadowRadius = 6
        //closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.systemGray4.cgColor
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func closeButtonTapped() {
        // Добавляем haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Анимация нажатия кнопки
        UIView.animate(withDuration: 0.1, animations: {
            if let button = self.view.subviews.first(where: { $0 is UIButton && ($0 as! UIButton).titleLabel?.text == "✕" }) {
                button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                if let button = self.view.subviews.first(where: { $0 is UIButton && ($0 as! UIButton).titleLabel?.text == "✕" }) {
                    button.transform = .identity
                }
            }) { _ in
                // Возвращаемся на главный экран
                self.returnToMainScreen()
            }
        }
    }
    
    private func returnToMainScreen() {
        // Найти корневой presenting view controller и закрыть все экраны
        var rootPresentingVC = presentingViewController
        while let parent = rootPresentingVC?.presentingViewController {
            rootPresentingVC = parent
        }
        rootPresentingVC?.dismiss(animated: true, completion: nil)
    }
}
