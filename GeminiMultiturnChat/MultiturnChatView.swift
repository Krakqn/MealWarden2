//
//  MultiturnChatView.swift
//  GeminiMultiturnChat
//
//  Created by Sri Yanamandra
//

import SwiftUI
import MarkdownUI
import OpenFoodFactsSDK

struct MultiturnChatView: View {
    @State var textInput = ""
    @State var logoAnimating = false
    @State var timer: Timer?
    @State var chatService = ChatService()
    @FocusState var textIsFocused: Bool
    @Environment (\.colorScheme) var colorScheme: ColorScheme
  
    //OpenFoodFactsSDK
    @State private var barcode: String = ""
    @State private var isInvalidCode = false
    @State private var isScanning = false
    let API = OpenFoodFactsAPI()
    @State private var productInfo = ""
    
    private func resetState() {
        isInvalidCode = false
        barcode = ""
        isScanning = false
    }
    
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
                      if !chatMessage.message.contains("You are an AI assistant named MealWarden. Your task is to answer questions about the food product described below.") {
                        chatMessageView(chatMessage)
                      }
                    }
//                  ForEach(Array(chatService.messages.enumerated()), id: \.element.id) { index, chatMessage in
//                      if index > 0 { // can use this to hide messages (for providing context)
//                          // MARK: Chat message view
//                          chatMessageView(chatMessage)
//                      }
//                    }
                }
                .onTapGesture {
                  textIsFocused = false
                }
                .onChange(of: chatService.messages) { _, _ in
                    guard let recentMessage = chatService.messages.last else { return }
                    DispatchQueue.main.async {
                        withAnimation {
                            proxy.scrollTo(recentMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: textIsFocused) { _, _ in
                  if textIsFocused {
                    guard let recentMessage = chatService.messages.last else { return }
                    DispatchQueue.main.async {
                        withAnimation {
                            proxy.scrollTo(recentMessage.id, anchor: .bottom)
                        }
                    }
                  }
                }
//                .onChange(of: chatService.messages.count) { _ in
//                    guard let recentMessage = chatService.messages.last else { return }
//                    DispatchQueue.main.async {
//                        withAnimation {
//                            proxy.scrollTo(recentMessage.id, anchor: .bottom)
//                        }
//                    }
//                }
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
              Button(action: {
                resetState()
                print("State reset successfully")
                isScanning = true
              }, label: {
                Image(systemName: "barcode.viewfinder")
                  .resizable()
                  .frame(width: 30, height: 30)
                  .foregroundColor(Color.blue)
              })
              TextField("Enter a message...", text: $textInput, axis: .vertical)
                  .focused($textIsFocused)
                  .padding(.vertical, 8) //was 10
                  .padding(.horizontal, 14) //was 16
                  .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                  .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                  .cornerRadius(20)
                  .overlay(
                      RoundedRectangle(cornerRadius: 20)
                          .strokeBorder(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), lineWidth: 1)
                  )
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
        .scrollDismissesKeyboard(.interactively)
        .foregroundStyle(.white)
        .padding()
        .background {
            // MARK: Background
            ZStack {
              colorScheme == .dark ? Color.black : Color.white
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $isScanning, onDismiss: {
          if barcode.isEmpty {
            resetState()
            print("State Reset Successfully")
            return
          }
          chatService.resetChat()
          print("Chat Reset Successfully")
          print("Found barcode \(barcode) which \(barcode.isAValidBarcode() ? "Valid" : "Invalid")")
          if barcode.isAValidBarcode() {
              API.fetchData(barcode: barcode) { result in
                let productDetails = GetInfo(barcode: barcode, productInformation: result)
                productInfo = productDetails.productInfoString
                                
                if productInfo == "Product Not Available" { isInvalidCode = true }
              }
          } else {
              isInvalidCode = true
          }
        }) {
            BarcodeScannerScreen(barcode: $barcode, isCapturing: $isScanning)
                .ignoresSafeArea(.all)
        }
        .onChange(of: productInfo) {
          if productInfo == "Product Not Available" { isInvalidCode = true }
          print(productInfo)
          chatService.sendMessage(productInfo)
        }
        .alert("Invalid barcode", isPresented: $isInvalidCode) {
            Button("Dismiss") {
                resetState()
            }
        } message: {
            Text("Barcode \(barcode) is invalid. Expected format should have 7,8,12 or 13 digits.")
        }
    }
    
    // MARK: Chat message view
    @ViewBuilder func chatMessageView(_ message: ChatMessage) -> some View {
        ChatBubble(direction: message.role == .model ? .left : .right) {
            Markdown(message.message)
            .markdownTextStyle {
              ForegroundColor(message.role == .model ? (colorScheme == .dark ? .white : .black) : .white)
            }
            .markdownBlockStyle(\.codeBlock) { configuration in
              // Source: https://gonzalezreal.github.io/2023/02/18/better-markdown-rendering-in-swiftui.html
                  ScrollView(.horizontal) {
                    configuration.label
                      .relativeLineSpacing(.em(0.25))
                      .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.85))
                      }
                      .padding()
                  }
                  .background(Color(.secondarySystemBackground))
                  .clipShape(RoundedRectangle(cornerRadius: 8))
                  .markdownMargin(top: .zero, bottom: .em(0.8))
              }
            .padding(.vertical, 15)
            .padding((message.role == .model) ? .leading : .trailing, 20) // this randomly fixed the broken spacing
            .padding((message.role == .model) ? .trailing : .leading, 15)
            .background(message.role == .model ? (colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2)) : (colorScheme == .dark ? Color.blue.opacity(1) : Color.blue.opacity(0.7)))
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
