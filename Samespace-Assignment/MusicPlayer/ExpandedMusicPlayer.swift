//
//  ExpandedMusicPlayer.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 11/04/24.
//

import SwiftUI

struct ExpandedMusicPlayer: View {
    @Binding var songList:[SongModel]
    @Binding var currentSongIndex: Int
    
    @Binding  var expandSheet: Bool
    var animation: Namespace.ID
    
    @State private var animateContent: Bool = false
    @State private var offsetY: CGFloat = 0
	//@State var currentMusicCoverURL: String = ""
	
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
	
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            ZStack {
				
				DynamicColorView(urlString: URLConstants.songCoverImage(imageCoverID: songList[currentSongIndex].cover))
					.ignoresSafeArea()

                VStack(spacing: 35) {
                    Capsule()
                        .fill(.gray)
                        .frame(width: 40, height: 5, alignment: .center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : size.height)
					
					///*
                    HStack{
                        GeometryReader {
                            let size = $0.size
							
                            TabView(selection: $currentSongIndex) {
								ForEach(songList.indices) { index in
									FetchImageView(url: URLConstants.songCoverImage(imageCoverID: songList[index].cover),
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
									.frame(width: size.height, height: size.height)
									.clipShape(RoundedRectangle(cornerRadius: animateContent ? 15 : 5, style: .continuous))
									.tag(index)
                                }
                            }
                            .matchedGeometryEffect(id: "ARTWORK", in: animation)
							.padding(.vertical, size.height < 700 ? 10 : 30)
                            .tabViewStyle(.page(indexDisplayMode: .never))
                        }
                    }
                    //*/
                    
                    
                    //PlayerView
                    playerView(size)
                        .offset(y: animateContent ? 0 : size.height)
                }
                .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .top)
                .clipped()
            }
            .contentShape(Rectangle())
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        let translationY = value.translation.height
                        offsetY = (translationY > 0 ? translationY : 0)
                    }).onEnded({ value in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if offsetY > size.height * 0.4 {
                                self.animateContent = false
                                self.expandSheet = false
                            }else {
                                offsetY = .zero
                            }
                        }
                    })
            )
            .ignoresSafeArea(.container, edges: .all)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                animateContent = true
            }
        }
        .task {
            await self.audioPlayerViewModel.getDuration()
        }
        .onChange(of: currentSongIndex) { _, newValue in
            if newValue < 0 || newValue == songList.count {
                return
            }
            self.audioPlayerViewModel.pauseMusic()
			let currentSong = songList[currentSongIndex]
			audioPlayerViewModel.playAudio(with:  songList[newValue].url, mediaDetails: .init(songName: currentSong.name,
																							  artist: currentSong.artist,
																							  duration: "",
																							  currentDuration: "",
																							  imageData: Data()))
			
            Task {
                await audioPlayerViewModel.getDuration()
            }
        }
		.onChange(of: audioPlayerViewModel.currentMusicTime, initial: false) { _, newValue in
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
    }
    
    @ViewBuilder
    func playerView(_ mainSize: CGSize) -> some View {
        GeometryReader {
            let size = $0.size
            
            let spacing = size.height*0.08
            
            VStack(spacing: size.height*0.1) {
                VStack(spacing: spacing) {
					
					//Name and Artist
                    VStack(alignment: .center, spacing: 2) {
                        Text(songList[currentSongIndex].name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(songList[currentSongIndex].artist)
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity,alignment: .center)
                    
					//Timing Indicator
					VStack(spacing: 5){
						ZStack(alignment: .leading) {
							Capsule()
								.fill(.ultraThinMaterial)
								.frame(width: size.width*0.98, height: 5)
								
							Capsule()
								.foregroundStyle(.white)
								.frame(minWidth: .zero)
								.frame(width: max(0, (audioPlayerViewModel.musicDuration != .zero ? audioPlayerViewModel.currentMusicTime.seconds/audioPlayerViewModel.musicDuration.seconds : 0)*size.width*0.98))
								.frame(height: 5)
						}
						.padding(.top, spacing)
						
						
						HStack {
							Text(audioPlayerViewModel.currentMusicTime.formatted())
								.font(.caption)
								.foregroundStyle(.gray)
							
							Spacer(minLength: 0)
							
							Text(audioPlayerViewModel.musicDuration.formatted())
								.font(.caption)
								.foregroundStyle(.gray)
						}
					}
                }
				
                // Play Back Controls
                HStack(spacing: size.width*0.18) {
                    Button {
                        self.currentSongIndex -= 1
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(size.height < 300 ? .title3 : .title2)
                    }
					.disabled(currentSongIndex == 0)
					.foregroundStyle(currentSongIndex == 0 ? .gray : .white)
                    
                    Button {
						withAnimation(.none) {
							self.audioPlayerViewModel.isPlaying ? audioPlayerViewModel.pauseMusic() : audioPlayerViewModel.playMusic()
						}
                    } label: {
                        Image(systemName: audioPlayerViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(size.height < 300 ? .largeTitle : .system(size: 50))
                    }
					.foregroundStyle(.white)
                    
                    Button {
                        self.currentSongIndex += 1
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(size.height < 300 ? .title3 : .title2)
                    }
                    .disabled(currentSongIndex+1 == songList.count)
                    .foregroundStyle(currentSongIndex+1 == songList.count ? .gray : .white)
                }
				.sensoryFeedback(.increase, trigger: currentSongIndex)
            }
			.padding(.bottom, 30)
        }
    }
}
