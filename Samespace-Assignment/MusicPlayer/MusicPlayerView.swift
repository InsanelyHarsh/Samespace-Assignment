//
//  MusicPlayerView.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 11/04/24.
//

import SwiftUI

struct MusicPlayerView: View {
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    
    @Binding var songList:[SongModel]
    @Binding var currentSongIndex: Int
    @Binding var expandSheet: Bool
	
    var animation: Namespace.ID
    
    var body: some View {
		HStack(spacing: 0) {
			
			ZStack{
				
				VStack(spacing: 15){
					if !expandSheet {
						GeometryReader { proxy in
							let size = proxy.size
							
							FetchImageView(url: URLConstants.songCoverImage(imageCoverID: songList[currentSongIndex].cover),
										   placeholder: {
								Image(systemName: "exclamationmark.triangle.fill")
									.resizable()
							},
										   imageData: { data in
								if let image = UIImage(data: data) {
									Image(uiImage: image)
										.resizable()
									
								}else {
									Image(systemName: "music.note")
										.resizable()
								}
							})
							.frame(width: size.width, height: size.height)
							//.aspectRatio(contentMode: .fill)
							.clipShape(Circle())
						}
						.matchedGeometryEffect(id: "ARTWORK", in: animation)
					}
				}
			}
			.frame(width: 45, height: 45)
			
			Text(songList[currentSongIndex].name)
				.fontWeight(.semibold)
				.lineLimit(1)
				.padding(.horizontal, 15)
			
			Spacer(minLength: 0)
			
			Button {
				audioPlayerViewModel.isPlaying ? audioPlayerViewModel.pauseMusic() : audioPlayerViewModel.playMusic()
			} label: {
				Image(systemName: audioPlayerViewModel.isPlaying ? "pause.fill" : "play.fill")
					.font(.title2)
					.foregroundStyle(.black)
					.padding(8)
					.background {
						Circle().foregroundStyle(.white)
					}
			}
		}
        .onAppear {
			let currentSong = songList[currentSongIndex]
			audioPlayerViewModel.playAudio(with:  songList[currentSongIndex].url, mediaDetails: .init(songName: currentSong.name,
																							  artist: currentSong.artist,
																							  duration: "",
																							  currentDuration: "",
																							  imageData: Data()))
        }
        .onChange(of: currentSongIndex) { _, newValue in
            self.audioPlayerViewModel.pauseMusic()
			let currentSong = songList[currentSongIndex]
			audioPlayerViewModel.playAudio(with:  songList[newValue].url, mediaDetails: .init(songName: currentSong.name,
																							  artist: currentSong.artist,
																							  duration: "",
																							  currentDuration: "",
																							  imageData: Data()))
        }
		
		.onChange(of: audioPlayerViewModel.currentMusicTime) { _, newValue in
			if newValue == .zero || audioPlayerViewModel.musicDuration == .indefinite || audioPlayerViewModel.musicDuration == .zero {
				return
			}
			
			if newValue == audioPlayerViewModel.musicDuration {
				if (currentSongIndex+1 < songList.count) {
					self.currentSongIndex += 1
				}else if (currentSongIndex+1 == songList.count) {
					self.currentSongIndex = 0
				}
			}
		}
        .padding(.horizontal)
        .padding(.bottom, 5)
        .foregroundStyle(.primary)
        .frame(height: 70)
		.contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                expandSheet = true
            }
		}
    }
}
