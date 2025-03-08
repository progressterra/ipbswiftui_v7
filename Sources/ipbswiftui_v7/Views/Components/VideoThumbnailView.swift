//
//  VideoThumbnailView.swift
//  ipbswiftui_v7
//
//  Created by Sergey Spevak on 09.03.2025.
//

import SwiftUI
import AVFoundation

struct VideoThumbnailView: View {
    let videoURL: URL
    
    @State private var thumbnailImage: UIImage? = nil

    var body: some View {
        Group {
            if let image = thumbnailImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .onAppear {
                        generateThumbnail()
                    }
            }
        }
        .frame(height: 64) // Размер превью
        .cornerRadius(8)
    }
    
    private func generateThumbnail() {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        
        DispatchQueue.global(qos: .background).async {
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self.thumbnailImage = uiImage
                }
            } catch {
                print("Ошибка получения превью: \(error.localizedDescription)")
            }
        }
    }
}
