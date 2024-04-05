//
//  ContentView.swift
//  OpenFoodFactsAPI
//
//  Created by Akksharvan Senthilkumar on 3/31/24.
//

import SwiftUI

struct ingredientsTest: View {
    @State private var productInformation: ProductInformation?
    var barcode: String = "00723060"
    
    var productInfoString: String {
        guard let productInformation = productInformation else {
            return "Loading..."
        }
        
        if productInformation.status_verbose == "product not found" {
            return "Product Not Available"
        }
        
        let product = productInformation.product
        let multilineString = """
        Product Name: \(product?.product_name ?? "")
        Nutri-Score Grade: \(product?.nutriscore_grade ?? "")
        Allergens: \(product?.allergens ?? "")
        Traces: \(product?.traces ?? "")
        Labels: \(product?.labels ?? "")
        Ingredients: \(product?.ingredients_text ?? "")
        """
        
        return multilineString
    }
    
    var body: some View {
        VStack {
            Text(productInfoString)
                .multilineTextAlignment(.leading)
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

//#Preview {
//    ingredientsTest()
//}
