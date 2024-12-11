//
//  GrammarFix.swift
//  GrammarFix
//
//  Created by Will Suo on 6/9/2023.
//

import Foundation
import ArgumentParser
import OSLog
import OpenAI

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
        let openAI = OpenAI(apiToken: key)
        let query = ChatQuery(messages: [
            .init(role: .system, content: "I will send you a message in Chinese Or English—I’m chatting with colleagues overseas, so I might need your help translating it into polite, respectful, and appropriately funny English. Just stick to the translation—no chit-chat, just only return the translation directly, please! Thanks a ton!")!,
            .init(role: .user, content: "\(text)")!
        ], model: .gpt3_5Turbo, n: 1)
        
        let chatResult: ChatResult = try await openAI.chats(query: query)
        
        guard let result = chatResult.choices.first?.message.content?.string else {
            throw GrammarFixError.resultEmpty
        }
        
        print(result)
    }
}
