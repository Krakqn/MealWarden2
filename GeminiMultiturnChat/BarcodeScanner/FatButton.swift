//
//  FatButton.swift
//  GeminiMultiturnChat
//
//  Created by Sri Yanamandra on 4/14/24.
//

import SwiftUI

struct FatButton: View {
  var label: String
  var action: () -> ()
  
  init(_ label: String, _ action: @escaping () -> Void) {
    self.label = label
    self.action = action
  }
    var body: some View {
      Button(action: action) {
        Text(label)
          .fontSize(17, .medium, .white)
          .padding(.horizontal, 24)
          .padding(.vertical, 14)
          .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.accentColor))
      }
      .buttonStyle(.plain)
    }
}

extension View {
  func fontSize(_ size: CGFloat, _ weight: Font.Weight = .regular,  _ color: Color = .primary, _ design: Font.Design = .default) -> some View {
    self.font(.system(size: size, weight: weight, design: design)).foregroundStyle(color)
  }
}

