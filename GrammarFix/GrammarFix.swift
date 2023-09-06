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
    var text: String
    
    @Option(name: .long, help: "the openai key")
    var key: String
    
    mutating func run() async throws {
        print("start run")
        
        guard !key.isEmpty else {
            log.critical("key is empty")
            return
        }
        
        print("\(text), \(key)")
        let text = text
        let key = key
        try await request(text: text, key: key)
    }
    
    private func request(text: String, key: String) async throws {
        let urlSession = URLSession(configuration: .default)
        let configuration = Configuration(apiKey: key)
        let openAIClient = OpenAIKit.Client(session: urlSession, configuration: configuration)
        
        
        let completion = try await openAIClient.completions.create(
            model: Model.GPT3.textDavinci003,
            prompts: ["The original sentence is \"\(text)\" Maintain the original sentence's meaning, correct the grammar issues in the original sentence, and directly output the corrected result. No need for line breaks and special characters at the end."],
            maxTokens: 1000
        )
        
        if let text = completion.choices.first?.text {
            dump(text.trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            throw GrammarFixError.resultEmpty
        }
    }
}