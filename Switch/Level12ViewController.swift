import UIKit
import AVFoundation

class Level12ViewController: UIViewController {
    
    private var redSlider: UISlider!
    private var greenSlider: UISlider!
    private var blueSlider: UISlider!
    private var redLabel: UILabel!
    private var greenLabel: UILabel!
    private var blueLabel: UILabel!
    private var currentColorView: UIView!
    private var targetColorView: UIView!
    private var circleIndicators: [UIView] = []
    private var audioPlayer: AVAudioPlayer?
    private var levelLabel: UILabel!
    
    private let targetRed: Float = 0.5 // Target RGB values
    private let targetGreen: Float = 0.8
    private let targetBlue: Float = 0.2
    private let tolerance: Float = 0.05 // Tolerance for each component
    
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
        resetLevel()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        view.addSubview(progressView)
        
        levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.text = LocalizationManager.Levels.level12.localized
        levelLabel.font = .systemFont(ofSize: 24, weight: .bold)
        levelLabel.textColor = .label
        view.addSubview(levelLabel)
        
        createCircleIndicators()
        createColorViews()
        createControls()
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 550),
            
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
    
    private func createColorViews() {
        let colorViewsStack = UIStackView()
        colorViewsStack.axis = .horizontal
        colorViewsStack.spacing = 20
        colorViewsStack.distribution = .fillEqually
        colorViewsStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(colorViewsStack)
        
        targetColorView = UIView()
        targetColorView.backgroundColor = UIColor(red: CGFloat(targetRed), green: CGFloat(targetGreen), blue: CGFloat(targetBlue), alpha: 1.0)
        targetColorView.layer.cornerRadius = 10
        targetColorView.translatesAutoresizingMaskIntoConstraints = false
        colorViewsStack.addArrangedSubview(targetColorView)
        
        currentColorView = UIView()
        currentColorView.backgroundColor = .black
        currentColorView.layer.cornerRadius = 10
        currentColorView.translatesAutoresizingMaskIntoConstraints = false
        colorViewsStack.addArrangedSubview(currentColorView)
        
        let targetLabel = UILabel()
        targetLabel.text = LocalizationManager.ColorGame.target.localized
        targetLabel.font = .systemFont(ofSize: 14, weight: .medium)
        targetLabel.textColor = .label
        targetLabel.textAlignment = .center
        targetLabel.translatesAutoresizingMaskIntoConstraints = false
        targetColorView.addSubview(targetLabel)
        
        let currentLabel = UILabel()
        currentLabel.text = LocalizationManager.ColorGame.yourColor.localized
        currentLabel.font = .systemFont(ofSize: 14, weight: .medium)
        currentLabel.textColor = .label
        currentLabel.textAlignment = .center
        currentLabel.translatesAutoresizingMaskIntoConstraints = false
        currentColorView.addSubview(currentLabel)
        
        NSLayoutConstraint.activate([
            targetColorView.heightAnchor.constraint(equalToConstant: 100),
            currentColorView.heightAnchor.constraint(equalToConstant: 100),
            
            targetLabel.centerXAnchor.constraint(equalTo: targetColorView.centerXAnchor),
            targetLabel.centerYAnchor.constraint(equalTo: targetColorView.centerYAnchor),
            
            currentLabel.centerXAnchor.constraint(equalTo: currentColorView.centerXAnchor),
            currentLabel.centerYAnchor.constraint(equalTo: currentColorView.centerYAnchor),
            
            colorViewsStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 80),
            colorViewsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            colorViewsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32)
        ])
    }
    
    private func createControls() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        // Red control
        let redContainer = createColorControlContainer(
            label: "Красный",
            slider: &redSlider,
            valueLabel: &redLabel,
            color: .systemRed
        )
        
        // Green control
        let greenContainer = createColorControlContainer(
            label: "Зеленый",
            slider: &greenSlider,
            valueLabel: &greenLabel,
            color: .systemGreen
        )
        
        // Blue control
        let blueContainer = createColorControlContainer(
            label: "Синий",
            slider: &blueSlider,
            valueLabel: &blueLabel,
            color: .systemBlue
        )
        
        stackView.addArrangedSubview(redContainer)
        stackView.addArrangedSubview(greenContainer)
        stackView.addArrangedSubview(blueContainer)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: currentColorView.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32)
        ])
    }
    
    private func createColorControlContainer(label: String, slider: inout UISlider!, valueLabel: inout UILabel!, color: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = label
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)
        
        slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.minimumTrackTintColor = color
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(slider)
        
        valueLabel = UILabel()
        valueLabel.text = "0.00"
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 80),
            
            slider.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 16),
            slider.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            slider.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor, constant: -16),
            
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueLabel.widthAnchor.constraint(equalToConstant: 50),
            
            container.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        playSound()
        
        if sender == redSlider {
            redLabel.text = String(format: "%.2f", sender.value)
        } else if sender == greenSlider {
            greenLabel.text = String(format: "%.2f", sender.value)
        } else if sender == blueSlider {
            blueLabel.text = String(format: "%.2f", sender.value)
        }
        
        updateCurrentColor()
        checkProgress()
    }
    
    private func updateCurrentColor() {
        let red = CGFloat(redSlider.value)
        let green = CGFloat(greenSlider.value)
        let blue = CGFloat(blueSlider.value)
        currentColorView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    private func checkProgress() {
        var successCount = 0
        
        let isRedCorrect = abs(redSlider.value - targetRed) <= tolerance
        let isGreenCorrect = abs(greenSlider.value - targetGreen) <= tolerance
        let isBlueCorrect = abs(blueSlider.value - targetBlue) <= tolerance
        
        if isRedCorrect { successCount += 1 }
        if isGreenCorrect { successCount += 1 }
        if isBlueCorrect { successCount += 1 }
        
        updateCircleIndicators(isRedCorrect: isRedCorrect, isGreenCorrect: isGreenCorrect, isBlueCorrect: isBlueCorrect)
        updateProgress(successCount: successCount)
        
        if successCount == 3 {
            animateSuccess()
        }
    }
    
    private func updateCircleIndicators(isRedCorrect: Bool, isGreenCorrect: Bool, isBlueCorrect: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.circleIndicators[0].backgroundColor = isRedCorrect ? .systemGreen : .systemRed
            self.circleIndicators[0].transform = isRedCorrect ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
            
            self.circleIndicators[1].backgroundColor = isGreenCorrect ? .systemGreen : .systemRed
            self.circleIndicators[1].transform = isGreenCorrect ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
            
            self.circleIndicators[2].backgroundColor = isBlueCorrect ? .systemGreen : .systemRed
            self.circleIndicators[2].transform = isBlueCorrect ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
        }
    }
    
    private func updateProgress(successCount: Int) {
        let progress = Float(successCount) / 3.0
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
                let level13VC = Level13ViewController()
                level13VC.modalPresentationStyle = .fullScreen
                self.present(level13VC, animated: true)
            }
        }
    }
    
    private func resetLevel() {
        redSlider.value = 0.0
        greenSlider.value = 0.0
        blueSlider.value = 0.0
        redLabel.text = "0.00"
        greenLabel.text = "0.00"
        blueLabel.text = "0.00"
        updateCurrentColor()
        updateCircleIndicators(isRedCorrect: false, isGreenCorrect: false, isBlueCorrect: false)
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
