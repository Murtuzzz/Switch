//
//  MainViewController.swift
//  Switch
//
//  Created by Мурат Кудухов on 21.08.2024.
//

import UIKit

final class MainViewController: UIViewController {
    
    // MARK: - Brand Colors (matching the logo)
    private let brandGreen = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0) // #2ecc71
    private let brandGray = UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1.0) // #9E9E9E
    private let brandCream = UIColor(red: 245/255, green: 245/255, blue: 220/255, alpha: 1.0) // #F5F5DC
    
    // MARK: - Animated Background
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0).cgColor,
            UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1.0).cgColor,
            UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0).cgColor
        ]
        layer.locations = [0.0, 0.5, 1.0]
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        return layer
    }()
    
    private var floatingViews: [UIView] = []
    
    // Добавляем логотип переключателя с анимацией
    private let logoSwitch: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: -50)
        
        // Фон переключателя с градиентом
        let background = UIView()
        background.layer.cornerRadius = 30
        background.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем градиент к фону
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [
            UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0).cgColor,
            UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0).cgColor
        ]
        backgroundGradient.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 1, y: 1)
        backgroundGradient.cornerRadius = 30
        background.layer.insertSublayer(backgroundGradient, at: 0)
        
        // Белый кружок с улучшенными тенями
        let thumb = UIView()
        thumb.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 220/255, alpha: 1.0)
        thumb.layer.cornerRadius = 25
        thumb.layer.shadowColor = UIColor.black.cgColor
        thumb.layer.shadowOpacity = 0.25
        thumb.layer.shadowOffset = CGSize(width: 0, height: 4)
        thumb.layer.shadowRadius = 8
        thumb.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(background)
        containerView.addSubview(thumb)
        
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: containerView.topAnchor),
            background.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            background.widthAnchor.constraint(equalToConstant: 100),
            background.heightAnchor.constraint(equalToConstant: 60),
            
            thumb.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            thumb.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -5),
            thumb.widthAnchor.constraint(equalToConstant: 50),
            thumb.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Анимация градиента для фона
        DispatchQueue.main.async {
            backgroundGradient.frame = CGRect(x: 0, y: 0, width: 100, height: 60)
        }
        
        return containerView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "SWITCH"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0)
        label.alpha = 0
        label.transform = CGAffineTransform(translationX: 0, y: -30)
        
        // Добавляем тень к тексту
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.1
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowRadius = 4
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationManager.MainScreen.subtitle.localized
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor(red: 120/255, green: 120/255, blue: 120/255, alpha: 1.0)
        label.alpha = 0
        label.transform = CGAffineTransform(translationX: 0, y: -20)
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(LocalizationManager.MainScreen.startGame.localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.tintColor = .white
        button.layer.cornerRadius = 28
        button.alpha = 0
        button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Glassmorphism эффект
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowRadius = 20
        
        return button
    }()
    
    private let survivalButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(LocalizationManager.MainScreen.survivalMode.localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 28
        button.alpha = 0
        button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Glassmorphism эффект
        button.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 15
        
        return button
    }()
    
    private let memoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(LocalizationManager.MainScreen.memoryMode.localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 28
        button.alpha = 0
        button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Glassmorphism эффект
        button.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 15
        
        return button
    }()
    
    private let reactionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(LocalizationManager.MainScreen.reactionMode.localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 28
        button.alpha = 0
        button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Glassmorphism эффект
        button.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 15
        
        return button
    }()
    
    private let trophyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let trophyImage = UIImage(systemName: "trophy.fill", withConfiguration: config)
        button.setImage(trophyImage, for: .normal)
        
        button.layer.cornerRadius = 30
        button.alpha = 0
        button.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        // Glassmorphism эффект
        button.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 20
        
        return button
    }()

    private let gearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let gearImage = UIImage(systemName: "gearshape.fill", withConfiguration: config)
        button.setImage(gearImage, for: .normal)
        
        button.layer.cornerRadius = 30
        button.alpha = 0
        button.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        // Glassmorphism эффект
        button.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 20
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBackgroundParticles()
        setupNotifications()
        updateColorsFromSettings()
        animateGradientBackground()
        
        // Анимации запускаем в конце, чтобы не влиять на touch events
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.animateElements()
            self.startFloatingAnimations()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateColorsFromSettings()
        
        // Убеждаемся, что кнопки всегда доступны для касания
        DispatchQueue.main.async {
            self.trophyButton.isUserInteractionEnabled = true
            self.gearButton.isUserInteractionEnabled = true
            self.view.bringSubviewToFront(self.trophyButton)
            self.view.bringSubviewToFront(self.gearButton)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Перезапускаем анимации при каждом появлении главного меню
        restartAnimations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopAllAnimations()
    }
    
    private func setupUI() {
        // Добавляем градиентный фон
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.addSubview(logoSwitch)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(startButton)
        view.addSubview(survivalButton)
        view.addSubview(memoryButton)
        view.addSubview(reactionButton)
        view.addSubview(trophyButton)
        view.addSubview(gearButton)
        
        startButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
        survivalButton.addTarget(self, action: #selector(survivalButtonAction), for: .touchUpInside)
        memoryButton.addTarget(self, action: #selector(memoryButtonAction), for: .touchUpInside)
        reactionButton.addTarget(self, action: #selector(reactionButtonAction), for: .touchUpInside)
        trophyButton.addTarget(self, action: #selector(trophyButtonAction), for: .touchUpInside)
        gearButton.addTarget(self, action: #selector(gearButtonAction), for: .touchUpInside)
        
        // Добавляем эффект нажатия для кнопок
        [startButton, survivalButton, memoryButton, reactionButton, trophyButton, gearButton].forEach { button in
            button.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
        
        constraints()
        
        // Убеждаемся, что кнопки находятся поверх всех элементов
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(self.trophyButton)
            self.view.bringSubviewToFront(self.gearButton)
            self.view.bringSubviewToFront(self.startButton)
            self.view.bringSubviewToFront(self.survivalButton)
            self.view.bringSubviewToFront(self.memoryButton)
            self.view.bringSubviewToFront(self.reactionButton)
        }
    }
    
    private func setupBackgroundParticles() {
        for i in 0..<15 {
            let particle = UIView()
            particle.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            particle.layer.cornerRadius = CGFloat.random(in: 2...6)
            particle.translatesAutoresizingMaskIntoConstraints = false
            
            // Отключаем взаимодействие с частицами, чтобы они не блокировали кнопки
            particle.isUserInteractionEnabled = false
            
            let size = CGFloat.random(in: 4...12)
            particle.frame.size = CGSize(width: size, height: size)
            particle.layer.cornerRadius = size / 2
            
            // Добавляем частицы в самый низ
            view.insertSubview(particle, at: 0)
            floatingViews.append(particle)
            
            // Случайное позиционирование
            particle.center = CGPoint(
                x: CGFloat.random(in: 0...view.bounds.width),
                y: CGFloat.random(in: 0...view.bounds.height)
            )
        }
    }
    
    private func startFloatingAnimations() {
        // Останавливаем предыдущие анимации частиц
        floatingViews.forEach { particle in
            particle.layer.removeAllAnimations()
            particle.transform = .identity
            particle.alpha = 0.3
        }
        
        for (index, particle) in floatingViews.enumerated() {
            animateParticle(particle, delay: Double(index) * 0.2)
        }
        
        // Floating анимация только для декоративных элементов (не для кнопок)
        // Останавливаем предыдущие floating анимации
        logoSwitch.layer.removeAllAnimations()
        titleLabel.layer.removeAllAnimations()
        
        animateFloating(logoSwitch, amplitude: 8, duration: 4)
        animateFloating(titleLabel, amplitude: 5, duration: 3.5)
        // Убираем floating анимацию для кнопок, чтобы не мешать touch events
        // animateFloating(startButton, amplitude: 3, duration: 3)
        // animateFloating(trophyButton, amplitude: 4, duration: 2.5)
        // animateFloating(gearButton, amplitude: 4, duration: 2.8)
    }
    
    private func animateParticle(_ particle: UIView, delay: Double) {
        UIView.animate(withDuration: Double.random(in: 3...8), delay: delay, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            particle.transform = CGAffineTransform(translationX: CGFloat.random(in: -30...30), y: CGFloat.random(in: -50...50))
        }
        
        UIView.animate(withDuration: Double.random(in: 2...4), delay: delay + 1, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            particle.alpha = CGFloat.random(in: 0.1...0.6)
        }
    }
    
    private func animateFloating(_ view: UIView, amplitude: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            view.transform = CGAffineTransform(translationX: 0, y: amplitude)
        }
    }
    
    private func animateGradientBackground() {
        // Останавливаем предыдущую анимацию градиента
        gradientLayer.removeAnimation(forKey: "gradientAnimation")
        
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = gradientLayer.colors
        animation.toValue = [
            UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1.0).cgColor,
            UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0).cgColor,
            UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0).cgColor
        ]
        animation.duration = 8
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(animation, forKey: "gradientAnimation")
    }
    
    private func animateLogoSwitch() {
        // Анимация переключения логотипа
        guard let logoBackground = logoSwitch.subviews.first,
              let logoThumb = logoSwitch.subviews.last else { return }
        
        // Останавливаем предыдущие анимации
        logoThumb.layer.removeAllAnimations()
        logoThumb.transform = .identity
        
        UIView.animate(withDuration: 2, delay: 1, options: [.repeat, .autoreverse]) {
            logoThumb.transform = CGAffineTransform(translationX: -40, y: 0)
        }
    }
    
    private func restartAnimations() {
        // Останавливаем все существующие анимации
        stopAllAnimations()
        
        // Запускаем анимации заново с небольшой задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.animateLogoSwitch()
            self.startFloatingAnimations()
            self.animateGradientBackground()
        }
    }
    
    private func stopAllAnimations() {
        // Останавливаем анимации логотипа
        logoSwitch.layer.removeAllAnimations()
        logoSwitch.subviews.forEach { $0.layer.removeAllAnimations() }
        
        // Останавливаем анимации заголовков
        titleLabel.layer.removeAllAnimations()
        subtitleLabel.layer.removeAllAnimations()
        
        // Останавливаем анимации частиц
        floatingViews.forEach { particle in
            particle.layer.removeAllAnimations()
        }
        
        // Останавливаем анимации градиента
        gradientLayer.removeAllAnimations()
        
        // Сбрасываем transforms
        logoSwitch.subviews.forEach { $0.transform = .identity }
        titleLabel.transform = .identity
        subtitleLabel.transform = .identity
    }
    
    private func constraints() {
        NSLayoutConstraint.activate([
            logoSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoSwitch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoSwitch.bottomAnchor, constant: 30),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 56),
            startButton.widthAnchor.constraint(equalToConstant: 260),
            
            survivalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            survivalButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            survivalButton.heightAnchor.constraint(equalToConstant: 56),
            survivalButton.widthAnchor.constraint(equalToConstant: 260),
            
            memoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            memoryButton.topAnchor.constraint(equalTo: survivalButton.bottomAnchor, constant: 20),
            memoryButton.heightAnchor.constraint(equalToConstant: 56),
            memoryButton.widthAnchor.constraint(equalToConstant: 260),
            
            reactionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reactionButton.topAnchor.constraint(equalTo: memoryButton.bottomAnchor, constant: 20),
            reactionButton.heightAnchor.constraint(equalToConstant: 56),
            reactionButton.widthAnchor.constraint(equalToConstant: 260),
            
            trophyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            trophyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            trophyButton.heightAnchor.constraint(equalToConstant: 60),
            trophyButton.widthAnchor.constraint(equalToConstant: 60),
            
            gearButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            gearButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            gearButton.heightAnchor.constraint(equalToConstant: 60),
            gearButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Color Updates
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(switchColorDidChange),
            name: .switchColorDidChange,
            object: nil
        )
    }
    
    @objc private func switchColorDidChange() {
        updateColorsFromSettings()
    }
    
    private func updateColorsFromSettings() {
        let selectedColor = SettingsManager.shared.switchColor
        
        // Обновляем цвета с анимацией
        UIView.animate(withDuration: 0.3) {
            // Обновляем заголовок
            self.titleLabel.textColor = selectedColor
            
            // Создаем градиент для главной кнопки
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                selectedColor.cgColor,
                selectedColor.withAlphaComponent(0.8).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.cornerRadius = 28
            gradientLayer.frame = CGRect(x: 0, y: 0, width: 260, height: 56)
            
            self.startButton.layer.sublayers?.removeAll { $0 is CAGradientLayer }
            self.startButton.layer.insertSublayer(gradientLayer, at: 0)
            
            // Обновляем остальные кнопки
            self.survivalButton.tintColor = selectedColor
            self.memoryButton.tintColor = selectedColor
            self.reactionButton.tintColor = selectedColor
            self.trophyButton.tintColor = selectedColor
            self.gearButton.tintColor = selectedColor
            
            // Обновляем логотип переключателя
            if let logoBackground = self.logoSwitch.subviews.first,
               let gradientLayer = logoBackground.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.colors = [
                    selectedColor.cgColor,
                    selectedColor.withAlphaComponent(0.8).cgColor
                ]
            }
        }
    }
    
    private func animateElements() {
        // Используем spring анимации для более естественного эффекта
        
        // Анимация логотипа
        UIView.animate(withDuration: 1.2, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.logoSwitch.alpha = 1
            self.logoSwitch.transform = .identity
        }
        
        UIView.animate(withDuration: 1.0, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseOut) {
            self.subtitleLabel.alpha = 1
            self.subtitleLabel.transform = .identity
        }
        
        // Анимация кнопок с spring эффектом
        let buttons = [startButton, survivalButton, memoryButton, reactionButton]
        for (index, button) in buttons.enumerated() {
            UIView.animate(withDuration: 1.0, delay: 0.7 + Double(index) * 0.15, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
                button.alpha = 1
                button.transform = .identity
            }
        }
        
        // Анимация круглых кнопок
        UIView.animate(withDuration: 1.2, delay: 1.4, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut) {
            self.trophyButton.alpha = 1
            self.trophyButton.transform = .identity
        }
        
        UIView.animate(withDuration: 1.2, delay: 1.6, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut) {
            self.gearButton.alpha = 1
            self.gearButton.transform = .identity
        }
    }
    
    @objc private func buttonTouchDown(_ button: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            button.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }
        
        // Добавляем haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    @objc private func buttonTouchUp(_ button: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            button.transform = .identity
        }
    }
    
    @objc
    func startButtonAction() {
        performButtonAnimation(startButton) {
            let startGameVC = Level1ViewController()
            startGameVC.modalPresentationStyle = .fullScreen
            self.present(startGameVC, animated: true)
        }
    }
    
    @objc
    func survivalButtonAction() {
        performButtonAnimation(survivalButton) {
            let survivalModeVC = SurvivalModeViewController()
            survivalModeVC.modalPresentationStyle = .fullScreen
            self.present(survivalModeVC, animated: true)
        }
    }
    
    @objc
    func memoryButtonAction() {
        performButtonAnimation(memoryButton) {
            let memoryVC = MemoryModeViewController()
            memoryVC.modalPresentationStyle = .fullScreen
            self.present(memoryVC, animated: true)
        }
    }
    
    @objc
    func reactionButtonAction() {
        performButtonAnimation(reactionButton) {
            let reactionVC = ReactionModeViewController()
            reactionVC.modalPresentationStyle = .fullScreen
            self.present(reactionVC, animated: true)
        }
    }
    
    @objc
    func trophyButtonAction() {
        performButtonAnimation(trophyButton) {
            let highScoresVC = HighScoresViewController()
            //highScoresVC.modalPresentationStyle = .fullScreen
            self.present(highScoresVC, animated: true)
        }
    }
    
    @objc
    func gearButtonAction() {
        performButtonAnimation(gearButton) {
            let settingsVC = SettingsViewController()
            //settingsVC.modalPresentationStyle = .fullScreen
            self.present(settingsVC, animated: true)
        }
    }
    
    private func performButtonAnimation(_ button: UIButton, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                button.transform = .identity
            } completion: { _ in
                completion()
            }
        }
        
        // Добавляем haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}
