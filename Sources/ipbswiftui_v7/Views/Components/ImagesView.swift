//
//  ImagesView.swift
//
//
//  Created by Artemy Volkov on 20.07.2023.
//

import SwiftUI

public struct ImagesView: View {
    @State private var selector = 0
    @State private var isImagePresented = false
    @State private var currentColor = 0
    
    let imageURLs: [String]
    let colours: [String]?
    
    private let size = UIScreen.main.bounds.width - 32
    
    public init(imageURLs: [String], colours: [String]? = nil) {
        self.imageURLs = imageURLs
        self.colours = colours
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            TabView(selection: $selector) {
                ForEach(0..<imageURLs.count, id: \.self) { index in
                    AsyncImageView(imageURL: imageURLs[index], width: size, height: size, cornerRadius: 8)
                        .tag(index)
                        .onTapGesture {
                            selector = index
                            isImagePresented = true
                        }
                        .fullScreenCover(isPresented: $isImagePresented) {
                            ImageViewer(imageURL: imageURLs[selector])
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        isImagePresented = false
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.black)
                                    .buttonStyle(.bordered)
                                    .clipShape(Circle())
                                    .padding()
                                }
                                .id(selector)
                        }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: size)
            
            VStack(spacing: 8) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(0..<imageURLs.count, id: \.self) { index in
                                SelectImageButtonView(imageURL: imageURLs[index]) {
                                    selector = index
                                }
                                .scaleEffect(selector == index ? 0.9 : 1)
                                .overlay {
                                    if selector == index {
                                        RoundedRectangle(cornerRadius: 8)
                                            .inset(by: 1)
                                            .strokeBorder()
                                            .gradientColor(gradient: Style.primary)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                    }
                    .padding(.horizontal, -12)
                    .onChange(of: selector) { newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                
                if let colours {
                    HStack(spacing: 4) {
                        Text("Цвет:")
                            .font(Style.footnoteRegular)
                            .foregroundColor(Style.textPrimary)
                        ForEach(0..<colours.count, id: \.self) { index in
                            Button(action: { withAnimation { currentColor = index } }) {
                                if currentColor == index {
                                    Text(colours[index])
                                        .font(Style.footnoteRegular)
                                        .gradientColor(gradient: Style.primary)
                                } else {
                                    Text(colours[index])
                                        .font(Style.footnoteRegular)
                                        .foregroundColor(Style.textDisabled)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Style.surface)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .animation(.default, value: selector)
    }
}

struct SelectImageButtonView: View {
    let imageURL: String
    let action: () -> ()
    
    var body: some View {
        Button(action: action) {
            AsyncImageView(imageURL: imageURL, width: 64, height: 64, cornerRadius: 6)
        }
        .buttonStyle(.plain)
    }
}


struct ImagesView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Style.background.ignoresSafeArea()
            ImagesView(imageURLs: [
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdwLNaJNplu9ls6XwV_YOqeaCMccPAEyLdcQ&usqp=CAU",
                "https://www.trustedreviews.com/wp-content/uploads/sites/54/2022/06/Steam-summer-sale.jpg",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNIcRlPYL68rHSXaRLou4ZeRKRBPvOS4X-JmBMhmqxOZE6ml0_pVsaFpJkK8AWQDEzmMI&usqp=CAU",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1w9waC7R0BrYo_pxOOxVbA0V7JQ71ZoRUQZdOtw01o7ZluFVMv3wHeQiihsBXO8KIV6E&usqp=CAU",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdwLNaJNplu9ls6XwV_YOqeaCMccPAEyLdcQ&usqp=CAU",
                "https://www.trustedreviews.com/wp-content/uploads/sites/54/2022/06/Steam-summer-sale.jpg",
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNIcRlPYL68rHSXaRLou4ZeRKRBPvOS4X-JmBMhmqxOZE6ml0_pVsaFpJkK8AWQDEzmMI&usqp=CAU"
            ], colours: ["Краcный", "Черный", "Синий"]
            )
        }
    }
}
