//
//  ContentView.swift
//  OpenFoodFactsAPI
//
//  Created by Akksharvan Senthilkumar on 3/31/24.
//

import SwiftUI

struct ingredientsTest: View {
    @State private var product: ProductInformation?
    
    var barcode: String = "9948247970"
    
    var body: some View {
        VStack {
            if let product = product {
                if (product.status_verbose == "product not found") {
                    Text("Product Not Available")
                }
                else {
                    Text("Product Name: \(product.product.product_name)")
                    Text("Nutri-Score Grade: \(product.product.nutriscore_grade)")
                    Text("Allergens: \(product.product.allergens ?? "")")
                    Text("Traces: \(product.product.traces ?? "")")
                    Text("Labels: \(product.product.labels ?? "")")
                    Text("Ingredients: \(product.product.ingredients_text)")
                    Text("Ingredients Analysis: \(product.product.ingredients_analysis)")
                }
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
