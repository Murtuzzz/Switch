import UIKit
import AVFoundation

class Level8ViewController: UIViewController {
    
    private var steppers: [UIStepper] = []
    private var valueLabels: [UILabel] = []
    private var circleIndicators: [UIView] = []
    private var audioPlayer: AVAudioPlayer?
    private var levelLabel: UILabel!
    private var targetValues: [Double] = [3.0, 2.0, 4.0]
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsManager.shared.applyBackground(to: view)
        setupCloseButton()
        setupUI()
        prepareAudioPlayer()
        resetSteppers()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        view.addSubview(progressView)
        
        // Настройка метки уровня
        levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.text = "Уровень 8"
        levelLabel.font = .systemFont(ofSize: 24, weight: .bold)
        levelLabel.textColor = .label
        view.addSubview(levelLabel)
        
        createCircleIndicators()
        createSteppers()
        
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
            progressView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    private func createCircleIndicators() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        for _ in 0..<3 {
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
    
    private func createSteppers() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        for _ in 0..<3 {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            
            let stepper = UIStepper()
            stepper.minimumValue = 0
            stepper.maximumValue = 5
            stepper.stepValue = 1
            stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
            stepper.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(stepper)
            steppers.append(stepper)
            
            let label = UILabel()
            label.text = "0"
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            valueLabels.append(label)
            
            NSLayoutConstraint.activate([
                stepper.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                stepper.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: stepper.trailingAnchor, constant: 16),
                label.widthAnchor.constraint(equalToConstant: 40),
                
                container.heightAnchor.constraint(equalToConstant: 44)
            ])
            
            stackView.addArrangedSubview(container)
        }
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32)
        ])
    }
    
    @objc private func stepperValueChanged(_ sender: UIStepper) {
        playSound()
        if let index = steppers.firstIndex(of: sender) {
            valueLabels[index].text = "\(Int(sender.value))"
        }
        
        let currentValues = steppers.map { $0.value }
        let currentSuccessCount = zip(currentValues, targetValues)
            .filter { $0 == $1 }
            .count
        
        updateCircleIndicators(successCount: currentSuccessCount)
        updateProgress(successCount: currentSuccessCount)
        
        if currentSuccessCount == targetValues.count {
            animateSuccess()
        }
    }
    
    private func updateCircleIndicators(successCount: Int) {
        for (index, circle) in circleIndicators.enumerated() {
            UIView.animate(withDuration: 0.3) {
                circle.backgroundColor = index < successCount ? .systemGreen : .systemRed
                circle.transform = index < successCount ? 
                    CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
            }
        }
    }
    
    private func updateProgress(successCount: Int) {
        let progress = Float(successCount) / Float(targetValues.count)
        UIView.animate(withDuration: 0.3) {
            self.progressView.progress = progress
        }
    }
    
    private func animateSuccess() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = .identity
            } completion: { _ in
                let level9VC = Level9ViewController()
                level9VC.modalPresentationStyle = .fullScreen
                self.present(level9VC, animated: true)
            }
        }
    }
    
    private func resetSteppers() {
        steppers.forEach { $0.value = 0 }
        valueLabels.forEach { $0.text = "0" }
        updateCircleIndicators(successCount: 0)
        updateProgress(successCount: 0)
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
