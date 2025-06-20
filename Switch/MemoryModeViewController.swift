import UIKit
import AVFoundation

class MemoryModeViewController: UIViewController {
    
    private var gameButtons: [UIButton] = []
    private var sequence: [Int] = []
    private var playerSequence: [Int] = []
    private var currentLevel: Int = 1
    private var currentScore: Int = 0
    private var gameMode: GameMode = .sequence
    private var audioPlayer: AVAudioPlayer?
    private var hasShownInstructions: Bool = false
    
    // UI Elements
    private var levelLabel: UILabel!
    private var scoreLabel: UILabel!
    private var instructionsLabel: UILabel!
    private var progressView: UIProgressView!
    private var modeSwitch: UISegmentedControl!
    
    private enum GameMode: Int, CaseIterable {
        case sequence = 0
        case pattern = 1
        
        var title: String {
            switch self {
            case .sequence: return "Последовательность"
            case .pattern: return "Паттерн"
            }
        }
        
        var buttonCount: Int {
            switch self {
            case .sequence: return 4
            case .pattern: return 9
            }
        }
    }
    
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
    
    private func setupUI() {
        view.addSubview(containerView)
        
        // Score and Level Labels
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Счет: 0"
        scoreLabel.font = .systemFont(ofSize: 20, weight: .bold)
        scoreLabel.textColor = .label
        view.addSubview(scoreLabel)
        
        levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.text = "Уровень: 1"
        levelLabel.font = .systemFont(ofSize: 20, weight: .bold)
        levelLabel.textColor = .label
        view.addSubview(levelLabel)
        
        // Progress Bar
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .systemGreen
        progressView.trackTintColor = .systemGray5
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.progress = 0.0
        view.addSubview(progressView)
        
        // Mode Switch
        modeSwitch = UISegmentedControl(items: GameMode.allCases.map { $0.title })
        modeSwitch.translatesAutoresizingMaskIntoConstraints = false
        modeSwitch.selectedSegmentIndex = 0
        modeSwitch.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        view.addSubview(modeSwitch)
        
        // Instructions
        instructionsLabel = UILabel()
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.text = "Режим Память - бесконечная игра"
        instructionsLabel.font = .systemFont(ofSize: 16, weight: .medium)
        instructionsLabel.textColor = .label
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        view.addSubview(instructionsLabel)
        
        setupConstraints()
        createGameButtons()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            containerView.heightAnchor.constraint(equalToConstant: 380),
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            
            levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //levelLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            progressView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            modeSwitch.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            modeSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            instructionsLabel.topAnchor.constraint(equalTo: modeSwitch.bottomAnchor, constant: 16),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func createGameButtons() {
        // Clear existing buttons
        gameButtons.forEach { $0.removeFromSuperview() }
        gameButtons.removeAll()
        
        switch gameMode {
        case .sequence:
            createSequenceButtons()
        case .pattern:
            createPatternGrid()
        }
    }
    
    private func createSequenceButtons() {
        let buttonsStack = UIStackView()
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 20
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonsStack)
        
