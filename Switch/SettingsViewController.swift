import UIKit
import AVFoundation

class SettingsViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Settings.title.localized
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Card Views
    private let colorCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let soundCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let backgroundCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let previewCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()
    
    // MARK: - Switch Color Section
    private let switchColorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Settings.switchColorTitle.localized
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let switchColorSubtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Settings.switchColorSubtitle.localized
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
   
    private var colorCircles: [UIView] = []
    private var selectedColorIndex: Int = 0
    
    private let colorCirclesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Sound Section
    private let soundLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Settings.soundTitle.localized
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let soundSubtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Settings.soundSubtitle.localized
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let soundSegmentedControl: UISegmentedControl = {
        let items = [
            LocalizationManager.Settings.soundClassic.localized,
            LocalizationManager.Settings.soundElectronic.localized,
            LocalizationManager.Settings.soundCrunch.localized,
            LocalizationManager.Settings.soundNone.localized
        ]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        return control
    }()
    
    // MARK: - Background Section
    private let backgroundLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Settings.backgroundTitle.localized
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let backgroundSubtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Settings.backgroundSubtitle.localized
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let backgroundSegmentedControl: UISegmentedControl = {
        let items = [
            LocalizationManager.Settings.backgroundLight.localized,
            LocalizationManager.Settings.backgroundDark.localized,
            LocalizationManager.Settings.backgroundGradient.localized,
            LocalizationManager.Settings.backgroundSystem.localized
        ]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        return control
    }()
    
    // MARK: - Preview Section
    private let previewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Settings.previewTitle.localized
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let previewSubtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.Settings.previewSubtitle.localized
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let previewSwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        mySwitch.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
        mySwitch.layer.shadowColor = UIColor.black.cgColor
        mySwitch.layer.shadowOpacity = 0.15
        mySwitch.layer.shadowOffset = CGSize(width: 0, height: 2)
        mySwitch.layer.shadowRadius = 4
        return mySwitch
    }()
    
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        loadSettings()
        setupActions()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Добавляем заголовок
        contentView.addSubview(titleLabel)
        
        // Добавляем карточки с контентом
        contentView.addSubview(colorCard)
        colorCard.addSubview(switchColorLabel)
        colorCard.addSubview(switchColorSubtitle)
        colorCard.addSubview(colorCirclesStackView)
        
        contentView.addSubview(soundCard)
        soundCard.addSubview(soundLabel)
        soundCard.addSubview(soundSubtitle)
        soundCard.addSubview(soundSegmentedControl)
        
        contentView.addSubview(backgroundCard)
        backgroundCard.addSubview(backgroundLabel)
        backgroundCard.addSubview(backgroundSubtitle)
        backgroundCard.addSubview(backgroundSegmentedControl)
        
        contentView.addSubview(previewCard)
        previewCard.addSubview(previewLabel)
        previewCard.addSubview(previewSubtitle)
        previewCard.addSubview(previewSwitch)
        
       
        
        setupColorCircles()
        
        previewSwitch.addTarget(self, action: #selector(previewSwitchChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Color Card
            colorCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            colorCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            colorCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            switchColorLabel.topAnchor.constraint(equalTo: colorCard.topAnchor, constant: 20),
            switchColorLabel.leadingAnchor.constraint(equalTo: colorCard.leadingAnchor, constant: 20),
            switchColorLabel.trailingAnchor.constraint(equalTo: colorCard.trailingAnchor, constant: -20),
            
            switchColorSubtitle.topAnchor.constraint(equalTo: switchColorLabel.bottomAnchor, constant: 4),
            switchColorSubtitle.leadingAnchor.constraint(equalTo: colorCard.leadingAnchor, constant: 20),
            switchColorSubtitle.trailingAnchor.constraint(equalTo: colorCard.trailingAnchor, constant: -20),
            
            colorCirclesStackView.topAnchor.constraint(equalTo: switchColorSubtitle.bottomAnchor, constant: 20),
            colorCirclesStackView.centerXAnchor.constraint(equalTo: colorCard.centerXAnchor),
            colorCirclesStackView.heightAnchor.constraint(equalToConstant: 40),
            colorCirclesStackView.bottomAnchor.constraint(equalTo: colorCard.bottomAnchor, constant: -20),
            
            // Sound Card
            soundCard.topAnchor.constraint(equalTo: colorCard.bottomAnchor, constant: 16),
            soundCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            soundCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            soundLabel.topAnchor.constraint(equalTo: soundCard.topAnchor, constant: 20),
            soundLabel.leadingAnchor.constraint(equalTo: soundCard.leadingAnchor, constant: 20),
            soundLabel.trailingAnchor.constraint(equalTo: soundCard.trailingAnchor, constant: -20),
            
            soundSubtitle.topAnchor.constraint(equalTo: soundLabel.bottomAnchor, constant: 4),
            soundSubtitle.leadingAnchor.constraint(equalTo: soundCard.leadingAnchor, constant: 20),
            soundSubtitle.trailingAnchor.constraint(equalTo: soundCard.trailingAnchor, constant: -20),
            
            soundSegmentedControl.topAnchor.constraint(equalTo: soundSubtitle.bottomAnchor, constant: 16),
            soundSegmentedControl.leadingAnchor.constraint(equalTo: soundCard.leadingAnchor, constant: 20),
            soundSegmentedControl.trailingAnchor.constraint(equalTo: soundCard.trailingAnchor, constant: -20),
            soundSegmentedControl.bottomAnchor.constraint(equalTo: soundCard.bottomAnchor, constant: -20),
            
            // Background Card
            backgroundCard.topAnchor.constraint(equalTo: soundCard.bottomAnchor, constant: 16),
            backgroundCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backgroundCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            backgroundLabel.topAnchor.constraint(equalTo: backgroundCard.topAnchor, constant: 20),
            backgroundLabel.leadingAnchor.constraint(equalTo: backgroundCard.leadingAnchor, constant: 20),
            backgroundLabel.trailingAnchor.constraint(equalTo: backgroundCard.trailingAnchor, constant: -20),
            
            backgroundSubtitle.topAnchor.constraint(equalTo: backgroundLabel.bottomAnchor, constant: 4),
            backgroundSubtitle.leadingAnchor.constraint(equalTo: backgroundCard.leadingAnchor, constant: 20),
            backgroundSubtitle.trailingAnchor.constraint(equalTo: backgroundCard.trailingAnchor, constant: -20),
            
            backgroundSegmentedControl.topAnchor.constraint(equalTo: backgroundSubtitle.bottomAnchor, constant: 16),
            backgroundSegmentedControl.leadingAnchor.constraint(equalTo: backgroundCard.leadingAnchor, constant: 20),
            backgroundSegmentedControl.trailingAnchor.constraint(equalTo: backgroundCard.trailingAnchor, constant: -20),
            backgroundSegmentedControl.bottomAnchor.constraint(equalTo: backgroundCard.bottomAnchor, constant: -20),
            
            // Preview Card
            previewCard.topAnchor.constraint(equalTo: backgroundCard.bottomAnchor, constant: 20),
            previewCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            previewCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            previewCard.heightAnchor.constraint(equalToConstant: 170),
            
            previewLabel.topAnchor.constraint(equalTo: previewCard.topAnchor, constant: 24),
            previewLabel.centerXAnchor.constraint(equalTo: previewCard.centerXAnchor),
            
            previewSubtitle.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 6),
            previewSubtitle.centerXAnchor.constraint(equalTo: previewCard.centerXAnchor),
            
            previewSwitch.topAnchor.constraint(equalTo: previewSubtitle.bottomAnchor, constant: 20),
            previewSwitch.centerXAnchor.constraint(equalTo: previewCard.centerXAnchor),
            
            // Bottom constraint for contentView
            contentView.bottomAnchor.constraint(equalTo: previewCard.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupColorCircles() {
        let colors: [UIColor] = [R.Colors.blue, R.Colors.green, R.Colors.red, R.Colors.purple, R.Colors.pink, R.Colors.orange]
        
        for (index, color) in colors.enumerated() {
            let circleView = UIView()
            circleView.translatesAutoresizingMaskIntoConstraints = false
            circleView.backgroundColor = color
            circleView.layer.cornerRadius = 20
            circleView.layer.borderWidth = 3
            circleView.layer.borderColor = UIColor.clear.cgColor
            circleView.tag = index
            
            // Добавляем тень для красивого эффекта
            circleView.layer.shadowColor = color.cgColor
            circleView.layer.shadowOpacity = 0.4
            circleView.layer.shadowOffset = CGSize(width: 0, height: 2)
            circleView.layer.shadowRadius = 4
            
            NSLayoutConstraint.activate([
                circleView.widthAnchor.constraint(equalToConstant: 40),
                circleView.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            // Добавляем tap gesture
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(colorCircleTapped(_:)))
            circleView.addGestureRecognizer(tapGesture)
            circleView.isUserInteractionEnabled = true
            
            colorCirclesStackView.addArrangedSubview(circleView)
            colorCircles.append(circleView)
        }
        
        // Выбираем первый цвет по умолчанию
        selectColorCircle(at: 0)
    }
    
    private func selectColorCircle(at index: Int) {
        // Сбрасываем все кружки
        for circle in colorCircles {
            circle.layer.borderColor = UIColor.clear.cgColor
            circle.transform = .identity
        }
        
        // Выделяем выбранный кружок
        if index < colorCircles.count {
            let selectedCircle = colorCircles[index]
            selectedCircle.layer.borderColor = UIColor.label.cgColor
            selectedCircle.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        
        selectedColorIndex = index
        updateSwitchColor()
    }
    
    @objc private func colorCircleTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }
        let index = tappedView.tag
        
        // Добавляем haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Анимация нажатия
        UIView.animate(withDuration: 0.1, animations: {
            tappedView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.selectColorCircle(at: index)
            }
        }
        
        // Сохраняем выбор и отправляем уведомление
        SettingsManager.shared.setSwitchColor(index: index)
    }
    
    private func setupActions() {
        soundSegmentedControl.addTarget(self, action: #selector(soundChanged), for: .valueChanged)
        backgroundSegmentedControl.addTarget(self, action: #selector(backgroundChanged), for: .valueChanged)
    }
    
    private func loadSettings() {
        // Загружаем сохраненные настройки
        let defaults = UserDefaults.standard
        let savedColorIndex = defaults.integer(forKey: "SwitchColor")
        soundSegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "SwitchSound")
        backgroundSegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "BackgroundStyle")
        
        // Применяем настройки
        selectColorCircle(at: savedColorIndex)
        updateBackground()
    }
    
    @objc private func soundChanged() {
        UserDefaults.standard.set(soundSegmentedControl.selectedSegmentIndex, forKey: "SwitchSound")
    }
    
    @objc private func backgroundChanged() {
        updateBackground()
        UserDefaults.standard.set(backgroundSegmentedControl.selectedSegmentIndex, forKey: "BackgroundStyle")
    }
    
    @objc private func previewSwitchChanged() {
        // Добавляем анимацию при переключении
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.previewSwitch.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        } completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.previewSwitch.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            }
        }
        
        // Добавляем haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        playSound()
    }
    
    private func updateSwitchColor() {
        let colors: [UIColor] = [R.Colors.blue, R.Colors.green, R.Colors.red, R.Colors.purple, R.Colors.pink, R.Colors.orange]
        let selectedColor = colors[selectedColorIndex]
        previewSwitch.onTintColor = selectedColor
    }
    
    private func updateBackground() {
        switch backgroundSegmentedControl.selectedSegmentIndex {
        case 0: // Светлый
            view.backgroundColor = R.Colors.whiteBg
            //containerView.backgroundColor = .white
        case 1: // Темный
            view.backgroundColor = R.Colors.darkBg
           // containerView.backgroundColor = .systemGray6
        case 2: // Градиент
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [R.Colors.breezeBg, R.Colors.iceBg]
            view.layer.insertSublayer(gradientLayer, at: 0)
            //containerView.backgroundColor = .white
        case 3: // Системный
            view.backgroundColor = R.Colors.purpleBg
            //containerView.backgroundColor = .systemBackground
        default:
            break
        }
    }
    
    private func playSound() {
        let soundNames = ["switchSound", "cosmo", "hrust"]
        let selectedSound = soundSegmentedControl.selectedSegmentIndex
        
        if selectedSound < soundNames.count {
            guard let soundURL = Bundle.main.url(forResource: soundNames[selectedSound], withExtension: "mp3") else {
                print("Sound file not found.")
                return
            }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Unable to play sound: \(error.localizedDescription)")
            }
        }
    }
    
} 
