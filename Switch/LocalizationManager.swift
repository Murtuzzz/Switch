//
//  LocalizationManager.swift
//  Switch
//
//  Created by Localization Manager
//

import Foundation

/// Менеджер локализации для удобного доступа к переводам
class LocalizationManager {
    
    /// Получает локализованную строку по ключу
    /// - Parameter key: Ключ локализации
    /// - Returns: Локализованная строка
    static func string(for key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    /// Получает форматированную локализованную строку
    /// - Parameters:
    ///   - key: Ключ локализации
    ///   - arguments: Аргументы для форматирования
    /// - Returns: Форматированная локализованная строка
    static func string(for key: String, _ arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: arguments)
    }
}

// MARK: - Extension для удобного доступа
extension String {
    /// Возвращает локализованную версию строки
    var localized: String {
        return LocalizationManager.string(for: self)
    }
    
    /// Возвращает форматированную локализованную строку
    /// - Parameter arguments: Аргументы для форматирования
    /// - Returns: Форматированная строка
    func localized(with arguments: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String(format: format, arguments: arguments)
    }
}

// MARK: - Предопределенные ключи локализации
extension LocalizationManager {
    
    // MARK: - Main Screen
    struct MainScreen {
        static let subtitle = "app_subtitle"
        static let startGame = "button_start_game"
        static let survivalMode = "button_survival_mode"
        static let memoryMode = "button_memory_mode"
        static let reactionMode = "button_reaction_mode"
    }
    
    // MARK: - Game Modes
    struct GameModes {
        static let survival = "mode_survival"
        static let memory = "mode_memory"
        static let reaction = "mode_reaction"
        static let sequence = "mode_sequence"
        static let pattern = "mode_pattern"
    }
    
    // MARK: - Level Indicators
    struct Level {
        static let level = "level"
        static let levelNumber = "level_number"
        static let levelSurvival = "level_survival"
        static let levelLogic = "level_logic"
        static let levelReaction = "level_reaction"
    }
    
    // MARK: - Game Stats
    struct Stats {
        static let score = "score"
        static let time = "time"
        static let timeSeconds = "time_seconds"
        static let timePlaceholder = "time_placeholder"
        static let record = "record"
        static let bestScore = "best_score"
        static let setFirstRecord = "set_first_record"
    }
    
    // MARK: - Settings
    struct Settings {
        static let title = "settings_title"
        static let switchColorTitle = "switch_color_title"
        static let switchColorSubtitle = "switch_color_subtitle"
        static let soundTitle = "sound_title"
        static let soundSubtitle = "sound_subtitle"
        static let soundClassic = "sound_classic"
        static let soundElectronic = "sound_electronic"
        static let soundCrunch = "sound_crunch"
        static let soundNone = "sound_none"
        static let backgroundTitle = "background_title"
        static let backgroundSubtitle = "background_subtitle"
        static let backgroundLight = "background_light"
        static let backgroundDark = "background_dark"
        static let backgroundGradient = "background_gradient"
        static let backgroundSystem = "background_system"
        static let previewTitle = "preview_title"
        static let previewSubtitle = "preview_subtitle"
    }
    
    // MARK: - High Scores
    struct HighScores {
        static let title = "high_scores_title"
        static let subtitle = "high_scores_subtitle"
        static let noRecordsSurvival = "no_records_survival"
        static let noRecordsMemory = "no_records_memory"
        static let noRecordsReaction = "no_records_reaction"
        static let noRecordsGeneral = "no_records_general"
        static let emptyRecordsMessage = "empty_records_message"
        static let points = "points"
    }
    
    // MARK: - Game Instructions
    struct Instructions {
        static let goalTitle = "goal_title"
        static let rulesTitle = "rules_title"
        static let warningTitle = "warning_title"
        static let tipTitle = "tip_title"
        static let buttonStart = "button_start"
        static let buttonBack = "button_back"
        
        // Survival Mode
        static let survivalTitle = "survival_mode_title"
        static let survivalGoal = "survival_goal"
        static let survivalRules = "survival_rules"
        static let survivalWarning = "survival_warning"
        static let survivalTip = "survival_tip"
        
        // Memory Mode
        static let memoryTitle = "memory_mode_title"
        static let memorySubtitle = "memory_mode_subtitle"
        static let memoryGoal = "memory_goal"
        static let memoryRules = "memory_rules"
        static let memoryWarning = "memory_warning"
        static let memoryTip = "memory_tip"
        
        // Reaction Mode
        static let reactionTitle = "reaction_mode_title"
        static let reactionGoal = "reaction_goal"
        static let reactionRules = "reaction_rules"
        static let reactionWarning = "reaction_warning"
        static let reactionTip = "reaction_tip"
    }
    
    // MARK: - Game Messages
    struct GameMessages {
        static let rememberSequence = "instructions_remember_sequence"
        static let rememberPattern = "instructions_remember_pattern"
        static let rememberWithLevel = "instructions_remember_with_level"
        static let yourTurn = "instructions_your_turn"
        static let repeatSequence = "instructions_repeat_sequence"
        static let tapButton = "instructions_tap_button"
        static let waiting = "instructions_waiting"
        
        static let correct = "correct"
        static let incorrect = "incorrect"
        static let incorrectReaction = "incorrect_reaction"
        static let tryAgain = "try_again"
        static let notBad = "not_bad"
        static let excellentReaction = "excellent_reaction"
        static let incredibleSpeed = "incredible_speed"
        static let combo = "combo"
        static let levelUp = "level_up"
        static let excellentPoints = "excellent_points"
    }
    
    // MARK: - Game Over
    struct GameOver {
        static let title = "game_over_title"
        static let score = "game_over_score"
        static let memoryModeResult = "game_over_memory_mode_result"
        static let reactionResults = "reaction_mode_results"
        static let completed = "game_over_completed"
        static let newGame = "button_new_game"
        static let playAgain = "button_play_again"
        static let mainMenu = "button_main_menu"
        static let showInstructions = "button_show_instructions"
        static let restart = "button_restart"
    }
    
    // MARK: - Level Instructions
    struct LevelInstructions {
        static let rememberSequenceLevel = "remember_sequence_level"
        static let rememberPatternLevel = "remember_pattern_level"
    }
    
    // MARK: - Color Game
    struct ColorGame {
        static let target = "target_color"
        static let yourColor = "your_color"
    }
    
    // MARK: - Launch Screen
    struct LaunchScreen {
        static let turnOnSound = "launch_turn_on_sound"
    }
    
    // MARK: - Individual Levels
    struct Levels {
        static let level1 = "level_1"
        static let level2 = "level_2"
        static let level3 = "level_3"
        static let level4 = "level_4"
        static let level5 = "level_5"
        static let level6 = "level_6"
        static let level7 = "level_7"
        static let level8 = "level_8"
        static let level9 = "level_9"
        static let level10 = "level_10"
        static let level11 = "level_11"
        static let level12 = "level_12"
        static let level13 = "level_13"
        static let level14 = "level_14"
        static let level15 = "level_15"
    }
} 