import AVFoundation
import Foundation

class SpeechManagerElevenLabs {
    
    private let apiKeyProvider: APIKeyProvider
    private let httpClient: HTTPClient
    private var audioPlayer: AVAudioPlayer?

    private var voiceCharlotte = "XB0fDUnXU5powFXDhCwa"

    
    init(
        apiKeyProvider: APIKeyProvider,
        httpClient: HTTPClient
    ) {
        self.apiKeyProvider = apiKeyProvider
        self.httpClient = httpClient
    }
    
    func speak(text: String) {
        let apikey = self.apiKeyProvider.getAPIKey()
        let headers = [
            "xi-api-key": "\(apikey)",
            "Content-Type": "application/json"
        ]
        let parameters = ["text": text]
        guard let postData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Failed to serialize JSON")
            return
        }
        
        // Use URLRequest instead of NSMutableURLRequest
        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceCharlotte)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("Status Code: \(response.statusCode)")
            }
            
            if let data = data {
                self.playAudio(data: data)
            }
        }
        dataTask.resume()
    }
    
    private func playAudio(data: Data) {
        DispatchQueue.main.async {
            do {
                self.audioPlayer = try AVAudioPlayer(data: data)
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
            } catch {
                print("Error playing audio: \(error.localizedDescription)")
            }
        }
    }
}
