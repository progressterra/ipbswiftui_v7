import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    //@Binding var isVideoPresented: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            }
            
//            VStack {
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        isVideoPresented = false
//                    }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.system(size: 30))
//                            .foregroundColor(.white)
//                            .padding()
//                    }
//                }
//                Spacer()
//            }
        }
        .onAppear {
            player = AVPlayer(url: videoURL)
        }
    }
}
