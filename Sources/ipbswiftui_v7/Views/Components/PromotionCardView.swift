//
//  PromotionCardView.swift
//  
//
//  Created by Artemy Volkov on 20.07.2023.
//

import SwiftUI

public struct PromotionCardView: View {
    let imageURL: String
    let title: String
    let onTapAction: () -> ()
    
    let size = UIScreen.main.bounds.size.width / 2.39
    
    public init(imageURL: String, title: String, onTapAction: @escaping () -> Void) {
        self.imageURL = imageURL
        self.title = title
        self.onTapAction = onTapAction
    }
    
    public var body: some View {
        Rectangle()
            .foregroundStyle(.clear)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.37, green: 0.37, blue: 0.45).opacity(0), location: 0.05),
                        Gradient.Stop(color: .black, location: 1.00)
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0.5),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: .black.opacity(0), location: 0.05),
                        Gradient.Stop(color: .black, location: 1.00)
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0.4),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
            .background(
                AsyncImageView(imageURL: imageURL, width: size, height: size, cornerRadius: 8)
            )
            .overlay(alignment: .bottomLeading) {
                Text(title)
                    .padding(10)
                    .font(Style.body)
                    .foregroundStyle(.white)
            }
            .onTapGesture(perform: onTapAction)
            .cornerRadius(8)
    }
}



struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PromotionCardView(imageURL: "https://media.istockphoto.com/id/621235832/photo/autumn-morning-at-the-cathedral.jpg?s=612x612&w=0&k=20&c=5ALajgxiRg5xdhsvpnJ9QkjHPSFOuWgDb0jDPqduenM=", title: "Весенняя распродажа") {
            print("Tapped")
        }
    }
}
