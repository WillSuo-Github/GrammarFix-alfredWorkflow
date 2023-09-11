//
//  GrammarFix.swift
//  GrammarFix
//
//  Created by Will Suo on 6/9/2023.
//

import Foundation
import ArgumentParser
import OSLog
import OpenAIKit
import NIOCore

let log = Logger(subsystem: "GrammarFix", category: "main")

@main
struct GrammarFix: AsyncParsableCommand {
    @Argument(help: "the text you want to grammar fix")
    private var text: String
    
    @Option(name: .long, help: "the openai key")
    private var key: String
    
    mutating func run() async throws {
        guard !key.isEmpty else {
            log.critical("key is empty")
            return
        }

        let text = text
        let key = key
        try await request(text: text, key: key)
    }
}

// MARK: - Request
extension GrammarFix {
    private func request(text: String, key: String) async throws {
        let urlSession = URLSession(configuration: .default)
        let configuration = Configuration(apiKey: key)
        let openAIClient = OpenAIKit.Client(session: urlSession, configuration: configuration)
        
        let completion = try await openAIClient.completions.create(
            model: Model.GPT3.textDavinci003,
            prompts: ["The original sentence is: \"\(text)\" Please maintain the meaning and language of the original sentence, correct the grammar issues in the original sentence, and directly output the corrected result without the prefix like \"The correct sentence is\" and without line breaks, special characters, or quotation marks at the beginning and end of the sentence."],
            maxTokens: 1000
        )
        
        if let text = completion.choices.first?.text {
            print(text.trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            throw GrammarFixError.resultEmpty
        }
    }
}
