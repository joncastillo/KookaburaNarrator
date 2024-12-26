import SwiftUI

struct ContentView: View {
    @State private var isCameraPresented = false
    @State private var isPhotoPickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var descriptionText: String = "Take a photo or select from photo gallery."
    @State private var isLoading = false

    // Dependencies
    private let openAIManager: OpenAIManager
    private let speechManager: SpeechManagerElevenLabs

    // Updated initializer
    init(apiKeyProviderOpenAI: APIKeyProvider,
         apiKeyProviderElevenLabs: APIKeyProvider,
         httpClient: HTTPClient,
         jsonHandler: JSONHandler,
         systemInstructions: String = "Give a description of this photo in a creative manner."
    ) {
        self.openAIManager = OpenAIManager(
            apiKeyProvider: apiKeyProviderOpenAI,
            httpClient: httpClient,
            jsonHandler: jsonHandler,
            systemInstructions: systemInstructions
        )
        self.speechManager = SpeechManagerElevenLabs(
            apiKeyProvider: apiKeyProviderElevenLabs,
            httpClient: httpClient
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(
                        Text("No image selected")
                            .foregroundColor(.gray)
                            .font(.headline)
                    )
            }
            ScrollView {
                Text(descriptionText)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            if isLoading {
                ProgressView()
            }

            HStack {
                Button(action: {
                    isCameraPresented = true
                }) {
                    Label("Take Photo", systemImage: "camera")
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    isPhotoPickerPresented = true
                }) {
                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .sheet(isPresented: $isCameraPresented) {
            ImagePicker(sourceType: .camera) { image in
                handleImageSelection(image)
            }
        }
        .sheet(isPresented: $isPhotoPickerPresented) {
            ImagePicker(sourceType: .photoLibrary) { image in
                handleImageSelection(image)
            }
        }
    }

    private func handleImageSelection(_ image: UIImage?) {
        guard let image = image else { return }
        selectedImage = image
        generateDescription(for: image)
    }

    private func generateDescription(for image: UIImage) {
        isLoading = true
        descriptionText = "Analyzing the image..."

        openAIManager.generateDescription(for: image) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let description):
                    self.descriptionText = description
                    self.speechManager.speak(text: description)
                case .failure(let error):
                    self.descriptionText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
