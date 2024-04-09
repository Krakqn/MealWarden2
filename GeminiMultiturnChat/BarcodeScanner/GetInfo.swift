//
//  ContentView.swift
//  OpenFoodFactsAPI
//
//  Created by Akksharvan Senthilkumar on 3/31/24.
//

import Foundation
import SwiftUI

struct GetInfo {
    var barcode: String
    var productInformation: ProductInformation?

    var productInfoString: String {
        guard let productInformation = productInformation else {
            return "Loading..."
        }
        
        if productInformation.status_verbose == "product not found" {
            return "Product Not Available"
        }
        
        let product = productInformation.product
        let multilineString = """
        You are an AI assistant named MealWarden. Your task is to answer questions about the food product described below. Users may ask about the product's ingredients, nutritional information, allergens, or any other relevant aspects. Your responses should be clear, concise, and directly address the user's question. If a question cannot be answered definitively based on the provided information, provide your best guess or inference and clarify that it's an assumption based on the available information.
        
        Product Name: \(product?.product_name ?? "")
        Nutri-Score Grade: \(product?.nutriscore_grade ?? "")
        Allergens: \(product?.allergens ?? "")
        Traces: \(product?.traces ?? "")
        Labels: \(product?.labels ?? "")
        Ingredients: \(product?.ingredients_text ?? "")
        
        When you are ready to begin answering questions, simply say "Ready to assist with any questions about this product!"
        """
        
        return multilineString
    }
}

//#Preview {
//    GetInfo()
//}
