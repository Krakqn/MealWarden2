//
//  ChatService.swift
//  GeminiChat
//
//  Created by Sri Yanamandra
//

import Foundation
import SwiftUI
import GoogleGenerativeAI

enum ChatRole {
    case user
    case model
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID().uuidString
    var role: ChatRole
    var message: String
}

@Observable
class ChatService {
    private var chat: Chat?
    private(set) var messages = [ChatMessage]()
    private(set) var firstMessages = [
        ChatMessage(role: .model, message: "Hello there! I'm MealWarden, your friendly food companion. To begin, simply use the barcode button to scan any product you'd like to know more about. Whether you're curious if a product is suitable for a vegetarian diet, safe to consume with certain allergies, or have questions about specific ingredients, I'm here to help. Feel free to ask me anything food-related!")
    ]
    private(set) var loadingResponse = false
    
    func sendMessage(_ message: String) {
        loadingResponse = true
        
        if (chat == nil) {
            let history: [ModelContent] = messages.map { ModelContent(role: $0.role == .user ? "user" : "model", parts: $0.message)}
            chat = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default).startChat(history: history)
        }
        
        // MARK: Add user's message to the list
        messages.append(.init(role: .user, message: message))
        
        Task {
            do {
                let response = try await chat?.sendMessage(message)
                
                loadingResponse = false
                
                guard let text = response?.text else {
                    messages.append(.init(role: .model, message: "Something went wrong, please try again."))
                    return
                }
                
                messages.append(.init(role: .model, message: text))
            }
            catch {
                loadingResponse = false
                messages.append(.init(role: .model, message: "Something went wrong, please try again."))
            }
        }
    }
  
  func resetChat() {
          chat = nil
          messages.removeAll()
          loadingResponse = false
      }
}

