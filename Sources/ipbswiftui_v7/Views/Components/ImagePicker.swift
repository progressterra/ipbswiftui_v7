//
//  ImagePicker.swift
//
//
//  Created by Artemy Volkov on 26.12.2023.
//

import SwiftUI

/// This struct provides a SwiftUI view that integrates with the `UIImagePickerController` to enable image selection from the camera.
///
/// ## Usage
///
/// To use `ImagePicker`, create an instance by binding a `UIImage` variable that will hold the selected image. The picker interface will automatically present the camera interface for image capture.
///
/// ```swift
/// @State private var image: UIImage?
/// @State private var isImagePickerPresented = false
///
/// var body: some View {
///     VStack {
///         if let image {
///             Image(uiImage: image)
///         }
///
///         Spacer()
///
///         Button("Select Image") {
///             isImagePickerPresented = true
///         }
///     }
///     .sheet(isPresented: $isImagePickerPresented) {
///          ImagePicker(image: $image)
///     }
/// }
/// ```
///
/// ## Important
///
/// - The device must have a camera available for this component to function correctly.
/// - Ensure the appropriate privacy permissions for camera access are set in your app's `Info.plist`.
///
/// When an image is picked, it updates the bound `UIImage` variable and dismisses the picker.
public struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var image: UIImage?
    
    public init(image: Binding<UIImage?>) {
        self._image = image
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
