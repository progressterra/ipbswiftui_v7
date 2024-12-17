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
    
    @State private var player = AVPlayer()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VideoPlayer(player: player)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
                    player.play()
                }
                .onDisappear {
                    player.pause()
                }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        player.pause()
                        dismiss()
                    }) {
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
