//
//  AsyncImageView.swift
//
//
//  Created by Artemy Volkov on 19.07.2023.
//

import SwiftUI
import Kingfisher

public struct AsyncImageView: View {
    let imageURL: String
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    
    public init(imageURL: String, width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        self.imageURL = imageURL
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        KFImage.url(URL(string: imageURL))
            .loadDiskFileSynchronously()
            .placeholder { ProgressView() }
            .fade(duration: 0.25)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
    }
}
