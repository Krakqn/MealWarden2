//
//  OpenFoodFactsAPI.swift
//  OpenFoodFactsAPI
//
//  Created by Akksharvan Senthilkumar on 4/1/24.
//

import Foundation

struct ProductInformation: Codable {
    let product: Product?
    let status_verbose: String?
}

struct Product: Codable {
    let ingredients_text: String?
    let product_name: String?
    let nutriscore_grade: String?
    let allergens: String?
    let traces: String?
    let labels: String?
}

//struct Ingredient: Codable, Identifiable {
//    let id = UUID()
//    let vegan: String?
//    let vegetarian: String?
//}

class OpenFoodFactsAPI {
    private var errorMessage = "Error: Unable to Find Ingredients"
    
    func fetchData(barcode: String, completion: @escaping (ProductInformation?) -> Void) {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode)")
        else { completion(nil); return }
        
        var request = URLRequest(url: url)
        request.setValue("MealWarden - iOS - Version 1.0", forHTTPHeaderField: "User-Agent")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            data, response, error in
            do {
                guard let data = data
                else { throw NSError(domain: "NoDataError", code: 0, userInfo: nil) }
                
                let jsonObject = try JSONDecoder().decode(ProductInformation.self, from: data)
                DispatchQueue.main.async { completion(jsonObject); return }
            }
            catch { completion(nil); return }
        }
        task.resume()
    }
}
