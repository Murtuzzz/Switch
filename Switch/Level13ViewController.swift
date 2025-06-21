import UIKit
import AVFoundation

class Level13ViewController: UIViewController {
    
    private var lightButtons: [UIButton] = []
    private var sequence: [Int] = []
    private var playerSequence: [Int] = []
    private var currentLevel: Int = 1
    private var audioPlayer: AVAudioPlayer?
    private var levelLabel: UILabel!
    private var instructionsLabel: UILabel!
    private var circleIndicators: [UIView] = []
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsManager.shared.applyBackground(to: view)
        setupCloseButton()
        setupUI()
        prepareAudioPlayer()
        startNewLevel()
    }
    
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
        levelLabel.text = "Уровень 13"
        levelLabel.font = .systemFont(ofSize: 24, weight: .bold)
        levelLabel.textColor = .label
        view.addSubview(levelLabel)
        
        instructionsLabel = UILabel()
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.text = "Запомните последовательность"
        instructionsLabel.font = .systemFont(ofSize: 18, weight: .medium)
        instructionsLabel.textColor = .label
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        view.addSubview(instructionsLabel)
        
        createCircleIndicators()
        createLightButtons()
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 400),
            
            levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            progressView.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            instructionsLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            instructionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func createCircleIndicators() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        for _ in 0..<4 {
            let circle = UIView()
            circle.backgroundColor = .systemRed
            circle.layer.cornerRadius = 10
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.widthAnchor.constraint(equalToConstant: 20).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 20).isActive = true
            stackView.addArrangedSubview(circle)
            circleIndicators.append(circle)
        }
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 16)
        ])
    }
    
    private func createLightButtons() {
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
            button.layer.cornerRadius = 15
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.2
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            button.addTarget(self, action: #selector(lightButtonTapped), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.isEnabled = false // Изначально отключены
            buttonsStack.addArrangedSubview(button)
            lightButtons.append(button)
        }
        
        NSLayoutConstraint.activate([
            buttonsStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buttonsStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            buttonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            buttonsStack.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func startNewLevel() {
        instructionsLabel.text = "Запомните последовательность!\nУровень \(currentLevel)"
        playerSequence = []
        sequence = generateSequence(length: currentLevel + 2)
        disableButtons()
        updateProgress()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.playSequence()
        }
    }
    
    private func generateSequence(length: Int) -> [Int] {
        var newSequence: [Int] = []
        for _ in 0..<length {
            newSequence.append(Int.random(in: 0..<4))
        }
        return newSequence
    }
    
    private func playSequence() {
        var delay: TimeInterval = 0.0
        for (index, buttonTag) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.highlightButton(buttonTag)
                self.playSound()
            }
            delay += 0.6 // Light up duration + pause
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
            self.instructionsLabel.text = "Ваш ход!"
            self.enableButtons()
        }
    }
    
    private func highlightButton(_ tag: Int) {
        guard tag < lightButtons.count else { return }
        let button = lightButtons[tag]
        let originalColor = button.backgroundColor
        
        // Разные цвета для каждой платформы
        let highlightColors: [UIColor] = [
            .systemRed,    // Красный для первой платформы
            .systemGreen,  // Зеленый для второй платформы
            .systemBlue,   // Синий для третьей платформы
            .systemPurple  // Фиолетовый для четвертой платформы
        ]
        
        UIView.animate(withDuration: 0.3, animations: {
            button.backgroundColor = highlightColors[tag]
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                button.backgroundColor = originalColor
                button.transform = .identity
            }
        }
    }
    
    @objc private func lightButtonTapped(_ sender: UIButton) {
        // Дополнительная проверка, что кнопки включены и sequence не пуст
        guard !sequence.isEmpty && sender.isEnabled else { return }
        
        playSound()
        
        // Те же цвета, что и при демонстрации
        let highlightColors: [UIColor] = [
            .systemRed,    // Красный для первой платформы
            .systemGreen,  // Зеленый для второй платформы
            .systemBlue,   // Синий для третьей платформы
            .systemPurple  // Фиолетовый для четвертой платформы
        ]
        
        // Анимация нажатия
        UIView.animate(withDuration: 0.1, animations: {
            sender.backgroundColor = highlightColors[sender.tag]
            sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                sender.backgroundColor = .lightGray
                sender.transform = .identity
            }
        }
        
        playerSequence.append(sender.tag)
        checkPlayerInput()
    }
    
    private func checkPlayerInput() {
        // Проверяем, что sequence не пуст и индекс не выходит за границы
        guard !sequence.isEmpty, playerSequence.count <= sequence.count else {
            instructionsLabel.text = "Неверно! Попробуйте снова."
            disableButtons()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.resetLevel()
            }
            return
        }
        
        for i in 0..<playerSequence.count {
            if i >= sequence.count || playerSequence[i] != sequence[i] {
                instructionsLabel.text = "Неверно! Попробуйте снова."
                updateCircleIndicators(isCorrect: false, at: i)
                disableButtons()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.resetLevel()
                }
                return
            }
        }
        
        updateCircleIndicators(isCorrect: true, at: playerSequence.count - 1)
        
        if playerSequence.count == sequence.count {
            instructionsLabel.text = "Верно!"
            disableButtons()
            currentLevel += 1
            updateProgress()
            
            if currentLevel > 6 {
                // Переход на следующий уровень после прохождения всех 6 уровней
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    let level14VC = Level14ViewController()
                    level14VC.modalPresentationStyle = .fullScreen
                    self.present(level14VC, animated: true)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.startNewLevel()
                }
            }
        }
    }
    
    private func updateCircleIndicators(isCorrect: Bool, at index: Int) {
        guard index < circleIndicators.count else { return }
        UIView.animate(withDuration: 0.3) {
            self.circleIndicators[index].backgroundColor = isCorrect ? .systemGreen : .systemRed
            self.circleIndicators[index].transform = isCorrect ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
        }
    }
    
    private func updateProgress() {
        let totalLevels = 6 // Всего 6 уровней
        let progress = Float(currentLevel - 1) / Float(totalLevels)
        UIView.animate(withDuration: 0.3) {
            self.progressView.progress = progress
        }
    }
    
    private func enableButtons() {
        lightButtons.forEach { $0.isEnabled = true }
    }
    
    private func disableButtons() {
        lightButtons.forEach { $0.isEnabled = false }
    }
    
    private func resetLevel() {
        playerSequence = []
        sequence = []
        lightButtons.forEach { $0.backgroundColor = .lightGray }
        circleIndicators.forEach { $0.backgroundColor = .systemRed }
        instructionsLabel.text = "Запомните последовательность!\nУровень \(currentLevel)"
        updateProgress()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startNewLevel()
        }
    }
    
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
       // closeButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
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
