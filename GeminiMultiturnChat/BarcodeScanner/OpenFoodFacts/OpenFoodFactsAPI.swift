//
//  OpenFoodFactsAPI.swift
//  OpenFoodFactsAPI
//
//  Created by Akksharvan Senthilkumar on 4/1/24.
//

import Foundation

struct ProductInformation: Codable {
    let product: Product
}

struct Product: Codable {
    let ingredients_text: String
}

class OpenFoodFactsAPI {
    private var errorMessage = "Error: Unable to Find Ingredients"
    
    func fetchData(barcode: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://world.open foodfacts.org/api/v2/product/\(barcode)")
        else { completion(self.errorMessage); return }

        let session = URLSession.shared
        let task = session.dataTask(with: url) {
            data, response, error in
            do {
                guard let data = data
                else { throw NSError(domain: "NoDataError", code: 0, userInfo: nil) }
                
                let jsonObject = try JSONDecoder().decode(ProductInformation.self, from: data)
                DispatchQueue.main.async { completion(jsonObject.product.ingredients_text); return }
            }
            catch { completion(self.errorMessage); return }
        }
        
        task.resume()
    }
}
