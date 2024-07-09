//
//  AsyncImageView.swift
//
//
//  Created by Artemy Volkov on 19.07.2023.
//

import SwiftUI
import Kingfisher

/// A SwiftUI view that asynchronously loads and displays an image from a URL using `Kingfisher`.
///
/// This view leverages `Kingfisher` to efficiently manage image downloading, caching, and displaying tasks. It is designed to handle image loading asynchronously, providing a smooth user experience even when loading large images or on slower network connections.
///
/// ## Usage
///
/// `AsyncImageView` requires the URL of the image, and dimensions for display. It also supports setting a corner radius for rounded image presentation. The view manages loading states internally, showing a progress view during loading and a placeholder image in case of failures.
///
/// ```swift
/// AsyncImageView(imageURL: "https://example.com/image.png", width: 100, height: 100, cornerRadius: 10)
/// ```
///
/// ## Parameters
/// - `imageURL`: A `String` representing the URL of the image to be loaded.
/// - `width`: A `CGFloat` value that sets the width of the image frame.
/// - `height`: A `CGFloat` value that sets the height of the image frame.
/// - `cornerRadius`: A `CGFloat` value that sets the corner radius of the image frame.
///
/// ## Features
/// - **Asynchronous Loading**: Images are loaded in the background, allowing the UI to remain responsive.
/// - **Caching**: Images are automatically cached by `Kingfisher` to improve performance and reduce network load.
/// - **Error Handling**: Provides a placeholder image if the image cannot be loaded.
/// - **Retries**: Automatically retries loading the image up to three times if the initial attempts fail.
/// - **Animations**: Includes a fade transition for image loading.
///
/// ## Notes
/// - Ensure the URL is correctly formatted and accessible.
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
