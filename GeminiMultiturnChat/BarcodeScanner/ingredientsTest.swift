//
//  ContentView.swift
//  OpenFoodFactsAPI
//
//  Created by Akksharvan Senthilkumar on 3/31/24.
//

import SwiftUI

struct ingredientsTest: View {
    @State private var responseData = "Loading..."
    var barcode: String
    
    var body: some View {
        VStack {
            Text(responseData)
                .padding()
                .onAppear {
                    let API = OpenFoodFactsAPI()
                    API.fetchData(barcode: barcode) { result in self.responseData = result; }
                }
        }
    }
}

//#Preview {
//    ingredientsTest()
//}
