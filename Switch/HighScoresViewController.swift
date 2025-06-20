import UIKit

// MARK: - Game Modes
enum GameMode: Int, CaseIterable {
    case survival = 0
    case memory = 1
    case reaction = 2
    
    var title: String {
        switch self {
        case .survival: return "Выживание"
        case .memory: return "Память"
        case .reaction: return "Реакция"
        }
    }
    
    var scoreKey: String {
        switch self {
        case .survival: return "SurvivalModeScores"
        case .memory: return "MemoryModeScores"
        case .reaction: return "ReactionModeScores"
        }
    }
    
    var highScoreKey: String {
        switch self {
        case .survival: return "SurvivalModeHighScore"
        case .memory: return "MemoryModeHighScore"
        case .reaction: return "ReactionModeHighScore"
        }
    }
    
    var emptyMessage: String {
        switch self {
        case .survival: return "Пока нет рекордов в режиме выживания"
        case .memory: return "Пока нет рекордов в режиме памяти"
        case .reaction: return "Пока нет рекордов в режиме реакции"
        }
    }
}

class HighScoresViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Рекорды"
        label.font = .systemFont(ofSize: 32, weight: .black)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ваши лучшие результаты"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let modeContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let modeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: GameMode.allCases.map { $0.title })
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.backgroundColor = .clear
        control.selectedSegmentTintColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
        ], for: .selected)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ], for: .normal)
        control.layer.cornerRadius = 12
        control.clipsToBounds = true
        return control
    }()
    
    private let bestScoreContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 0.1)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 0.3).cgColor
        return view
    }()
    
    private let bestScoreIconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "👑"
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let bestScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let leaderboardContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        table.layer.cornerRadius = 16
        table.clipsToBounds = true
        return table
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateIconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "🎯"
        label.font = .systemFont(ofSize: 64)
        label.textAlignment = .center
        return label
    }()
    
    private let emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "Пока нет рекордов"
        return label
    }()
    
    private let emptyStateSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var currentMode: GameMode = .survival
    private var highScores: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        loadHighScores()
        updateDisplay()
        
        // Добавляем анимацию появления
        animateViewAppearance()
    }
    
    private func setupUI() {
        // Основная структура
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Header
        contentView.addSubview(headerContainerView)
        headerContainerView.addSubview(titleLabel)
        headerContainerView.addSubview(subtitleLabel)
        
        // Режимы
        contentView.addSubview(modeContainerView)
        modeContainerView.addSubview(modeSegmentedControl)
        
        // Лучший результат
        contentView.addSubview(bestScoreContainerView)
        bestScoreContainerView.addSubview(bestScoreIconLabel)
        bestScoreContainerView.addSubview(bestScoreLabel)
        
        // Таблица рекордов
        contentView.addSubview(leaderboardContainerView)
        leaderboardContainerView.addSubview(tableView)
        
        // Empty state
        leaderboardContainerView.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateIconLabel)
        emptyStateView.addSubview(emptyStateTitleLabel)
        emptyStateView.addSubview(emptyStateSubtitleLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ModernHighScoreCell.self, forCellReuseIdentifier: "ModernHighScoreCell")
        
        modeSegmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header
            headerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            
            // Mode container
            modeContainerView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 24),
            modeContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            modeContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            modeSegmentedControl.topAnchor.constraint(equalTo: modeContainerView.topAnchor, constant: 12),
            modeSegmentedControl.leadingAnchor.constraint(equalTo: modeContainerView.leadingAnchor, constant: 12),
            modeSegmentedControl.trailingAnchor.constraint(equalTo: modeContainerView.trailingAnchor, constant: -12),
            modeSegmentedControl.bottomAnchor.constraint(equalTo: modeContainerView.bottomAnchor, constant: -12),
            modeSegmentedControl.heightAnchor.constraint(equalToConstant: 36),
            
            // Best score container
            bestScoreContainerView.topAnchor.constraint(equalTo: modeContainerView.bottomAnchor, constant: 20),
            bestScoreContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bestScoreContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            bestScoreIconLabel.topAnchor.constraint(equalTo: bestScoreContainerView.topAnchor, constant: 16),
            bestScoreIconLabel.centerXAnchor.constraint(equalTo: bestScoreContainerView.centerXAnchor),
            
            bestScoreLabel.topAnchor.constraint(equalTo: bestScoreIconLabel.bottomAnchor, constant: 8),
            bestScoreLabel.leadingAnchor.constraint(equalTo: bestScoreContainerView.leadingAnchor, constant: 16),
            bestScoreLabel.trailingAnchor.constraint(equalTo: bestScoreContainerView.trailingAnchor, constant: -16),
            bestScoreLabel.bottomAnchor.constraint(equalTo: bestScoreContainerView.bottomAnchor, constant: -16),
            
            // Leaderboard container
            leaderboardContainerView.topAnchor.constraint(equalTo: bestScoreContainerView.bottomAnchor, constant: 20),
            leaderboardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            leaderboardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            leaderboardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            leaderboardContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300),
            
            // TableView
            tableView.topAnchor.constraint(equalTo: leaderboardContainerView.topAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: leaderboardContainerView.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: leaderboardContainerView.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: leaderboardContainerView.bottomAnchor, constant: -12),
            
            // Empty state
            emptyStateView.centerXAnchor.constraint(equalTo: leaderboardContainerView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: leaderboardContainerView.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: leaderboardContainerView.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: leaderboardContainerView.trailingAnchor, constant: -40),
            
            emptyStateIconLabel.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateIconLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            emptyStateTitleLabel.topAnchor.constraint(equalTo: emptyStateIconLabel.bottomAnchor, constant: 16),
            emptyStateTitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateTitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyStateSubtitleLabel.topAnchor.constraint(equalTo: emptyStateTitleLabel.bottomAnchor, constant: 8),
            emptyStateSubtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateSubtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateSubtitleLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    @objc private func modeChanged() {
        currentMode = GameMode(rawValue: modeSegmentedControl.selectedSegmentIndex) ?? .survival
        loadHighScores()
        updateDisplay()
        
        // Добавляем анимацию переключения
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
    
    private func loadHighScores() {
        highScores = UserDefaults.standard.array(forKey: currentMode.scoreKey) as? [Int] ?? []
    }
    
    private func updateDisplay() {
        // Обновляем информацию о лучшем результате
        let bestScore = UserDefaults.standard.integer(forKey: currentMode.highScoreKey)
        if bestScore > 0 {
            bestScoreLabel.text = "Лучший результат: \(bestScore)"
        } else {
            bestScoreLabel.text = "Поставьте свой первый рекорд!"
        }
        
        // Показываем/скрываем empty state
        let isEmpty = highScores.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        if isEmpty {
            emptyStateSubtitleLabel.text = currentMode.emptyMessage + "\nСыграйте в этот режим, чтобы установить рекорд!"
        }
        
        tableView.reloadData()
    }
    
    private func animateViewAppearance() {
        // Начальное состояние
        headerContainerView.alpha = 0
        headerContainerView.transform = CGAffineTransform(translationX: 0, y: -30)
        
        modeContainerView.alpha = 0
        modeContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        bestScoreContainerView.alpha = 0
        bestScoreContainerView.transform = CGAffineTransform(translationX: -50, y: 0)
        
        leaderboardContainerView.alpha = 0
        leaderboardContainerView.transform = CGAffineTransform(translationX: 50, y: 0)
        
        // Анимация появления
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.headerContainerView.alpha = 1
            self.headerContainerView.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.modeContainerView.alpha = 1
            self.modeContainerView.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.4, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.bestScoreContainerView.alpha = 1
            self.bestScoreContainerView.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.leaderboardContainerView.alpha = 1
            self.leaderboardContainerView.transform = .identity
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension HighScoresViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModernHighScoreCell", for: indexPath) as! ModernHighScoreCell
        let score = highScores[indexPath.row]
        cell.configure(place: indexPath.row + 1, score: score, mode: currentMode)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

// MARK: - ModernHighScoreCell
class ModernHighScoreCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.03
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let rankContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 0.1)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private let medalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28)
        label.textAlignment = .center
        return label
    }()
    
    private let scoreContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()
    
    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "очков"
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(rankContainerView)
        rankContainerView.addSubview(rankLabel)
        containerView.addSubview(medalLabel)
        containerView.addSubview(scoreContainerView)
        scoreContainerView.addSubview(scoreLabel)
        scoreContainerView.addSubview(pointsLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            rankContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            rankContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rankContainerView.widthAnchor.constraint(equalToConstant: 40),
            rankContainerView.heightAnchor.constraint(equalToConstant: 40),
            
            rankLabel.centerXAnchor.constraint(equalTo: rankContainerView.centerXAnchor),
            rankLabel.centerYAnchor.constraint(equalTo: rankContainerView.centerYAnchor),
            
            medalLabel.leadingAnchor.constraint(equalTo: rankContainerView.trailingAnchor, constant: 12),
            medalLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            medalLabel.widthAnchor.constraint(equalToConstant: 40),
            
            scoreContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            scoreContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            scoreLabel.topAnchor.constraint(equalTo: scoreContainerView.topAnchor),
            scoreLabel.leadingAnchor.constraint(equalTo: scoreContainerView.leadingAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: scoreContainerView.trailingAnchor),
            
            pointsLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 2),
            pointsLabel.leadingAnchor.constraint(equalTo: scoreContainerView.leadingAnchor),
            pointsLabel.trailingAnchor.constraint(equalTo: scoreContainerView.trailingAnchor),
            pointsLabel.bottomAnchor.constraint(equalTo: scoreContainerView.bottomAnchor)
        ])
    }
    
    func configure(place: Int, score: Int, mode: GameMode) {
        rankLabel.text = "\(place)"
        scoreLabel.text = "\(score)"
        
        // Настройка цветов и медалей для топ-3
        switch place {
        case 1:
            medalLabel.text = "🏆"
            containerView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.08)
            rankContainerView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.2)
            rankLabel.textColor = UIColor.systemYellow.withAlphaComponent(0.8)
            scoreLabel.textColor = UIColor.systemYellow.withAlphaComponent(0.9)
            
        case 2:
            medalLabel.text = "🥈"
            containerView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.08)
            rankContainerView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
            rankLabel.textColor = UIColor.systemGray.withAlphaComponent(0.8)
            scoreLabel.textColor = UIColor.systemGray.withAlphaComponent(0.9)
            
        case 3:
            medalLabel.text = "🥉"
            containerView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.08)
            rankContainerView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            rankLabel.textColor = UIColor.systemOrange.withAlphaComponent(0.8)
            scoreLabel.textColor = UIColor.systemOrange.withAlphaComponent(0.9)
            
        default:
            medalLabel.text = ""
            containerView.backgroundColor = .secondarySystemGroupedBackground
            rankContainerView.backgroundColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 0.1)
            rankLabel.textColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0)
            scoreLabel.textColor = .label
        }
        
        // Добавляем анимацию появления
        animateAppearance()
    }
    
    private func animateAppearance() {
        containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        containerView.alpha = 0.7
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1.0
        }
    }
} 
