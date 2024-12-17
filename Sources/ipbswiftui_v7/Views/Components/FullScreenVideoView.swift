//
//  Untitled.swift
//  ipbswiftui_v7
//
//  Created by Sergey Spevak on 17.12.2024.
//
import AVKit
import SwiftUI

struct FullScreenVideoView: View {
    let videoURL: URL
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VideoPlayer(player: AVPlayer(url: videoURL))
                .edgesIgnoringSafeArea(.all)
                .onDisappear {
                    // Останавливаем воспроизведение при закрытии
                    AVPlayer(url: videoURL).pause()
                }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
