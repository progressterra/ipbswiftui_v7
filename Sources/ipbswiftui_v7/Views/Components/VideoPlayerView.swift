import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showPlayButton = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .onTapGesture {
                        togglePlayPause()
                    }
            }

            if showPlayButton {
                Button(action: {
                    playVideo()
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 1.0), value: showPlayButton)
            }
        }
        .onAppear {
            player = AVPlayer(url: videoURL)
            player?.pause()
        }
    }

    private func playVideo() {
        player?.play()
        isPlaying = true
        withAnimation {
            showPlayButton = false
        }
    }

    private func togglePlayPause() {
        if isPlaying {
            player?.pause()
            isPlaying = false
            withAnimation {
                showPlayButton = true
            }
        }
    }
}

//import SwiftUI
//import AVKit
//
//struct VideoPlayerView: View {
//    let videoURL: URL
//    @State private var player: AVPlayer?
//    //@Binding var isVideoPresented: Bool
//
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//            
//            if let player = player {
//                VideoPlayer(player: player)
//                    .onAppear {
//                        player.play()
//                    }
//                    .onDisappear {
//                        player.pause()
//                    }
//            }
//            
////            VStack {
////                HStack {
////                    Spacer()
////                    Button(action: {
////                        isVideoPresented = false
////                    }) {
////                        Image(systemName: "xmark.circle.fill")
////                            .font(.system(size: 30))
////                            .foregroundColor(.white)
////                            .padding()
////                    }
////                }
////                Spacer()
////            }
//        }
//        .onAppear {
//            player = AVPlayer(url: videoURL)
//            player?.pause()
//        }
//    }
//}
