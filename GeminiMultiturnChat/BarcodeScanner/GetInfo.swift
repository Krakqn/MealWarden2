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
        Product Name: \(product?.product_name ?? "")
        Nutri-Score Grade: \(product?.nutriscore_grade ?? "")
        Allergens: \(product?.allergens ?? "")
        Traces: \(product?.traces ?? "")
        Labels: \(product?.labels ?? "")
        Ingredients: \(product?.ingredients_text ?? "")
        """
        
        return multilineString
    }
}

//#Preview {
//    GetInfo()
//}
