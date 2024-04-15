//
//  AudioPlayerViewModel.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 08/04/24.
//

import Foundation
import AVFoundation
import MediaPlayer

class AudioPlayerViewModel: NSObject, ObservableObject {
    
    @Published private(set) var isPlaying = false
    
    @Published private(set) var musicDuration: CMTime = .zero
    @Published private(set) var currentMusicTime: CMTime = .zero
    
    private var audioPlayer: AVPlayer = AVPlayer()
    private static var timeObserverToken: Any? = nil
	private let hapticsManager: HapticsManager = HapticsManager()
	
	override init() {
		super.init()
		self.configureAudioSession()
		self.hapticsManager.prepareHapticEngine()
	}
	
    func playAudio(with urlString: String, mediaDetails: ControlCentreMediaDetails) {
		
		guard let url = URL(string: urlString) else {
			print("Invalid Media URL! \n")
			return
		}
		
		if let currentMediaURL = ((audioPlayer.currentItem?.asset) as? AVURLAsset)?.url {
			
			if currentMediaURL == url {
				return
			}
		}

        let audioItem = AVPlayerItem(url: url)
        audioPlayer.replaceCurrentItem(with: audioItem)
		
		setNowPlayingInfo(mediaDetails: mediaDetails)
        addPeriodicTimeObserver() //observing time played
        playMusic()
    }
    
    func pauseMusic() {
        if !isPlaying { return }
        audioPlayer.pause()
		hapticsManager.performHaptic()
        self.isPlaying = false
    }
    
    func playMusic() {
        if isPlaying { return }
        audioPlayer.play()
		hapticsManager.performHaptic()
        self.isPlaying = true
    }

    func getDuration() async {
        
        let duration = try? await audioPlayer.currentItem?.asset.load(.duration)
        guard let duration = duration else { return }
        DispatchQueue.main.async {
            self.musicDuration = duration
        }
    }
    
    private func addPeriodicTimeObserver() {
        // Invoke callback every half second
        let interval = CMTime(seconds: 0.5,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        // Add time observer. Invoke closure on the main queue.
        AudioPlayerViewModel.timeObserverToken =
            audioPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                self?.currentMusicTime = time
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print("Error configuring audio session: \(error.localizedDescription)")
        }
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [unowned self] event in
            self.playMusic()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.pauseMusic()
            return .success
        }
    }
	
	private func setNowPlayingInfo(mediaDetails: ControlCentreMediaDetails) {
		var nowPlayingInfo = [String : Any]()
		nowPlayingInfo[MPMediaItemPropertyTitle] = mediaDetails.songName
		nowPlayingInfo[MPMediaItemPropertyArtist] = mediaDetails.artist
		
		if let image = UIImage(data: mediaDetails.imageData) {
			nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ in
				return image
			})
		}
		
		nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.musicDuration.seconds
		nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.currentMusicTime.seconds
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}
}
