import UIKit
import AVFoundation

class SurvivalModeViewController: UIViewController {
    
    private var switches: [UISwitch] = []
    private var circleIndicators: [UIView] = []
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var timeRemaining: Int = 30
    private var currentScore: Int = 0
    private var currentLevel: Int = 1
    private var correctCombination: [Bool] = []
    private var hasShownInstructions: Bool = false
    
    // Новые элементы для анимаций
    private var comboCount: Int = 0
    private var particleEmitters: [CAEmitterLayer] = []
    private var backgroundGradient: CAGradientLayer?
    private var pulseLayer: CAShapeLayer?
    
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
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = .systemGreen
        progress.trackTintColor = .systemGray5
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.progress = 0.0
        return progress
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Stats.score.localized(with: 0)
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Stats.time.localized(with: 30)
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Level.levelLogic.localized(with: 1)
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let bestScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SettingsManager.shared.applyBackground(to: view)
        setupCloseButton()
        setupUI()
        setupPulseEffect()
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
        stopAllSounds()
    }
    
    // MARK: - Dynamic Background Setup
    private func setupDynamicBackground() {
        // Сначала применяем базовый фон из настроек
        SettingsManager.shared.applyBackground(to: view)
        
        // Затем добавляем градиентный слой поверх
        backgroundGradient = CAGradientLayer()
        backgroundGradient?.frame = view.bounds
        backgroundGradient?.colors = [
            UIColor.systemBlue.withAlphaComponent(0.1).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.1).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.1).cgColor
        ]
        backgroundGradient?.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradient?.endPoint = CGPoint(x: 1, y: 1)
        view.layer.addSublayer(backgroundGradient!)
        
        // Анимируем градиент
        animateBackgroundGradient()
    }
    
    private func animateBackgroundGradient() {
        guard let gradient = backgroundGradient else { return }
        
        let animation = CABasicAnimation(keyPath: "colors")
        animation.duration = 3.0
        animation.repeatCount = .infinity
        animation.autoreverses = true
        
        let colors1 = [
            UIColor.systemBlue.withAlphaComponent(0.1).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.1).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.1).cgColor
        ]
        
        let colors2 = [
            UIColor.systemGreen.withAlphaComponent(0.1).cgColor,
            UIColor.systemOrange.withAlphaComponent(0.1).cgColor,
            UIColor.systemPink.withAlphaComponent(0.1).cgColor
        ]
        
        animation.fromValue = colors1
        animation.toValue = colors2
        
        gradient.add(animation, forKey: "colorAnimation")
    }
    
    // MARK: - Pulse Effect Setup
    private func setupPulseEffect() {
        pulseLayer = CAShapeLayer()
        pulseLayer?.frame = containerView.bounds
        pulseLayer?.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 20).cgPath
        pulseLayer?.fillColor = UIColor.clear.cgColor
        pulseLayer?.strokeColor = UIColor.systemGreen.withAlphaComponent(0.3).cgColor
        pulseLayer?.lineWidth = 3
        containerView.layer.addSublayer(pulseLayer!)
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        view.addSubview(progressView)
        view.addSubview(scoreLabel)
        view.addSubview(timerLabel)
        view.addSubview(levelLabel)
        view.addSubview(bestScoreLabel)
        
        // Устанавливаем текст рекорда
        bestScoreLabel.text = LocalizationManager.Stats.record.localized(with: getBestScore())
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 500),
            
            levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scoreLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 16),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            
            timerLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 16),
            timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            progressView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            bestScoreLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bestScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createCircleIndicators(count: Int) {
        // Удаляем существующие индикаторы
        circleIndicators.forEach { $0.removeFromSuperview() }
        circleIndicators.removeAll()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        for _ in 0..<count {
            let circle = UIView()
            circle.backgroundColor = .systemRed
            circle.layer.cornerRadius = 12
            circle.layer.shadowColor = UIColor.black.cgColor
            circle.layer.shadowOpacity = 0.2
            circle.layer.shadowOffset = CGSize.zero
            circle.layer.shadowRadius = 4
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.widthAnchor.constraint(equalToConstant: 24).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            stackView.addArrangedSubview(circle)
            circleIndicators.append(circle)
        }
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32)
        ])
    }
    
    private func createSwitches(count: Int) {
        // Удаляем существующие переключатели
        switches.forEach { $0.removeFromSuperview() }
        switches.removeAll()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        for _ in 0..<count {
            let mySwitch = UISwitch()
            mySwitch.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            mySwitch.onTintColor = SettingsManager.shared.switchColor
            mySwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            stackView.addArrangedSubview(mySwitch)
            switches.append(mySwitch)
        }
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 120)
        ])
    }
    
    private func generateNewLevel() {
        // Анимация исчезновения старых элементов
        animateElementsOut {
            // Генерируем случайное количество переключателей (от 3 до 6)
            let switchCount = Int.random(in: 3...6)
            
            // Генерируем случайную комбинацию
            self.correctCombination = (0..<switchCount).map { _ in Bool.random() }
            
            // Обновляем UI
            self.createCircleIndicators(count: switchCount)
            self.createSwitches(count: switchCount)
            
            // Обновляем метки
            self.levelLabel.text = LocalizationManager.Level.levelLogic.localized(with: self.currentLevel)
            self.scoreLabel.text = LocalizationManager.Stats.score.localized(with: self.currentScore)
            
            // Сбрасываем прогресс
            self.updateProgress(successCount: 0)
            
            // Анимация появления новых элементов
            self.animateElementsIn()
        }
    }
    
    // MARK: - Level Transition Animations
    private func animateElementsOut(completion: @escaping () -> Void) {
        let animationGroup = DispatchGroup()
        
        // Анимация исчезновения переключателей
        for (index, mySwitch) in switches.enumerated() {
            animationGroup.enter()
            UIView.animate(
                withDuration: 0.2,
                delay: Double(index) * 0.05,
                options: .curveEaseIn,
                animations: {
                    mySwitch.alpha = 0
                    mySwitch.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }
            ) { _ in
                animationGroup.leave()
            }
        }
        
        // Анимация исчезновения индикаторов
        for (index, circle) in circleIndicators.enumerated() {
            animationGroup.enter()
            UIView.animate(
                withDuration: 0.2,
                delay: Double(index) * 0.03,
                options: .curveEaseIn,
                animations: {
                    circle.alpha = 0
                    circle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }
            ) { _ in
                animationGroup.leave()
            }
        }
        
        animationGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func animateElementsIn() {
        // Анимация появления индикаторов
        for (index, circle) in circleIndicators.enumerated() {
            circle.alpha = 0
            circle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(
                withDuration: 0.4,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5
            ) {
                circle.alpha = 1
                circle.transform = .identity
            }
        }
        
        // Анимация появления переключателей
        for (index, mySwitch) in switches.enumerated() {
            mySwitch.alpha = 0
            mySwitch.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(
                withDuration: 0.5,
                delay: Double(index) * 0.1 + 0.2,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.8
            ) {
                mySwitch.alpha = 1
                mySwitch.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }
    }
    
    @objc private func switchChanged() {
        playSound()
        let currentCombination = switches.map { $0.isOn }
        
        let currentSuccessCount = zip(currentCombination, correctCombination)
            .filter { $0 == $1 }
            .count
        
        updateCircleIndicators(successCount: currentSuccessCount)
        updateProgress(successCount: currentSuccessCount)
        
        if currentSuccessCount == correctCombination.count {
            // Увеличиваем combo
            comboCount += 1
            
            // Начисляем очки в зависимости от количества переключателей и combo
            let basePoints = correctCombination.count * 5
            let comboBonus = comboCount > 1 ? (comboCount - 1) * 10 : 0
            currentScore += basePoints + comboBonus
            currentLevel += 1
            
            // Увеличиваем время на 3 секунды
            timeRemaining += 3
            
            // Запускаем праздничные анимации
            celebrateSuccess()
            
            // Обновляем UI с анимацией
            animateScoreUpdate()
            
            // Генерируем новый уровень с задержкой для анимации
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.generateNewLevel()
            }
        } else {
            // Сбрасываем combo если игрок ошибся
            comboCount = 0
        }
    }
    
    // MARK: - Success Celebration Animations
    private func celebrateSuccess() {
        // Анимация пульса контейнера
        animateSuccessPulse()
        
        // Партиклы
        createSuccessParticles()
        
        // Анимация переключателей
        animateSwitchesSuccess()
        
        // Встряска экрана
        animateScreenShake()
        
        // Вибрация
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Combo анимация
        if comboCount > 1 {
            showComboEffect()
        }
    }
    
    private func animateSuccessPulse() {
        guard let pulse = pulseLayer else { return }
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.1
        scaleAnimation.duration = 0.3
        scaleAnimation.autoreverses = true
        
        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.fromValue = UIColor.systemGreen.withAlphaComponent(0.3).cgColor
        colorAnimation.toValue = UIColor.systemYellow.withAlphaComponent(0.8).cgColor
        colorAnimation.duration = 0.3
        colorAnimation.autoreverses = true
        
        pulse.add(scaleAnimation, forKey: "successPulse")
        pulse.add(colorAnimation, forKey: "successColor")
    }
    
    private func createSuccessParticles() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: containerView.center.x, y: containerView.center.y)
        emitter.emitterShape = .point
        emitter.emitterSize = CGSize(width: 1, height: 1)
        
        let cell = CAEmitterCell()
        cell.birthRate = 100
        cell.lifetime = 2.0
        cell.velocity = 150
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.scale = 0.1
        cell.scaleRange = 0.05
        cell.contents = createStarImage()?.cgImage
        cell.color = UIColor.systemYellow.cgColor
        
        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        particleEmitters.append(emitter)
        
        // Удаляем эмиттер через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            emitter.removeFromSuperlayer()
            if let index = self.particleEmitters.firstIndex(of: emitter) {
                self.particleEmitters.remove(at: index)
            }
        }
    }
    
    private func createStarImage() -> UIImage? {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let path = UIBezierPath()
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius: CGFloat = 8
        
        for i in 0..<5 {
            let angle = CGFloat(i) * .pi * 2 / 5 - .pi / 2
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()
        
        UIColor.systemYellow.setFill()
        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func animateSwitchesSuccess() {
        for (index, mySwitch) in switches.enumerated() {
            UIView.animate(
                withDuration: 0.2,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.8
            ) {
                mySwitch.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    mySwitch.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }
            }
        }
    }
    
    private func animateScreenShake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 5, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 5, y: view.center.y))
        
        view.layer.add(animation, forKey: "shake")
    }
    
    private func showComboEffect() {
        let comboLabel = UILabel()
        comboLabel.text = "COMBO x\(comboCount)!"
        comboLabel.font = .systemFont(ofSize: 32, weight: .bold)
        comboLabel.textColor = .systemOrange
        comboLabel.textAlignment = .center
        comboLabel.alpha = 0
        comboLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        view.addSubview(comboLabel)
        comboLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            comboLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comboLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100)
        ])
        
        UIView.animate(withDuration: 0.5, animations: {
            comboLabel.alpha = 1
            comboLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.5, animations: {
                comboLabel.alpha = 0
                comboLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { _ in
                comboLabel.removeFromSuperview()
            }
        }
    }
    
    private func animateScoreUpdate() {
        // Анимация увеличения счета
        UIView.transition(with: scoreLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.scoreLabel.text = LocalizationManager.Stats.score.localized(with: self.currentScore)
        }
        
        UIView.transition(with: timerLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.timerLabel.text = LocalizationManager.Stats.time.localized(with: self.timeRemaining)
        }
        
        // Пульсация счета
        UIView.animate(withDuration: 0.2, animations: {
            self.scoreLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.scoreLabel.transform = .identity
            }
        }
    }
    
    private func updateCircleIndicators(successCount: Int) {
        for (index, circle) in circleIndicators.enumerated() {
            UIView.animate(withDuration: 0.3, delay: Double(index) * 0.05, options: .curveEaseOut) {
                circle.backgroundColor = index < successCount ? .systemGreen : .systemRed
                circle.transform = index < successCount ? 
                    CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
                
                // Добавляем свечение для правильных
                if index < successCount {
                    circle.layer.shadowColor = UIColor.systemGreen.cgColor
                    circle.layer.shadowOpacity = 0.6
                    circle.layer.shadowRadius = 8
                } else {
                    circle.layer.shadowOpacity = 0.2
                    circle.layer.shadowRadius = 4
                }
            }
        }
    }
    
    private func updateProgress(successCount: Int) {
        let progress = Float(successCount) / Float(correctCombination.count)
        UIView.animate(withDuration: 0.3) {
            self.progressView.progress = progress
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 1
            self.updateTimerDisplay()
            
            // Предупреждения о времени
            if self.timeRemaining == 10 {
                self.showTimeWarning(message: "⚠️ 10 секунд!")
            } else if self.timeRemaining == 5 {
                self.showTimeWarning(message: "🚨 5 секунд!")
                self.animateUrgentTimer()
            }
            
            if self.timeRemaining <= 0 {
                self.gameOver()
            }
        }
    }
    
    private func updateTimerDisplay() {
        let color: UIColor = timeRemaining <= 10 ? .systemRed : .label
        
        UIView.transition(with: timerLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.timerLabel.text = LocalizationManager.Stats.time.localized(with: self.timeRemaining)
            self.timerLabel.textColor = color
        }
        
        // Пульсация при малом времени
        if timeRemaining <= 5 && timeRemaining > 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.timerLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    self.timerLabel.transform = .identity
                }
            }
        }
    }
    
    private func showTimeWarning(message: String) {
        let warningLabel = UILabel()
        warningLabel.text = message
        warningLabel.font = .systemFont(ofSize: 28, weight: .bold)
        warningLabel.textColor = .systemRed
        warningLabel.textAlignment = .center
        warningLabel.alpha = 0
        warningLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        view.addSubview(warningLabel)
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -20)
        ])
        
        // Анимация появления и исчезновения
        UIView.animate(withDuration: 0.3, animations: {
            warningLabel.alpha = 1
            warningLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 1.0, animations: {
                warningLabel.alpha = 0
                warningLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { _ in
                warningLabel.removeFromSuperview()
            }
        }
        
        // Вибрация
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func animateUrgentTimer() {
        guard let gradient = backgroundGradient else { return }
        
        // Мигающий красный фон при критическом времени
        let animation = CABasicAnimation(keyPath: "colors")
        animation.duration = 0.5
        animation.repeatCount = 3
        animation.autoreverses = true
        
        let urgentColors = [
            UIColor.systemRed.withAlphaComponent(0.2).cgColor,
            UIColor.systemOrange.withAlphaComponent(0.2).cgColor,
            UIColor.systemYellow.withAlphaComponent(0.1).cgColor
        ]
        
        animation.toValue = urgentColors
        gradient.add(animation, forKey: "urgentAnimation")
    }
    
    private func gameOver() {
        timer?.invalidate()
        timer = nil
        
        // Сохраняем рекорд для режима выживания
        saveBestScore()
        
        let alert = UIAlertController(
            title: LocalizationManager.GameOver.title.localized,
            message: LocalizationManager.GameOver.score.localized(with: currentScore),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: LocalizationManager.GameOver.newGame.localized, style: .default) { [weak self] _ in
            self?.resetGame()
        })
        
        alert.addAction(UIAlertAction(title: LocalizationManager.GameOver.mainMenu.localized, style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func resetGame() {
        currentScore = 0
        currentLevel = 1
        timeRemaining = 30
        comboCount = 0
        
        // Очищаем все партиклы
        particleEmitters.forEach { $0.removeFromSuperlayer() }
        particleEmitters.removeAll()
        
        // Сбрасываем цвет таймера
        timerLabel.textColor = .label
        
        generateNewLevel()
        startTimer()
    }
    
    private func getBestScore() -> Int {
        return UserDefaults.standard.integer(forKey: "SurvivalModeHighScore")
    }
    
    private func saveBestScore() {
        let currentBest = getBestScore()
        if currentScore > currentBest {
            UserDefaults.standard.set(currentScore, forKey: "SurvivalModeHighScore")
            bestScoreLabel.text = LocalizationManager.Stats.record.localized(with: currentScore)
        }
        
        // Добавляем в список рекордов режима выживания
        var survivalScores = UserDefaults.standard.array(forKey: "SurvivalModeScores") as? [Int] ?? []
        survivalScores.append(currentScore)
        // Оставляем только топ-10 рекордов
        survivalScores = Array(survivalScores.sorted(by: >).prefix(10))
        UserDefaults.standard.set(survivalScores, forKey: "SurvivalModeScores")
    }
    
    private func saveSurvivalModeScore() {
        let defaults = UserDefaults.standard
        
        // Сохраняем лучший результат для режима выживания
        let currentHighScore = defaults.integer(forKey: "SurvivalModeHighScore")
        if currentScore > currentHighScore {
            defaults.set(currentScore, forKey: "SurvivalModeHighScore")
        }
        
        // Добавляем в общий список рекордов режима выживания
        var survivalScores = defaults.array(forKey: "SurvivalModeScores") as? [Int] ?? []
        survivalScores.append(currentScore)
        // Оставляем только топ-10 рекордов
        survivalScores = Array(survivalScores.sorted(by: >).prefix(10))
        defaults.set(survivalScores, forKey: "SurvivalModeScores")
    }
    
    private func prepareAudioPlayer() {
        audioPlayer = SettingsManager.shared.createAudioPlayer()
        audioPlayer?.prepareToPlay()
    }
    
    private func playSound() {
        audioPlayer?.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Обновляем размер градиента при изменении размера view
        backgroundGradient?.frame = view.bounds
    }
    
//    deinit {
//        timer?.invalidate()
//    }
    
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
        iconLabel.text = "⚡"
        iconLabel.font = .systemFont(ofSize: 32)
        
        let titleLabel = UILabel()
        titleLabel.text = LocalizationManager.Instructions.survivalTitle.localized
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = R.Colors.green
        
        titleStackView.addArrangedSubview(iconLabel)
        titleStackView.addArrangedSubview(titleLabel)
        
        // Описание цели
        let goalView = createInfoBlock(
            icon: "🎯",
            title: LocalizationManager.Instructions.goalTitle.localized,
            description: LocalizationManager.Instructions.survivalGoal.localized
        )
        
        // Правила
        let rulesView = createInfoBlock(
            icon: "📋",
            title: LocalizationManager.Instructions.rulesTitle.localized,
            description: LocalizationManager.Instructions.survivalRules.localized
        )
        
        // Предупреждение
        let warningView = createInfoBlock(
            icon: "⚠️",
            title: LocalizationManager.Instructions.warningTitle.localized,
            description: LocalizationManager.Instructions.survivalWarning.localized
        )
        
        // Совет
        let tipView = createInfoBlock(
            icon: "💡",
            title: LocalizationManager.Instructions.tipTitle.localized,
            description: LocalizationManager.Instructions.survivalTip.localized
        )
        
        // Кнопки
        let buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        
        let startButton = createModernButton(title: LocalizationManager.Instructions.buttonStart.localized, isPrimary: true)
        startButton.addTarget(self, action: #selector(instructionsStartButtonTapped), for: .touchUpInside)
        
        let backButton = createModernButton(title: LocalizationManager.Instructions.buttonBack.localized, isPrimary: false)
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
            self.generateNewLevel()
            self.startTimer()
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
    
    private func stopAllSounds() {
        // Останавливаем audioPlayer
        audioPlayer?.stop()
        audioPlayer = nil
    }
} 
 
