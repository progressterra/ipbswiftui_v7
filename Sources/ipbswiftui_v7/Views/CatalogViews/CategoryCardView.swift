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
    let displayName: String
    let onTapAction: () -> ()
    
    let width = UIScreen.main.bounds.size.width / 3.83
    
    public init(imageURL: String, name: String, displayName: String, onTapAction: @escaping () -> ()) {
        self.imageURL = imageURL
        self.name = name
        self.onTapAction = onTapAction
        self.displayName = displayName
    }
    
    public var body: some View {
        VStack {
            AsyncImageView(
                imageURL: imageURL,
                width: width,
                height: width,
                cornerRadius: 8
            ).onTapGesture(perform: onTapAction)
            
            Text(displayName)
                .lineLimit(2)
                .font(Style.footnoteRegular)
                .foregroundStyle(Style.textPrimary)
                .frame(width: width, height: 36, alignment: .top)
                .multilineTextAlignment(.center)
        }
    }
}


public struct CategoryCardOneLineView: View {
    let imageURL: String
    let name: String
    let displayName: String
    let onTapAction: () -> ()
    
    let width = UIScreen.main.bounds.size.width / 3.0
    
    public init(imageURL: String, name: String, displayName: String, onTapAction: @escaping () -> ()) {
        self.imageURL = imageURL
        self.name = name
        self.onTapAction = onTapAction
        self.displayName = displayName
    }
    
    public var body: some View {
        HStack {
            AsyncImageView(
                imageURL: imageURL,
                width: width,
                height: width,
                cornerRadius: 8
            )
            Spacer()
            Text(displayName)
                .font(Style.title)
                .foregroundStyle(Style.textSecondary)
                .multilineTextAlignment(.center)
                .padding(10)
                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Style.primary, lineWidth: 1))
                .lineLimit(1)
                                .truncationMode(.tail)
            Spacer()
        }.onTapGesture(perform: onTapAction)
    }
}




#Preview {
    VStack
    {
        CategoryCardView(imageURL: "https://media.istockphoto.com/id/621235832/photo/autumn-morning-at-the-cathedral.jpg?s=612x612&w=0&k=20&c=5ALajgxiRg5xdhsvpnJ9QkjHPSFOuWgDb0jDPqduenM=", name: "Спортивные товары", displayName: "Спортивные товары") {
            print("Tapped")
        }
        
        CategoryCardOneLineView(imageURL: "https://media.istockphoto.com/id/621235832/photo/autumn-morning-at-the-cathedral.jpg?s=612x612&w=0&k=20&c=5ALajgxiRg5xdhsvpnJ9QkjHPSFOuWgDb0jDPqduenM=", name: "Спортивные товары", displayName: "Спортивные товары") {
            print("Tapped")
        }
    }
}
