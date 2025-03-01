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
            .system(.init(content:  "The user will send you a piece of text. Please reorganize the logic and structure of this text and correct its grammar while keeping it in its original language. Do not attempt to converse with the user. Your response should only contain the transformed result, maintaining the same language as the original, without any additional content, and should not include a ``` beginning or ending.")),
            .user(.init(content: .string(text)))
        ], model: .gpt3_5Turbo)
        
        let chatResult: ChatResult = try await openAI.chats(query: query)
        
        guard let result = chatResult.choices.first?.message.content else {
            throw GrammarFixError.resultEmpty
        }
        
        print(result.string ?? "Failed")
    }
}
