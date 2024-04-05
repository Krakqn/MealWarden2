//
//  ContentView.swift
//  OpenFoodFactsAPI
//
//  Created by Akksharvan Senthilkumar on 3/31/24.
//

import SwiftUI

struct ingredientsTest: View {
    @State private var product: Product?
    
    var barcode: String = "3017620422003"
    
    var body: some View {
        VStack {
            if let product = product {
                Text("Product Name: \(product.product_name)")
                Text("Nutri-Score Grade: \(product.nutriscore_grade)")
                Text("Allergens: \(product.allergens ?? "")")
                Text("Traces: \(product.traces ?? "")")
                Text("Labels: \(product.labels ?? "")")
              Text("Ingredients: \(product.ingredients_text)")
                
            } else {
                Text("Loading...")
            }
        }
        .padding()
        .onAppear {
            let API = OpenFoodFactsAPI()
            API.fetchData(barcode: barcode) { result in
                self.product = result
            }
        }
    }
}

#Preview {
    ingredientsTest()
}
