//
//  testView.swift
//  GeminiMultiturnChat
//
//  Created by Sri Yanamandra on 4/4/24.
//

import SwiftUI

struct TestView: View {
  let result: String
    
  init(tempBarcode: String, productInformation: ProductInformation?) {
          let productInfo = GetInfo(barcode: tempBarcode, productInformation: productInformation)
          result = productInfo.productInfoString
      }
    
    var body: some View {
        VStack {
            Text(result)
                .multilineTextAlignment(.leading)
        }
        .padding()
        
    }
}

//struct TestView_Previews: PreviewProvider {
//    static var previews: some View {
//      TestView(tempBarcode: "00723060")
//    }
//}
