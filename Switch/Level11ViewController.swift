import UIKit
import AVFoundation

class Level11ViewController: UIViewController {
    
    private var frequencySlider: UISlider!
    private var amplitudeSlider: UISlider!
    private var frequencyLabel: UILabel!
    private var amplitudeLabel: UILabel!
    private var waveView: UIView!
    private var targetWaveView: UIView!
    private var circleIndicators: [UIView] = []
    private var audioPlayer: AVAudioPlayer?
    private var levelLabel: UILabel!
    private var displayLink: CADisplayLink?
    
    private let targetFrequency: Float = 2.0
    private let targetAmplitude: Float = 2.0
    private let tolerance: Float = 0.1
    
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
        startWaveAnimation()
        resetSliders()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        view.addSubview(progressView)
        
        levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.text = "Уровень 11"
        levelLabel.font = .systemFont(ofSize: 24, weight: .bold)
        levelLabel.textColor = .label
        view.addSubview(levelLabel)
        
        createCircleIndicators()
        createWaveViews()
        createControls()
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 500),
            
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
        
        for _ in 0..<2 {
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
    
    private func createWaveViews() {
        // Target wave view
        targetWaveView = UIView()
        targetWaveView.translatesAutoresizingMaskIntoConstraints = false
        targetWaveView.backgroundColor = .systemGray5
        targetWaveView.layer.cornerRadius = 10
        containerView.addSubview(targetWaveView)
        
        // Current wave view
        waveView = UIView()
        waveView.translatesAutoresizingMaskIntoConstraints = false
        waveView.backgroundColor = .systemBlue
        waveView.layer.cornerRadius = 10
        containerView.addSubview(waveView)
        
        NSLayoutConstraint.activate([
            targetWaveView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 80),
            targetWaveView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            targetWaveView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            targetWaveView.heightAnchor.constraint(equalToConstant: 100),
            
            waveView.topAnchor.constraint(equalTo: targetWaveView.bottomAnchor, constant: 32),
            waveView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            waveView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            waveView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func createControls() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        // Frequency control
        let frequencyContainer = createControlContainer(
            label: "Частота",
            slider: &frequencySlider,
            valueLabel: &frequencyLabel
        )
        
        // Amplitude control
        let amplitudeContainer = createControlContainer(
            label: "Амплитуда",
            slider: &amplitudeSlider,
            valueLabel: &amplitudeLabel
        )
        
        stackView.addArrangedSubview(frequencyContainer)
        stackView.addArrangedSubview(amplitudeContainer)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: waveView.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32)
        ])
    }
    
    private func createControlContainer(label: String, slider: inout UISlider!, valueLabel: inout UILabel!) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = label
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)
        
        slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 5
        slider.value = 0
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(slider)
        
        valueLabel = UILabel()
        valueLabel.text = "0.0"
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
            valueLabel.widthAnchor.constraint(equalToConstant: 40),
            
            container.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        playSound()
        
        if sender == frequencySlider {
            frequencyLabel.text = String(format: "%.1f", sender.value)
        } else {
            amplitudeLabel.text = String(format: "%.1f", sender.value)
        }
        
        checkProgress()
    }
    
    private func startWaveAnimation() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateWave() {
        let time = CACurrentMediaTime()
        
        // Update target wave
        updateWaveView(targetWaveView, frequency: targetFrequency, amplitude: targetAmplitude, time: time)
        
        // Update current wave
        updateWaveView(waveView, frequency: frequencySlider.value, amplitude: amplitudeSlider.value, time: time)
    }
    
    private func updateWaveView(_ view: UIView, frequency: Float, amplitude: Float, time: Double) {
        let path = UIBezierPath()
        let width = view.bounds.width
        let height = view.bounds.height
        let centerY = height / 2
        
        path.move(to: CGPoint(x: 0, y: centerY))
        
        for x in stride(from: 0, through: width, by: 1) {
            // Calculate y based on x, frequency, amplitude, and time for animation
            let waveY = centerY + (sin((Double(x) / Double(width) * Double(frequency) * 2 * .pi) + time) * (Double(amplitude) / 5.0) * (height / 2.0))
            path.addLine(to: CGPoint(x: x, y: waveY))
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        
        // Set contrasting stroke color based on the view
        if view == targetWaveView {
            shapeLayer.strokeColor = UIColor.black.cgColor
        } else if view == waveView {
            shapeLayer.strokeColor = UIColor.white.cgColor
        }
        
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 2
        
        view.layer.sublayers?.removeAll(where: { $0 is CAShapeLayer })
        view.layer.addSublayer(shapeLayer)
    }
    
    private func checkProgress() {
        var successCount = 0
        
        if abs(frequencySlider.value - targetFrequency) <= tolerance {
            successCount += 1
        }
        
        if abs(amplitudeSlider.value - targetAmplitude) <= tolerance {
            successCount += 1
        }
        
        updateCircleIndicators(successCount: successCount)
        updateProgress(successCount: successCount)
        
        if successCount == 2 {
            animateSuccess()
        }
    }
    
    private func updateCircleIndicators(successCount: Int) {
        // Update based on individual correctness, not just total successCount
        let isFrequencyCorrect = abs(frequencySlider.value - targetFrequency) <= tolerance
        let isAmplitudeCorrect = abs(amplitudeSlider.value - targetAmplitude) <= tolerance
        
        UIView.animate(withDuration: 0.3) {
            self.circleIndicators[0].backgroundColor = isFrequencyCorrect ? .systemGreen : .systemRed
            self.circleIndicators[0].transform = isFrequencyCorrect ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
            
            self.circleIndicators[1].backgroundColor = isAmplitudeCorrect ? .systemGreen : .systemRed
            self.circleIndicators[1].transform = isAmplitudeCorrect ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
        }
    }
    
    private func updateProgress(successCount: Int) {
        let progress = Float(successCount) / 2.0
        UIView.animate(withDuration: 0.3) {
            self.progressView.progress = progress
        }
    }
    
    private func animateSuccess() {
        displayLink?.invalidate()
        displayLink = nil
        
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = .identity
            } completion: { _ in
               let level12VC = Level12ViewController()
               level12VC.modalPresentationStyle = .fullScreen
               self.present(level12VC, animated: true)
            }
        }
    }
    
    private func resetSliders() {
        frequencySlider.value = 0.0
        amplitudeSlider.value = 0.0
        frequencyLabel.text = "0.0"
        amplitudeLabel.text = "0.0"
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
    
    deinit {
        displayLink?.invalidate()
    }
} 

