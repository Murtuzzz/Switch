import UIKit
import AVFoundation

extension Notification.Name {
    static let switchColorDidChange = Notification.Name("switchColorDidChange")
}

class SettingsManager {
    static let shared = SettingsManager()
    
    let brandGreen = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
    
    private init() {}
    
    // MARK: - Switch Color
    var switchColor: UIColor {
        let colors: [UIColor] = [R.Colors.blue, R.Colors.green, R.Colors.red, R.Colors.purple, R.Colors.pink, R.Colors.orange]
        let index = UserDefaults.standard.integer(forKey: "SwitchColor")
        return colors[index]
    }
    
    func setSwitchColor(index: Int) {
        UserDefaults.standard.set(index, forKey: "SwitchColor")
        NotificationCenter.default.post(name: .switchColorDidChange, object: nil, userInfo: ["colorIndex": index])
    }
    
    // MARK: - Sound
    var soundFileName: String? {
        let soundNames = ["switchSound", "cosmo", "hrust"]
        let index = UserDefaults.standard.integer(forKey: "SwitchSound")
        return index < soundNames.count ? soundNames[index] : nil
    }
    
    // MARK: - Background
    func applyBackground(to view: UIView) {
        let index = UserDefaults.standard.integer(forKey: "BackgroundStyle")
        
        switch index {
        case 0: // Светлый
            view.backgroundColor = R.Colors.whiteBg
            //containerView.backgroundColor = .white
        case 1: // Темный
            view.backgroundColor = R.Colors.darkBg
           // containerView.backgroundColor = .systemGray6
        case 2: // Градиент
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [R.Colors.breezeBg.cgColor, R.Colors.iceBg.cgColor]
            view.layer.insertSublayer(gradientLayer, at: 0)
            //containerView.backgroundColor = .white
        case 3: // Системный
            view.backgroundColor = R.Colors.purpleBg
            //containerView.backgroundColor = .systemBackground
        default:
            break
        }
    }
    
    // MARK: - Audio Player
    func createAudioPlayer() -> AVAudioPlayer? {
        guard let soundFileName = soundFileName,
              let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: "mp3") else {
            return nil
        }
        
        do {
            return try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print("Unable to create audio player: \(error.localizedDescription)")
            return nil
        }
    }
} 
