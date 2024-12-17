import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL

    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL))
            .onAppear {
                // Опционально: Автоматически запускаем воспроизведение
                AVPlayer(url: videoURL).play()
            }
            .onDisappear {
                // Опционально: Останавливаем воспроизведение при закрытии
                AVPlayer(url: videoURL).pause()
            }
    }
}
