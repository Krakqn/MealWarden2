//
//  MultiturnChatView.swift
//  GeminiMultiturnChat
//
//  Created by Anup D'Souza
//

import SwiftUI

struct MultiturnChatView: View {
    @State var textInput = ""
    @State var logoAnimating = false
    @State var timer: Timer?
    @State var chatService = ChatService()
    @FocusState var textIsFocused: Bool
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        VStack {
            // MARK: Animating logo
            Image(.geminiLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .opacity(logoAnimating ? 0.5 : 1)
                .animation(.easeInOut, value: logoAnimating)
            
            // MARK: Chat message list
            ScrollViewReader(content: { proxy in
                ScrollView {
                    ForEach(chatService.messages) { chatMessage in
                        // MARK: Chat message view
                        chatMessageView(chatMessage)
                    }
                }
                .onChange(of: chatService.messages) { _, _ in
                    guard let recentMessage = chatService.messages.last else { return }
                    DispatchQueue.main.async {
                        withAnimation {
                            proxy.scrollTo(recentMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: chatService.loadingResponse) { _, newValue in
                    if newValue {
                        startLoadingAnimation()
                    } else {
                        stopLoadingAnimation()
                    }
                }
            })
          
          /*
           
           } else {
               TextField("Ask me something...", text: $text)
                   .lineLimit(5)
                   .focused($textIsFocused)
                   .padding(.vertical, 10)
                   .onTapGesture {
                       textIsFocused = true
                   }
           */
            
            // MARK: Input fields
            HStack {
              TextField("Enter a message...", text: $textInput, axis: .vertical)
                    //.textFieldStyle(.roundedBorder)
                    .focused($textIsFocused)
                    .padding(.vertical, 10)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .onTapGesture {
                        textIsFocused = true
                    }
              Button(action: sendMessage, label: {
                Image(systemName: "arrow.right.circle.fill")
                  .resizable()
                  .frame(width: 30, height: 30)
                  .foregroundColor(Color.blue)
              })
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background {
            // MARK: Background
            ZStack {
              colorScheme == .dark ? Color.black : Color.white
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: Chat message view
    @ViewBuilder func chatMessageView(_ message: ChatMessage) -> some View {
        ChatBubble(direction: message.role == .model ? .left : .right) {
            Text(message.message)
                .font(.title3)
                .padding(.all, 20)
                .foregroundStyle(.white)
                .background(message.role == .model ? Color.gray.opacity(0.5) : Color.blue.opacity(1))
        }
    }
    
    // MARK: Fetch response
    func sendMessage() {
      let trimmedString = textInput.trimmingCharacters(in: .whitespaces)

      if !trimmedString.isEmpty {
        chatService.sendMessage(textInput)
      }
        textInput = ""
        textIsFocused = false
    }
    // MARK: Response loading animation
    func startLoadingAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
            logoAnimating.toggle()
        })
    }
    
    func stopLoadingAnimation() {
        logoAnimating = false
        timer?.invalidate()
        timer = nil
    }
}

//#Preview {
//    MultiturnChatView()
//}
