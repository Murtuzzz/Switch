import UIKit
import AVFoundation

class Level10ViewController: UIViewController {
    
    private var switches: [UISwitch] = []
    private var slider: UISlider!
    private var stepper: UIStepper!
    private var circleIndicators: [UIView] = []
    private var audioPlayer: AVAudioPlayer?
    private var levelLabel: UILabel!
    private var sliderLabel: UILabel!
    private var stepperLabel: UILabel!
    
    private var targetSwitchStates: [Bool] = [true, false]
    private var targetSliderValue: Float = 0.75
    private var targetStepperValue: Double = 3.0
    private let sliderTolerance: Float = 0.05
    
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
        resetControls()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        view.addSubview(progressView)
        
        // Настройка метки уровня
        levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.text = "Уровень 10"
        levelLabel.font = .systemFont(ofSize: 24, weight: .bold)
        levelLabel.textColor = .label
        view.addSubview(levelLabel)
        
        createCircleIndicators()
        createControls()
        
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
        
        for _ in 0..<4 {
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
    
    private func createControls() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        // Switches
        let switchesStack = UIStackView()
        switchesStack.axis = .horizontal
        switchesStack.spacing = 32
        switchesStack.distribution = .equalSpacing
        switchesStack.translatesAutoresizingMaskIntoConstraints = false
        
        for _ in 0..<2 {
            let switchControl = UISwitch()
            switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            switchesStack.addArrangedSubview(switchControl)
            switches.append(switchControl)
        }
        
        // Slider
        let sliderContainer = UIView()
        sliderContainer.translatesAutoresizingMaskIntoConstraints = false
        
        slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        sliderContainer.addSubview(slider)
        
        sliderLabel = UILabel()
        sliderLabel.text = "0%"
        sliderLabel.font = .systemFont(ofSize: 18, weight: .medium)
        sliderLabel.textAlignment = .center
        sliderLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderContainer.addSubview(sliderLabel)
        
        NSLayoutConstraint.activate([
            slider.centerYAnchor.constraint(equalTo: sliderContainer.centerYAnchor),
            slider.leadingAnchor.constraint(equalTo: sliderContainer.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: sliderLabel.leadingAnchor, constant: -16),
            
            sliderLabel.centerYAnchor.constraint(equalTo: sliderContainer.centerYAnchor),
            sliderLabel.widthAnchor.constraint(equalToConstant: 60),
            sliderLabel.trailingAnchor.constraint(equalTo: sliderContainer.trailingAnchor),
            
            sliderContainer.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Stepper
        let stepperContainer = UIView()
        stepperContainer.translatesAutoresizingMaskIntoConstraints = false
        
        stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 5
        stepper.stepValue = 1
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepperContainer.addSubview(stepper)
        
        stepperLabel = UILabel()
        stepperLabel.text = "0"
        stepperLabel.font = .systemFont(ofSize: 18, weight: .medium)
        stepperLabel.textAlignment = .center
        stepperLabel.translatesAutoresizingMaskIntoConstraints = false
        stepperContainer.addSubview(stepperLabel)
        
        NSLayoutConstraint.activate([
            stepper.centerYAnchor.constraint(equalTo: stepperContainer.centerYAnchor),
            stepper.leadingAnchor.constraint(equalTo: stepperContainer.leadingAnchor),
            
            stepperLabel.centerYAnchor.constraint(equalTo: stepperContainer.centerYAnchor),
            stepperLabel.leadingAnchor.constraint(equalTo: stepper.trailingAnchor, constant: 16),
            stepperLabel.widthAnchor.constraint(equalToConstant: 40),
            
            stepperContainer.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        stackView.addArrangedSubview(switchesStack)
        stackView.addArrangedSubview(sliderContainer)
        stackView.addArrangedSubview(stepperContainer)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32)
        ])
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        playSound()
        checkProgress()
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        playSound()
        let percentage = Int(sender.value * 100)
        sliderLabel.text = "\(percentage)%"
        checkProgress()
    }
    
    @objc private func stepperValueChanged(_ sender: UIStepper) {
        playSound()
        stepperLabel.text = "\(Int(sender.value))"
        checkProgress()
    }
    
    private func checkProgress() {
        let switchSuccess = zip(switches.map { $0.isOn }, targetSwitchStates)
            .filter { $0 == $1 }
            .count
        
        let sliderSuccess = abs(slider.value - targetSliderValue) <= sliderTolerance ? 1 : 0
        let stepperSuccess = stepper.value == targetStepperValue ? 1 : 0
        
        let totalSuccess = switchSuccess + sliderSuccess + stepperSuccess
        updateCircleIndicators(successCount: totalSuccess)
        updateProgress(successCount: totalSuccess)
        
        if totalSuccess == 4 {
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
        let progress = Float(successCount) / 4.0
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
                let level11VC = Level11ViewController()
                level11VC.modalPresentationStyle = .fullScreen
                self.present(level11VC, animated: true)
            }
        }
//        UIView.animate(withDuration: 0.3, animations: {
//            self.containerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
//        }) { _ in
//            UIView.animate(withDuration: 0.2) {
//                self.containerView.transform = .identity
//            } completion: { _ in
//                let alert = UIAlertController(
//                    title: "Поздравляем!",
//                    message: "Вы прошли все уровни!",
//                    preferredStyle: .alert
//                    
//                )
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true)
//                
//                
//            }
////            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
////                rootViewController.dismiss(animated: true, completion: nil)
////            }
//        }
    }
    
    private func resetControls() {
        switches.forEach { $0.isOn = false }
        slider.value = 0
        sliderLabel.text = "0%"
        stepper.value = 0
        stepperLabel.text = "0"
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