        for i in 0..<4 {
            let button = UIButton(type: .system)
            button.tag = i
            button.backgroundColor = .lightGray
            button.layer.cornerRadius = 20
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.2
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            button.addTarget(self, action: #selector(gameButtonTapped), for: .touchUpInside)
            buttonsStack.addArrangedSubview(button)
            gameButtons.append(button)
        }
        
        NSLayoutConstraint.activate([
            buttonsStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buttonsStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            buttonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            buttonsStack.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func createPatternGrid() {
        let gridStack = UIStackView()
        gridStack.axis = .vertical
        gridStack.spacing = 12
        gridStack.distribution = .fillEqually
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(gridStack)
        
        for row in 0..<3 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.distribution = .fillEqually
            gridStack.addArrangedSubview(rowStack)
            
            for col in 0..<3 {
                let button = UIButton(type: .system)
                button.tag = row * 3 + col
                button.backgroundColor = .lightGray
                button.layer.cornerRadius = 15
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.2
                button.layer.shadowOffset = CGSize(width: 0, height: 2)
                button.layer.shadowRadius = 4
                button.addTarget(self, action: #selector(gameButtonTapped), for: .touchUpInside)
                rowStack.addArrangedSubview(button)
                gameButtons.append(button)
            }
        }
        
        NSLayoutConstraint.activate([
            gridStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            gridStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            gridStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            gridStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            gridStack.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    @objc private func modeChanged() {
        gameMode = GameMode(rawValue: modeSwitch.selectedSegmentIndex) ?? .sequence
        createGameButtons()
        startNewGame()
    }
    
    private func startNewGame() {
        currentLevel = 1
        currentScore = 0
        updateLabels()
        startNewLevel()
    }
    
    private func startNewLevel() {
        playerSequence = []
        
        // Увеличиваем сложность каждые 5 уровней
        let sequenceLength = min(2 + currentLevel, gameMode.buttonCount)
        sequence = generateSequence(length: sequenceLength)
        
        disableButtons()
        updateProgress()
        updateLabels()
        
        instructionsLabel.text = "Запомните \(gameMode.title.lowercased())!\nУровень \(currentLevel)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.playSequence()
        }
    }
    
    private func generateSequence(length: Int) -> [Int] {
        var newSequence: [Int] = []
        for _ in 0..<length {
            newSequence.append(Int.random(in: 0..<gameMode.buttonCount))
        }
        return newSequence
    }
    
    private func playSequence() {
        var delay: TimeInterval = 0.0
        let speed = max(0.4, 0.8 - Double(currentLevel) * 0.05) // Ускоряется с уровнем
        
        for buttonTag in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.highlightButton(buttonTag)
                self.playSound()
            }
            delay += speed
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
            self.instructionsLabel.text = "Ваш ход! Повторите последовательность"
            self.enableButtons()
        }
    }
    
    private func highlightButton(_ tag: Int) {
        guard tag < gameButtons.count else { return }
        let button = gameButtons[tag]
        let originalColor = button.backgroundColor
        
        let highlightColors: [UIColor] = [
            .systemRed, .systemGreen, .systemBlue, .systemPurple,
            .systemOrange, .systemPink, .systemTeal, .systemIndigo, .systemYellow
        ]
        
        let highlightColor = highlightColors[min(tag, highlightColors.count - 1)]
        
        UIView.animate(withDuration: 0.3, animations: {
            button.backgroundColor = highlightColor
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                button.backgroundColor = originalColor
                button.transform = .identity
            }
        }
    }
    
    @objc private func gameButtonTapped(_ sender: UIButton) {
        let buttonTag = sender.tag
        playerSequence.append(buttonTag)
        
        // Добавляем эффект нажатия
        animateButtonPress(sender)
        
        highlightButton(buttonTag)
        playSound()
        
        // Проверяем правильность до сих пор
        if playerSequence.count <= sequence.count {
            for i in 0..<playerSequence.count {
                if playerSequence[i] != sequence[i] {
                    // Эффект ошибки
                    animateButtonError(sender)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.gameOver()
                    }
                    return
                }
            }
            
            updateProgress()
            
            // Если последовательность завершена правильно
            if playerSequence.count == sequence.count {
                levelCompleted()
            }
        }
    }
    
    private func levelCompleted() {
        // Начисляем очки
        let basePoints = sequence.count * 10
        let levelBonus = currentLevel * 5
        let modeBonus = gameMode == .pattern ? 5 : 0
        currentScore += basePoints + levelBonus + modeBonus
        
        // Проверяем комбо для больших последовательностей
        if sequence.count >= 10 && sequence.count % 5 == 0 {
            let comboMultiplier = sequence.count / 5
            let comboBonus = comboMultiplier * 50
            currentScore += comboBonus
            showComboEffect(combo: comboMultiplier)
        }
        
        disableButtons()
        
        instructionsLabel.text = "Отлично! +\(basePoints + levelBonus + modeBonus) очков"
        
        // Празднование успеха
        celebrateSuccess()
        
        currentLevel += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.startNewLevel()
        }
    }
    
    private func celebrateSuccess() {
        // Анимация контейнера с пружинящим эффектом
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.containerView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.containerView.transform = .identity
            }
        }
        
        // Анимируем кнопки
        animateButtonsSuccess()
        
        // Анимируем labels
        animateLabelsSuccess()
        
        // Встряска экрана
        animateScreenShake()
        
        // Радужный фон
        animateRainbowBackground()
        
