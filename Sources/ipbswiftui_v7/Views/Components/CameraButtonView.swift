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
