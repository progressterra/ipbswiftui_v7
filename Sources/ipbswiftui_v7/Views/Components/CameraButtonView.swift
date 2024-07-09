//
//  SwiftUIView.swift
//
//
//  Created by Artemy Volkov on 27.07.2023.
//

import SwiftUI

/// A custom camera button view that triggers an image picker for capturing photos.
///
/// This view displays a camera icon and opens an image picker when tapped, allowing the user to take a photo with the device's camera. The captured image is then passed back through a binding.
///
/// ## Features
/// - **Interactive Camera Icon**: Presents a stylized camera button that users can tap to launch the camera.
/// - **Dynamic Style**: The button's style dynamically changes when active to indicate that the image picker is currently displayed.
/// - **Integration with Image Picker**: Utilizes ``ImagePicker``, a custom wrapper around `UIImagePickerController` to interface directly with SwiftUI.
///
/// ## Usage
/// `CameraButtonView` is intended to be used in forms or interfaces where users need to capture an image using the camera.
///
/// ```swift
/// struct ContentView: View {
///     @State private var image: UIImage?
///
///     var body: some View {
///         CameraButtonView(inputImage: $image)
///     }
/// }
/// ```
public struct CameraButtonView: View {
    /// A binding to a `UIImage?` that will store the image captured by the camera.
    @Binding var inputImage: UIImage?
    @State private var showingImagePicker = false
    
    public init(inputImage: Binding<UIImage?>) {
        self._inputImage = inputImage
    }
    
    public var body: some View {
        Image("camera", bundle: .module)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .frame(width: 56, height: 48)
            .foregroundStyle(
                            showingImagePicker
                           ? Style.primary
                           : LinearGradient(colors: [Style.textDisabled],
                                            startPoint: .center,
                                            endPoint: .center)
            )
            .onTapGesture { showingImagePicker = true }
            .animation(.default, value: showingImagePicker)
            .background(Style.surface)
            .cornerRadius(8)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
                    .edgesIgnoringSafeArea(.bottom)
            }
    }
}
