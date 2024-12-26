import Foundation
import AVFoundation

class SpeechManager {
    static let shared = SpeechManager() // Singleton instance for reuse
    
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {}
    
    /// Speaks the given text using AVSpeechSynthesizer.
    /// - Parameter text: The text to be spoken.
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    /// Stops any ongoing speech synthesis.
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
