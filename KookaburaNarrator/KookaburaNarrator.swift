//
//  Pictochat2App.swift
//  Pictochat2
//
//  Created by Jonathan Castillo on 26/12/2024.
//

import SwiftUI

@main
struct KookaburaNarrator: App {
    var body: some Scene {
        let apiKeyProviderOpenAI = RealAPIKeyProvider()
        let httpClient = RealHTTPClient()
        let jsonHandler = RealJSONHandler()
        let apiKeyProviderElevenLabs = RealAPIKeyProviderElevenLabs()
        
        WindowGroup {
            ContentView(apiKeyProviderOpenAI: apiKeyProviderOpenAI, 
                        apiKeyProviderElevenLabs: apiKeyProviderElevenLabs,
                        httpClient: httpClient,
                        jsonHandler: jsonHandler
            )
        }
    }
}
