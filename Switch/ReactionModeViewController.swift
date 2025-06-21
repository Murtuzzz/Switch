import UIKit
import AVFoundation

class ReactionModeViewController: UIViewController {
    
    // MARK: - Properties
    private var gridButtons: [UIButton] = []
    private var activeLightButtonTag: Int?
    private var currentLevel: Int = 1
    private var currentScore: Int = 0
    private var audioPlayer: AVAudioPlayer?
    private var reactionTimer: Timer?
    private var timeRemaining: TimeInterval = 0.0
    private var initialTimeLimit: TimeInterval = 1.5
    private let timeDecrementPerLevel: TimeInterval = 0.08
    private let minTimeLimit: TimeInterval = 0.2
    private var consecutiveSuccess: Int = 0
    private let levelUpThreshold: Int = 7
    private var hasShownInstructions: Bool = false
    
    private var levelLabel: UILabel!
    private var instructionsLabel: UILabel!
    private var scoreLabel: UILabel!
    private var timerLabel: UILabel!
    private var progressView: UIProgressView!
    private var bestScoreLabel: UILabel!
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = R.Colors.whiteBg
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasShownInstructions {
            hasShownInstructions = true
            showInstructionsAlert()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllSounds()
    }
    
    deinit {
        reactionTimer?.invalidate()
        stopAllSounds()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(containerView)
        
        // Close button
        
        // Progress view
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = R.Colors.green
        progressView.trackTintColor = .systemGray5
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.progress = 0.0
        view.addSubview(progressView)
        
        // Level label
        levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.text = "Реакция - Уровень 1"
        levelLabel.font = .systemFont(ofSize: 24, weight: .bold)
        levelLabel.textColor = .label
        levelLabel.textAlignment = .center
        view.addSubview(levelLabel)
        
        // Instructions label
        instructionsLabel = UILabel()
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.text = "Ожидание инструкций..."
        instructionsLabel.font = .systemFont(ofSize: 16, weight: .medium)
        instructionsLabel.textColor = .secondaryLabel
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        view.addSubview(instructionsLabel)
        
        // Score label
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Счет: 0"
        scoreLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        scoreLabel.textColor = .label
        view.addSubview(scoreLabel)
        
        // Timer label
        timerLabel = UILabel()
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.text = "Время: 1.50"
        timerLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        timerLabel.textColor = .label
        view.addSubview(timerLabel)
        
        // Best score label
        bestScoreLabel = UILabel()
        bestScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        bestScoreLabel.text = "Рекорд: \(getBestScore())"
        bestScoreLabel.font = .systemFont(ofSize: 16, weight: .medium)
        bestScoreLabel.textColor = .secondaryLabel
        bestScoreLabel.textAlignment = .center
        view.addSubview(bestScoreLabel)
        
        createGridButtons()
        
        NSLayoutConstraint.activate([
            
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
            
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            containerView.widthAnchor.constraint(equalToConstant: 340),
            containerView.heightAnchor.constraint(equalToConstant: 420),
            
            scoreLabel.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 20),
            scoreLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            timerLabel.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 20),
            timerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            bestScoreLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bestScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createGridButtons() {
        gridStackView = UIStackView()
        gridStackView.axis = .vertical
        gridStackView.spacing = 12
        gridStackView.distribution = .fillEqually
        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(gridStackView)
        
        let rows = 3
        let cols = 3
        
        for row in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.distribution = .fillEqually
            gridStackView.addArrangedSubview(rowStack)
            
            for col in 0..<cols {
                let button = UIButton(type: .system)
                button.tag = row * cols + col
                button.backgroundColor = .systemGray4
                button.layer.cornerRadius = 20
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.1
                button.layer.shadowOffset = CGSize(width: 0, height: 2)
                button.layer.shadowRadius = 4
                button.addTarget(self, action: #selector(gridButtonTapped), for: .touchUpInside)
                rowStack.addArrangedSubview(button)
                gridButtons.append(button)
            }
        }
        
        NSLayoutConstraint.activate([
            gridStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            gridStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 30),
            gridStackView.widthAnchor.constraint(equalToConstant: 280),
            gridStackView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    // MARK: - Instructions
    private func showInstructionsAlert() {
        showModernInstructionsScreen()
    }
    
    private func showModernInstructionsScreen() {
        let instructionsView = createInstructionsView()
        
        // Устанавливаем начальное состояние для анимации
        instructionsView.alpha = 0
        instructionsView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        view.addSubview(instructionsView)
        
        // Анимируем появление
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            instructionsView.alpha = 1
            instructionsView.transform = .identity
        }
    }
    
    private func createInstructionsView() -> UIView {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = R.Colors.whiteBg
        cardView.layer.cornerRadius = 25
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.3
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView.layer.shadowRadius = 20
        
        // Заголовок с иконкой
        let titleStackView = UIStackView()
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .horizontal
        titleStackView.spacing = 12
        titleStackView.alignment = .center
        
        let iconLabel = UILabel()
        iconLabel.text = "⚡️"
        iconLabel.font = .systemFont(ofSize: 32)
        
        let titleLabel = UILabel()
        titleLabel.text = "Режим Реакция"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = R.Colors.green
        
        titleStackView.addArrangedSubview(iconLabel)
        titleStackView.addArrangedSubview(titleLabel)
        
        // Описание цели
        let goalView = createInfoBlock(
            icon: "🎯",
            title: "Цель",
            description: "Быстро нажимайте на подсвеченную кнопку!"
        )
        
        // Правила
        let rulesView = createInfoBlock(
            icon: "📋",
            title: "Правила",
            description: """
            • Синяя кнопка загорается случайно
            • Нажмите на неё до истечения времени
            • Время уменьшается с каждым уровнем
            • 7 правильных ответов = новый уровень
            """
        )
        
        // Предупреждение
        let warningView = createInfoBlock(
            icon: "⚠️",
            title: "Внимание",
            description: "Одна ошибка или пропуск = конец игры"
        )
        
        // Совет
        let tipView = createInfoBlock(
            icon: "💡",
            title: "Совет",
            description: "Будьте внимательны и быстры!"
        )
        
        // Кнопки
        let buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        
        let startButton = createModernButton(title: "Начать игру", isPrimary: true)
        startButton.addTarget(self, action: #selector(instructionsStartButtonTapped), for: .touchUpInside)
        
        let backButton = createModernButton(title: "Назад", isPrimary: false)
        backButton.addTarget(self, action: #selector(instructionsBackButtonTapped), for: .touchUpInside)
        
        buttonStackView.addArrangedSubview(backButton)
        buttonStackView.addArrangedSubview(startButton)
        
        // Добавляем элементы в карточку
        cardView.addSubview(titleStackView)
        cardView.addSubview(goalView)
        cardView.addSubview(rulesView)
        cardView.addSubview(warningView)
        cardView.addSubview(tipView)
        cardView.addSubview(buttonStackView)
        
        overlayView.addSubview(cardView)
        
        // Устанавливаем frame и autoresizing до добавления в иерархию view
        overlayView.frame = view.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        NSLayoutConstraint.activate([
            
            cardView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 32),
            cardView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -32),
            
            titleStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            titleStackView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            
            goalView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 24),
            goalView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            goalView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            rulesView.topAnchor.constraint(equalTo: goalView.bottomAnchor, constant: 16),
            rulesView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            rulesView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            warningView.topAnchor.constraint(equalTo: rulesView.bottomAnchor, constant: 16),
            warningView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            warningView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            tipView.topAnchor.constraint(equalTo: warningView.bottomAnchor, constant: 16),
            tipView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            tipView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            buttonStackView.topAnchor.constraint(equalTo: tipView.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return overlayView
    }
    
    private func createInfoBlock(icon: String, title: String, description: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = R.Colors.light
        containerView.layer.cornerRadius = 12
        
        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 54)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .left
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.textAlignment = .left
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            //iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
    
    private func createModernButton(title: String, isPrimary: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 25
        
        if isPrimary {
            button.backgroundColor = R.Colors.green
            button.setTitleColor(.white, for: .normal)
            button.layer.shadowColor = R.Colors.green.cgColor
            button.layer.shadowOpacity = 0.3
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.layer.shadowRadius = 8
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(R.Colors.green, for: .normal)
            button.layer.borderWidth = 2
            button.layer.borderColor = R.Colors.green.cgColor
        }
        
        // Добавляем эффект нажатия
        button.addTarget(self, action: #selector(modernButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(modernButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    @objc private func modernButtonTouchDown(_ button: UIButton) {
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func modernButtonTouchUp(_ button: UIButton) {
        UIView.animate(withDuration: 0.1) {
            button.transform = .identity
        }
    }
    
    @objc private func instructionsStartButtonTapped() {
        hideInstructionsScreen {
            self.startGame()
        }
    }
    
    @objc private func instructionsBackButtonTapped() {
        hideInstructionsScreen {
            self.dismiss(animated: true)
        }
    }
    
    private func hideInstructionsScreen(completion: @escaping () -> Void) {
        guard let instructionsView = view.subviews.last else {
            completion()
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            instructionsView.alpha = 0
            instructionsView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            instructionsView.removeFromSuperview()
            completion()
        }
    }
    
    // MARK: - Game Logic
    private func startGame() {
        currentScore = 0
        currentLevel = 1
        consecutiveSuccess = 0
        initialTimeLimit = 1.5
        instructionsLabel.text = "Нажмите на подсвеченную кнопку!"
        updateLabels()
        startNewRound()
    }
    
    private func startNewRound() {
        // Reset all buttons
        gridButtons.forEach {
            $0.backgroundColor = .systemGray4
            $0.isEnabled = true
        }
        
        // Stop existing timer
        reactionTimer?.invalidate()
        
        // Calculate time limit for current level (ускоряющееся уменьшение)
        let exponentialDecrement = TimeInterval(currentLevel - 1) * timeDecrementPerLevel * (1 + TimeInterval(currentLevel - 1) * 0.02)
        let currentTimeLimit = max(minTimeLimit, initialTimeLimit - exponentialDecrement)
        timeRemaining = currentTimeLimit
        updateTimerLabel()
        
        // Select random button to highlight
        let randomIndex = Int.random(in: 0..<gridButtons.count)
        activeLightButtonTag = gridButtons[randomIndex].tag
        highlightButton(tag: activeLightButtonTag!)
        
        // Start countdown timer
        reactionTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.timeRemaining -= 0.01
            
            if self.timeRemaining <= 0 {
                timer.invalidate()
                self.roundFailed()
            } else {
                self.updateTimerLabel()
                
                // Warning effects
                if self.timeRemaining <= 0.6 && self.timeRemaining > 0.3 {
                    self.timerLabel.textColor = .systemOrange
                } else if self.timeRemaining <= 0.3 {
                    self.timerLabel.textColor = .systemRed
                    // Пульсация при критическом времени
                    if Int(self.timeRemaining * 10) % 3 == 0 {
                        UIView.animate(withDuration: 0.1) {
                            self.timerLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                        } completion: { _ in
                            UIView.animate(withDuration: 0.1) {
                                self.timerLabel.transform = .identity
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func gridButtonTapped(_ sender: UIButton) {
        playSound()
        reactionTimer?.invalidate()
        disableAllButtons()
        
        if sender.tag == activeLightButtonTag {
            // Correct button
            currentScore += calculateScore()
            consecutiveSuccess += 1
            
            animateButtonSuccess(sender) { [weak self] in
                guard let self = self else { return }
                
                // Level up check
                if self.consecutiveSuccess >= self.levelUpThreshold {
                    self.levelUp()
                }
                
                self.updateLabels()
                
                // Small delay before next round
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.startNewRound()
                }
            }
        } else {
            // Wrong button
            animateButtonError(sender) { [weak self] in
                guard let self = self else { return }
                self.roundFailed()
            }
        }
    }
    
    private func calculateScore() -> Int {
        let baseScore = 10
        let levelBonus = (currentLevel - 1) * 5
        let speedBonus = Int(max(0, (timeRemaining * 10))) // Bonus for fast reaction
        return baseScore + levelBonus + speedBonus
    }
    
    private func levelUp() {
        currentLevel += 1
        consecutiveSuccess = 0
        
        // Show level up effect
        showLevelUpEffect()
        
        // Celebration
        celebrateSuccess()
    }
    
    private func roundFailed() {
        consecutiveSuccess = 0
        instructionsLabel.text = "Неверно! Правильная кнопка подсвечена оранжевым"
        
        // Show correct button briefly
        if let activeTag = activeLightButtonTag {
            highlightButton(tag: activeTag, color: R.Colors.orange)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.gameOver()
        }
    }
    
    private func gameOver() {
        saveBestScore()
        
        let isNewRecord = currentScore > UserDefaults.standard.integer(forKey: "ReactionModeHighScore") && currentScore > 0
        let title = isNewRecord ? "🏆 Новый рекорд!" : "⚡️ Игра окончена!"
        
        let performanceMessage: String
        if currentLevel <= 2 {
            performanceMessage = "Попробуйте ещё раз!"
        } else if currentLevel <= 5 {
            performanceMessage = "Неплохо для начала!"
        } else if currentLevel <= 10 {
            performanceMessage = "Отличная реакция!"
        } else {
            performanceMessage = "Невероятная скорость!"
        }
        
        let alert = UIAlertController(
            title: title,
            message: """
            📊 Результаты:
            • Уровень: \(currentLevel)
            • Счет: \(currentScore)
            • Рекорд: \(getBestScore())
            
            \(performanceMessage)
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Играть снова", style: .default) { [weak self] _ in
            self?.startGame()
        })
        
        alert.addAction(UIAlertAction(title: "Показать инструкции", style: .default) { [weak self] _ in
            self?.showInstructionsAlert()
        })
        
        alert.addAction(UIAlertAction(title: "Главное меню", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Visual Effects
    private func highlightButton(tag: Int, color: UIColor = R.Colors.blue) {
        guard tag < gridButtons.count else { return }
        let button = gridButtons[tag]
        
        UIView.animate(withDuration: 0.2) {
            button.backgroundColor = color
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            button.transform = .identity
        }
    }
    
    private func animateButtonSuccess(_ button: UIButton, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            button.backgroundColor = R.Colors.green
            button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                button.transform = .identity
            }) { _ in
                completion()
            }
        }
        
        // Success haptic feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
    
    private func animateButtonError(_ button: UIButton, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            button.backgroundColor = R.Colors.red
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            // Shake animation
            let shakeAnimation = CABasicAnimation(keyPath: "position")
            shakeAnimation.duration = 0.1
            shakeAnimation.repeatCount = 3
            shakeAnimation.autoreverses = true
            shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: button.center.x - 5, y: button.center.y))
            shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: button.center.x + 5, y: button.center.y))
            
            button.layer.add(shakeAnimation, forKey: "shake")
            
            UIView.animate(withDuration: 0.2, animations: {
                button.transform = .identity
            }) { _ in
                completion()
            }
        }
        
        // Error haptic feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.error)
    }
    
    private func celebrateSuccess() {
        // Container animation
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8) {
            self.containerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = .identity
            }
        }
        
        // Success haptic feedback
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()
    }
    
    private func showLevelUpEffect() {
        let levelUpLabel = UILabel()
        levelUpLabel.text = "УРОВЕНЬ \(currentLevel)!"
        levelUpLabel.font = .systemFont(ofSize: 32, weight: .bold)
        levelUpLabel.textColor = R.Colors.green
        levelUpLabel.textAlignment = .center
        levelUpLabel.alpha = 0
        levelUpLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        view.addSubview(levelUpLabel)
        levelUpLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            levelUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelUpLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100)
        ])
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            levelUpLabel.alpha = 1
            levelUpLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0.5, animations: {
                levelUpLabel.alpha = 0
                levelUpLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { _ in
                levelUpLabel.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func updateLabels() {
        scoreLabel.text = "Счет: \(currentScore)"
        levelLabel.text = "Реакция - Уровень \(currentLevel)"
        timerLabel.textColor = .label
        updateProgress()
    }
    
    private func updateTimerLabel() {
        timerLabel.text = String(format: "Время: %.2f", max(0, timeRemaining))
    }
    
    private func updateProgress() {
        let progress = Float(consecutiveSuccess) / Float(levelUpThreshold)
        UIView.animate(withDuration: 0.3) {
            self.progressView.progress = progress
        }
    }
    
    private func disableAllButtons() {
        gridButtons.forEach { $0.isEnabled = false }
    }
    
    private func getBestScore() -> Int {
        return UserDefaults.standard.integer(forKey: "ReactionModeHighScore")
    }
    
    private func saveBestScore() {
        let currentBest = getBestScore()
        if currentScore > currentBest {
            UserDefaults.standard.set(currentScore, forKey: "ReactionModeHighScore")
            bestScoreLabel.text = "Рекорд: \(currentScore)"
        }
        
        // Добавляем в список рекордов режима реакции
        var reactionScores = UserDefaults.standard.array(forKey: "ReactionModeScores") as? [Int] ?? []
        reactionScores.append(currentScore)
        // Оставляем только топ-10 рекордов
        reactionScores = Array(reactionScores.sorted(by: >).prefix(10))
        UserDefaults.standard.set(reactionScores, forKey: "ReactionModeScores")
        
        // Add to high scores (для совместимости)
        var scores = UserDefaults.standard.array(forKey: "AllHighScores") as? [Int] ?? []
        scores.append(currentScore)
        scores.sort(by: >)
        if scores.count > 10 {
            scores = Array(scores.prefix(10))
        }
        UserDefaults.standard.set(scores, forKey: "AllHighScores")
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        // Останавливаем все звуки
        stopAllSounds()
        
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
                // Стандартная анимация закрытия iOS
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Audio
    private func prepareAudioPlayer() {
        audioPlayer = SettingsManager.shared.createAudioPlayer()
        audioPlayer?.prepareToPlay()
    }
    
    private func playSound() {
        audioPlayer?.play()
    }
    
    private func stopAllSounds() {
        // Останавливаем audioPlayer
        audioPlayer?.stop()
        audioPlayer = nil
        
        // Останавливаем таймер
        reactionTimer?.invalidate()
        reactionTimer = nil
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
}
