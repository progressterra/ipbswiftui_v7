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
        KFImage(URL(string: imageURL))
            .loadDiskFileSynchronously()
            .placeholder { ProgressView() }
            .onFailureImage(KFCrossPlatformImage(named: "placeholder", in: .module, with: .none))
            .retry(maxCount: 3)
            .fade(duration: 0.5)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: width, minHeight: height, maxHeight: height)
            .cornerRadius(cornerRadius)
    }
}
