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
    @State private var showProductPage = false
    @State private var showProductInfoPage = false
    let API = OpenFoodFactsAPI()
    @State private var productInfo = ""
    @State private var productName = ""
    @State private var pastBarcode = ""
    
    private func resetState() {
        isInvalidCode = false
        barcode = ""
        isScanning = false
    }
    
    var body: some View {
        VStack {
          // MARK: Header
          HStack {
            Button(action: {
              if productName != "" {
                showProductPage = true
              }
            }) {
              HStack(spacing: 10) {
                // Profile picture icon
                Image(systemName: "person.circle.fill")
                  .font(.system(size: 40))
                  .foregroundColor(.gray)
                  .opacity(logoAnimating ? 0.5 : 1)
                  .animation(.easeInOut, value: logoAnimating)
                
                VStack(alignment: .leading, spacing: 2) {
                  Text("MealWarden")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                  
                  if productName == "" {
                    Text("I'm here to help! Scan a barcode to start.")
                      .font(.system(size: 14))
                      .foregroundColor(.gray)
                  } else {
                    Text("Currently examining **\(productName)**. Tap for more information.")
                      .font(.system(size: 14))
                      .foregroundColor(.gray)
                  }
                }
                .alignmentGuide(HorizontalAlignment.leading) { d in d[.leading] }
              }
            }
            .buttonStyle(PlainButtonStyle())
              
              Spacer()
              
              Button(action: {
                if productName != "" {
                  showProductInfoPage = true
                }
              }) {
                  Image(systemName: "exclamationmark.circle")
                      .font(.system(size: 25))
                      .foregroundColor(.white)
              }
              
              Button(action: {
                // used Link to get rid of the conflict iwth openURL
                // nothing should go here
              }) {
                Link(destination: URL(string: "https://www.google.com")!) {
                  Image(systemName: "exclamationmark.bubble.circle")
                      .font(.system(size: 25))
                      .foregroundColor(.white)
                }
              }
          }
          .padding(.horizontal, 5)
          .background(Color.black)
            
            // MARK: Chat message list
            ScrollViewReader(content: { proxy in
                ScrollView {
                  if productName == "" {
                      ForEach(chatService.firstMessages) { chatMessage in
                          // MARK: Initial message
                          chatMessageView(chatMessage)
                        }
                    }
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                      // keyboard apparently takes 0.3 seconds to animate
                      // source: https://stackoverflow.com/questions/5979793/time-taken-for-keyboard-to-animate-on-ios#:~:text=I%20know%20from%20what%20I,s%2C%20and%20they%20work%20well.
                      
                      // so we're cheesing this by waiting 0.05 seconds before scrolling to the bottom lol
                      // this way, .bottom gets set to wherever the keyboard will be because the animation
                      // will have triggered after 50ms
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
          if barcode.isEmpty || barcode == pastBarcode {
            resetState()
            print("State Reset Successfully")
            return
          }
          startLoadingAnimation()
          chatService.resetChat()
          print("Chat Reset Successfully")
          print("Found barcode \(barcode) which \(barcode.isAValidBarcode() ? "Valid" : "Invalid")")
          if barcode.isAValidBarcode() {
              API.fetchData(barcode: barcode) { result in
                let productDetails = GetInfo(barcode: barcode, productInformation: result)
                productInfo = productDetails.productInfoString
                productName = productDetails.productInformation?.product?.product_name ?? ""
                                
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
          else {
            chatService.sendMessage(productInfo)
            pastBarcode = barcode
          }
          print(productInfo)
          stopLoadingAnimation()
        }
        .alert("Invalid barcode", isPresented: $isInvalidCode) {
            Button("Dismiss") {
                stopLoadingAnimation()
                resetState()
            }
        } message: {
            Text("Barcode \(barcode) is invalid. Expected format should have 7,8,12 or 13 digits.")
        }
        .sheet(isPresented: $showProductPage) {
          ProductPage(barcode: pastBarcode)
        }
        .sheet(isPresented: $showProductInfoPage) {
          NavigationView {
            ProductInfoPage(open: $showProductInfoPage, productInfoString: productInfo)
              .navigationBarTitle("Product Information", displayMode: .inline)
          }
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
