//
//  SwiftUIView.swift
//  
//
//  Created by Artemy Volkov on 27.07.2023.
//

import SwiftUI

public struct CameraButtonView: View {
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
            .gradientColor(gradient:
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

fileprivate struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var image: UIImage?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