        // Вибрация
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Показываем эффект "+ОЧКИ"
        showScorePopup()
    }
    
    private func animateButtonsSuccess() {
        for (index, button) in gameButtons.enumerated() {
            UIView.animate(
                withDuration: 0.3,
                delay: Double(index) * 0.05,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.8
            ) {
                button.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    button.transform = .identity
                }
            }
        }
    }
    
    private func animateLabelsSuccess() {
        // Анимация score label
        UIView.animate(withDuration: 0.3, animations: {
            self.scoreLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.scoreLabel.textColor = .systemGreen
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.scoreLabel.transform = .identity
                self.scoreLabel.textColor = .label
            }
        }
        
        // Пульсация progress bar
        UIView.animate(withDuration: 0.2, animations: {
            self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.progressView.transform = .identity
            }
        }
    }
    
    private func animateScreenShake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 3, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 3, y: view.center.y))
        
        view.layer.add(animation, forKey: "shake")
    }
    
    private func showScorePopup() {
        let basePoints = sequence.count * 10
        let levelBonus = currentLevel * 5
        let modeBonus = gameMode == .pattern ? 5 : 0
        let totalPoints = basePoints + levelBonus + modeBonus
        
        let popupLabel = UILabel()
        popupLabel.text = "+\(totalPoints)"
        popupLabel.font = .systemFont(ofSize: 36, weight: .bold)
        popupLabel.textColor = .systemYellow
        popupLabel.textAlignment = .center
        popupLabel.alpha = 0
        popupLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        // Добавляем обводку для лучшей видимости
        popupLabel.layer.shadowColor = UIColor.black.cgColor
        popupLabel.layer.shadowOpacity = 0.8
        popupLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        popupLabel.layer.shadowRadius = 2
        
        view.addSubview(popupLabel)
        popupLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80)
        ])
        
        // Анимация появления
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            popupLabel.alpha = 1
            popupLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            // Анимация исчезновения
            UIView.animate(withDuration: 0.3, delay: 0.8, animations: {
                popupLabel.alpha = 0
                popupLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).translatedBy(x: 0, y: -50)
            }) { _ in
                popupLabel.removeFromSuperview()
            }
        }
    }
    
    private func animateRainbowBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        let colors = [
            R.Colors.purple.cgColor,
            UIColor.systemYellow.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemOrange.cgColor,
            UIColor.systemIndigo.cgColor,
            UIColor.systemBlue.cgColor,
            UIColor.systemPurple.cgColor
        ]
        
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.opacity = 0
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Анимация появления радуги
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0
        fadeInAnimation.toValue = 0.3
        fadeInAnimation.duration = 0.5
        fadeInAnimation.fillMode = .forwards
        fadeInAnimation.isRemovedOnCompletion = false
        
        gradientLayer.add(fadeInAnimation, forKey: "fadeIn")
        
        // Анимация исчезновения через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
            fadeOutAnimation.fromValue = 0.3
            fadeOutAnimation.toValue = 0
            fadeOutAnimation.duration = 0.8
            fadeOutAnimation.fillMode = .forwards
            fadeOutAnimation.isRemovedOnCompletion = false
            
            gradientLayer.add(fadeOutAnimation, forKey: "fadeOut")
            
            // Удаляем слой после анимации
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                gradientLayer.removeFromSuperlayer()
            }
        }
    }
    
    private func showComboEffect(combo: Int) {
        let comboLabel = UILabel()
        comboLabel.text = "КОМБО x\(combo)!"
        comboLabel.font = .systemFont(ofSize: 42, weight: .black)
        comboLabel.textColor = .systemOrange
        comboLabel.textAlignment = .center
        comboLabel.alpha = 0
        comboLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        // Добавляем яркую обводку
        comboLabel.layer.shadowColor = UIColor.systemRed.cgColor
        comboLabel.layer.shadowOpacity = 1.0
        comboLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        comboLabel.layer.shadowRadius = 10
        
        view.addSubview(comboLabel)
        comboLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            comboLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comboLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120)
        ])
        
        // Взрывная анимация появления
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.2) {
            comboLabel.alpha = 1
            comboLabel.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        } completion: { _ in
            // Пульсация
            UIView.animate(withDuration: 0.3, delay: 0, options: [.repeat, .autoreverse], animations: {
                comboLabel.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            }) { _ in
                // Исчезновение
                UIView.animate(withDuration: 0.4, delay: 0.5, animations: {
                    comboLabel.alpha = 0
                    comboLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).translatedBy(x: 0, y: -100)
                }) { _ in
                    comboLabel.removeFromSuperview()
                }
            }
        }
        
        // Дополнительная вибрация для комбо
        let heavyFeedback = UIImpactFeedbackGenerator(style: .heavy)
        heavyFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            heavyFeedback.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            heavyFeedback.impactOccurred()
        }
    }
    
    private func animateButtonPress(_ button: UIButton) {
        // Пульсирующий эффект нажатия
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            button.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
                button.alpha = 1.0
            }
        }
        
        // Эффект свечения
        let glowLayer = CALayer()
        glowLayer.frame = button.bounds
        glowLayer.backgroundColor = UIColor.systemBlue.cgColor
        glowLayer.cornerRadius = button.layer.cornerRadius
        glowLayer.opacity = 0
        
        button.layer.insertSublayer(glowLayer, at: 0)
        
        let glowAnimation = CABasicAnimation(keyPath: "opacity")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = 0.3
        glowAnimation.duration = 0.2
        glowAnimation.autoreverses = true
        glowAnimation.fillMode = .removed
        
        glowLayer.add(glowAnimation, forKey: "glow")
        
        // Удаляем glow layer после анимации
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            glowLayer.removeFromSuperlayer()
        }
    }
    
    private func animateButtonError(_ button: UIButton) {
        // Тряска кнопки
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = 3
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: button.center.x - 5, y: button.center.y))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: button.center.x + 5, y: button.center.y))
        
        button.layer.add(shakeAnimation, forKey: "shake")
        
        // Красное свечение для ошибки
        let errorLayer = CALayer()
        errorLayer.frame = button.bounds
        errorLayer.backgroundColor = UIColor.systemRed.cgColor
        errorLayer.cornerRadius = button.layer.cornerRadius
        errorLayer.opacity = 0
        
        button.layer.insertSublayer(errorLayer, at: 0)
        
        let errorAnimation = CABasicAnimation(keyPath: "opacity")
        errorAnimation.fromValue = 0
        errorAnimation.toValue = 0.5
        errorAnimation.duration = 0.15
        errorAnimation.autoreverses = true
        errorAnimation.repeatCount = 3
        errorAnimation.fillMode = .removed
        
        errorLayer.add(errorAnimation, forKey: "error")
        
        // Удаляем error layer после анимации
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            errorLayer.removeFromSuperlayer()
        }
        
        // Вибрация ошибки
        let errorFeedback = UINotificationFeedbackGenerator()
        errorFeedback.notificationOccurred(.error)
    }
    
    private func gameOver() {
        disableButtons()
        
        instructionsLabel.text = "Игра окончена!"
        
        // Сохраняем рекорд
        saveHighScore()
        
        let alert = UIAlertController(
            title: "Игра окончена",
            message: "Уровень: \(currentLevel)\nСчет: \(currentScore)\n\nМожете гордиться своей памятью!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Новая игра", style: .default) { _ in
            self.startNewGame()
        })
        
        alert.addAction(UIAlertAction(title: "В главное меню", style: .default) { _ in
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func saveHighScore() {
        let defaults = UserDefaults.standard
        let currentHighScore = defaults.integer(forKey: "MemoryModeHighScore")
        
        if currentScore > currentHighScore {
            defaults.set(currentScore, forKey: "MemoryModeHighScore")
            defaults.set(currentLevel, forKey: "MemoryModeHighLevel")
        }
        
        // Добавляем в список рекордов режима памяти
        var memoryScores = defaults.array(forKey: "MemoryModeScores") as? [Int] ?? []
        memoryScores.append(currentScore)
        // Оставляем только топ-10 рекордов
        memoryScores = Array(memoryScores.sorted(by: >).prefix(10))
        defaults.set(memoryScores, forKey: "MemoryModeScores")
        
        // Добавляем в общий список рекордов (для совместимости)
        var scores = defaults.array(forKey: "HighScores") as? [Int] ?? []
        scores.append(currentScore)
        scores.sort { $0 > $1 }
        scores = Array(scores.prefix(10)) // Оставляем топ 10
        defaults.set(scores, forKey: "HighScores")
    }
    
    private func updateLabels() {
        scoreLabel.text = "Счет: \(currentScore)"
        levelLabel.text = "Уровень: \(currentLevel)"
    }
    
    private func updateProgress() {
        let progress = Float(playerSequence.count) / Float(sequence.count)
        UIView.animate(withDuration: 0.3) {
            self.progressView.progress = progress
        }
    }
    
    private func enableButtons() {
        gameButtons.forEach { $0.isEnabled = true }
    }
    
    private func disableButtons() {
        gameButtons.forEach { $0.isEnabled = false }
    }
    
    private func prepareAudioPlayer() {
        audioPlayer = SettingsManager.shared.createAudioPlayer()
        audioPlayer?.prepareToPlay()
    }
    
    private func playSound() {
        audioPlayer?.play()
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
        iconLabel.text = "🧠"
        iconLabel.font = .systemFont(ofSize: 32)
        
        let titleLabel = UILabel()
        titleLabel.text = "Режим Память"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = R.Colors.green
        
        titleStackView.addArrangedSubview(iconLabel)
        titleStackView.addArrangedSubview(titleLabel)
        
        // Описание цели
        let goalView = createInfoBlock(
            icon: "🎯",
            title: "Цель",
            description: "Запомните и повторите последовательность!"
        )
        
        // Правила
        let rulesView = createInfoBlock(
            icon: "📋",
            title: "Правила",
            description: """
            • Запомните последовательность подсвеченных кнопок
            • Повторите её в том же порядке
            • Каждый уровень добавляет новую кнопку
            • Выберите режим: Последовательность (4 кнопки) или Паттерн (9 кнопок)
            """
        )
        
        // Предупреждение
        let warningView = createInfoBlock(
            icon: "⚠️",
            title: "Внимание",
            description: "Одна ошибка = конец игры"
        )
        
        // Совет
        let tipView = createInfoBlock(
            icon: "💡",
            title: "Совет",
            description: "Тренируйте зрительную память и концентрацию!"
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
            self.startNewGame()
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
                // Стандартная анимация закрытия iOS
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
 
 
