//
//  ImageViewer.swift
//
//
//  Created by Artemy Volkov on 21.07.2023.
//

import SwiftUI
import Kingfisher

/// `ImageViewer` is a SwiftUI view for displaying an image with zoom and pan functionalities.
/// It provides double-tap to zoom, drag to pan, and pinch to zoom gestures.
///
/// Usage:
///
///     ImageViewer(imageURL: "https://example.com/image.jpg")
///
/// or
///
///     ImageViewer(image: Image("myImage"))
///
/// - Parameters:
///   - imageURL: An optional string representing the URL of the image to be displayed.
///   - image: An optional `Image` object to be displayed.
///
/// The user can interact with the `ImageViewer` view in the following ways:
/// - Double-tap on the image to zoom in. Double-tap again to zoom out.
/// - Drag to pan the image when it's zoomed in.
/// - Pinch to zoom in and out.
///
/// The image is displayed with aspect ratio content mode set to `.fit`,
/// ensuring the entire image is visible without distortion.
public struct ImageViewer: View {
    
    let imageURL: String?
    let image: Image?
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var scaleEffectAnchor: UnitPoint = .center
    @State private var offset: CGPoint = .zero
    @State private var lastTranslation: CGSize = .zero
    
    public init(imageURL: String? = nil, image: Image? = nil) {
        self.imageURL = imageURL
        self.image = image
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                if let imageURL {
                    KFImage(URL(string: imageURL))
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale, anchor: scaleEffectAnchor)
                        .offset(x: offset.x, y: offset.y)
                        .gesture(makeDragGesture(size: proxy.size))
                        .gesture(makeMagnificationGesture(size: proxy.size))
                        .onTapGesture(count: 2) {
                            let location = CGPoint(x: $0.x, y: $0.y)
                            withAnimation {
                                if scale == 1 {
                                    scale *= 2
                                    scaleEffectAnchor = UnitPoint(x: location.x / proxy.size.width,
                                                                  y: location.y / proxy.size.height)
                                } else {
                                    scale = 1
                                    scaleEffectAnchor = .center
                                }
                            }
                        }
                } else if let image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale, anchor: scaleEffectAnchor)
                        .offset(x: offset.x, y: offset.y)
                        .gesture(makeDragGesture(size: proxy.size))
                        .gesture(makeMagnificationGesture(size: proxy.size))
                        .onTapGesture(count: 2) {
                            let location = CGPoint(x: $0.x, y: $0.y)
                            withAnimation {
                                if scale == 1 {
                                    scale *= 2
                                    scaleEffectAnchor = UnitPoint(x: location.x / proxy.size.width,
                                                                  y: location.y / proxy.size.height)
                                } else {
                                    scale = 1
                                    scaleEffectAnchor = .center
                                }
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    private func makeMagnificationGesture(size: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                
                // To minimize jittering
                if abs(1 - delta) > 0.01 {
                    scale *= delta
                }
            }
            .onEnded { _ in
                lastScale = 1
                if scale < 1 {
                    withAnimation {
                        scale = 1
                    }
                }
                adjustMaxOffset(size: size)
            }
    }
    
    private func makeDragGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let diff = CGPoint(
                    x: value.translation.width - lastTranslation.width,
                    y: value.translation.height - lastTranslation.height
                )
                offset = .init(x: offset.x + diff.x, y: offset.y + diff.y)
                lastTranslation = value.translation
            }
            .onEnded { _ in
                adjustMaxOffset(size: size)
            }
    }
    
    private func adjustMaxOffset(size: CGSize) {
        let maxOffsetX = (size.width * (scale - 1)) / 2
        let maxOffsetY = (size.height * (scale - 1)) / 2
        
        var newOffsetX = offset.x
        var newOffsetY = offset.y
        
        if abs(newOffsetX) > maxOffsetX {
            newOffsetX = maxOffsetX * (abs(newOffsetX) / newOffsetX)
        }
        if abs(newOffsetY) > maxOffsetY {
            newOffsetY = maxOffsetY * (abs(newOffsetY) / newOffsetY)
        }
        
        let newOffset = CGPoint(x: newOffsetX, y: newOffsetY)
        if newOffset != offset {
            withAnimation {
                offset = newOffset
            }
        }
        self.lastTranslation = .zero
    }
}
