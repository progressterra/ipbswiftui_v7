//
//  CategoryCardView.swift
//  
//
//  Created by Artemy Volkov on 19.07.2023.
//

import SwiftUI

public struct CategoryCardView: View {
    let imageURL: String
    let name: String
    let onTapAction: () -> ()
    
    let width = UIScreen.main.bounds.size.width / 3.83

    public init(imageURL: String, name: String, onTapAction: @escaping () -> ()) {
        self.imageURL = imageURL
        self.name = name
        self.onTapAction = onTapAction
    }
    
    public var body: some View {
        VStack {
            AsyncImageView(
                imageURL: imageURL,
                width: width,
                height: width,
                cornerRadius: 8
            ).onTapGesture(perform: onTapAction)
            
            Text(name)
                .lineLimit(2)
                .font(Style.footnoteRegular)
                .foregroundColor(Style.textPrimary)
                .frame(width: width, height: 36, alignment: .top)
                .multilineTextAlignment(.center)
        }
    }
}



struct Previews_CategoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCardView(imageURL: "https://media.istockphoto.com/id/621235832/photo/autumn-morning-at-the-cathedral.jpg?s=612x612&w=0&k=20&c=5ALajgxiRg5xdhsvpnJ9QkjHPSFOuWgDb0jDPqduenM=", name: "Спортивные товары") {
            print("Tapped")
        }
    }
}
