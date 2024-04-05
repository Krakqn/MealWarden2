//
//  ContentView.swift
//  OpenFoodFactsAPI
//
//  Created by Akksharvan Senthilkumar on 3/31/24.
//

import SwiftUI

struct ingredientsTest: View {
    @State private var productInformation: ProductInformation?
    
    var barcode: String = "9948247970"
    
    var body: some View {
        VStack {
            if let productInformation = productInformation {
                if (productInformation.status_verbose == "product not found") {
                    Text("Product Not Available")
                }
                else {
                    Text("Product Name: \(productInformation.product?.product_name ?? "")")
                    Text("Nutri-Score Grade: \(productInformation.product?.nutriscore_grade ?? "")")
                    Text("Allergens: \(productInformation.product?.allergens ?? "")")
                    Text("Traces: \(productInformation.product?.traces ?? "")")
                    Text("Labels: \(productInformation.product?.labels ?? "")")
                    Text("Ingredients: \(productInformation.product?.ingredients_text ?? "")")
                }
            } else {
                Text("Loading...")
            }
        }
        .padding()
        .onAppear {
            let API = OpenFoodFactsAPI()
            API.fetchData(barcode: barcode) { result in
                self.productInformation = result
            }
        }
    }
}

#Preview {
    ingredientsTest()
}
