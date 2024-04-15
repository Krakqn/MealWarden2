//
//  ProductInfoPage.swift
//  GeminiMultiturnChat
//
//  Created by Sri Yanamandra on 4/13/24.
//

import SwiftUI

struct ProductInfoPage: View {
  @Binding var open: Bool
  let productInfoString: String
  let unwantedParts = [
      "You are an AI assistant named MealWarden. Your task is to answer questions about the food product described below. Users may ask about the product's ingredients, nutritional information, allergens, or any other relevant aspects. Your responses should be clear, concise, and directly address the user's question. If a question cannot be answered definitively based on the provided information, provide your best guess or inference and clarify that it's an assumption based on the available information.",
      "When you are ready to begin answering questions, simply say \"Ready to assist with any questions about this product!"
  ]
  
  
  func nextStep() {
    open = false
  }
    
  var body: some View {
    let lines = productInfoString.components(separatedBy: .newlines)
    let filteredLines = lines.filter { line in
        !unwantedParts.contains(where: line.contains)
    }
    let tempInfo = filteredLines.joined(separator: "\n")
    let productInfoCut = tempInfo.trimmingCharacters(in: .whitespacesAndNewlines)
    GeometryReader { geo in
      VStack{
        List{ // placeholder text, copied from winston at the moment (will change later)
          QuestionAnswer(question: "What did I just scan? Can I have some information about the product?", answer: productInfoCut, systemImage: "questionmark.circle")
          QuestionAnswer(question: "Where does this data come from?", answer: "All data is from [OpenFoodFacts](https://world.openfoodfacts.org).", systemImage: "questionmark.circle")
        }
        Spacer()
        FatButton("Okay!", nextStep)
      }
      .frame(minHeight: geo.size.height - 16)
    }
  }
}

struct QuestionAnswer: View {
  var question: String
  var answer: String
  var systemImage: String?
  var body: some View {
    VStack{
      HStack{
        if let systemImage {
          Image(systemName: systemImage)
        }
        Text(.init(question))
        Spacer()
      }
      .fontWeight(.bold)
      .font(.system(.headline))
      .padding(.bottom, 5)
      HStack{
        Text(.init(answer))
        Spacer()
      }
    }
  }
}
