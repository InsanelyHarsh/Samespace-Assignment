//
//  RootView.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 13/04/24.
//

import SwiftUI

struct RootView: View {
	@StateObject var homeViewModel = HomeViewModel()
	@StateObject var audioPlayerViewModel: AudioPlayerViewModel = AudioPlayerViewModel()
	
	@GestureState private var dragOffset: CGSize = .zero
	@Namespace private var animation
	
	@State private var expandSheet: Bool = false
	@State private var currentTab: TabViewType = .forYou
	
	@State var currentSongIndex = -1 //fetch from db
	@State var currentSongPlayList: [SongModel] = []
	
	var body: some View {
		ZStack(alignment: .bottom) {
			
			
			switch homeViewModel.songListFetchState {
			case .loading:
				loadingScreen
			case .finished:
				contentView
			case .failed(let errorMessage):
				errorScreen(withMessage: errorMessage)
			}
			
			//Player
			VStack{
				ZStack {
					if expandSheet && currentSongIndex >= 0 {
						Rectangle()
							.fill(.clear)
							.clipShape(RoundedRectangle(cornerRadius: 10))
					} else if currentSongIndex >= 0 {
						DynamicColorView(urlString: URLConstants.songCoverImage(imageCoverID: homeViewModel.currentSongList[currentSongIndex].cover))
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.overlay {
								MusicPlayerView(songList: $currentSongPlayList,
												currentSongIndex: $currentSongIndex,
												expandSheet: $expandSheet,
												animation: animation)
								.environmentObject(audioPlayerViewModel)
							}
							.matchedGeometryEffect(id: "BGVIEW", in: animation)
					}
				}
				.frame( height: 70)
				
				//Tab Icons
				bottomTabBar
			}
		}
		.preferredColorScheme(.dark)
		.onAppear {
			self.homeViewModel.fetchSongsList()
		}
		.overlay{
			if expandSheet {
				ExpandedMusicPlayer(songList: $currentSongPlayList, currentSongIndex: $currentSongIndex, expandSheet: $expandSheet, animation: animation)
					.environmentObject(audioPlayerViewModel)
					.transition(.asymmetric(insertion: .identity, removal: .offset(y: -5)))
			}
		}
	}

	
	//Content
	private var contentView: some View {
		
		TabView(selection: $currentTab) {
			songList(homeViewModel.currentSongList)
				.tag(TabViewType.forYou)
			
			songList(homeViewModel.currentTopTracks)
				.tag(TabViewType.topTracks)
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
	}
	
	private var loadingScreen: some View {
		ScrollView(.vertical, showsIndicators: false) {
			VStack(spacing: 20) {
				ForEach(0..<10) { _ in
					loadingCell
				}
			}
		}.scrollDisabled(true)
	}
    
    private var bottomTabBar: some View {
        HStack {
			VStack(spacing: 8){
                Text("For You")
                
                Image(systemName: "circle.fill")
					.font(.caption2)
					.opacity(currentTab == .forYou ? 1 : 0)
            }
			.foregroundStyle(currentTab == .forYou ? .white : .gray)
			.scaleEffect(currentTab == .forYou ? 1.2 : 0.9)
			.onTapGesture {
				withAnimation {
					currentTab = .forYou
				}
			}
			
            Spacer()
            
			VStack(spacing: 8){
                Text("Top Tracks")
					
                Image(systemName: "circle.fill")
					.opacity(currentTab == .topTracks ? 1 : 0)
					.font(.caption2)
            }
			.foregroundStyle(currentTab == .topTracks ? .white : .gray)
			.scaleEffect(currentTab == .topTracks ? 1.2 : 0.9)
			.onTapGesture {
				withAnimation {
					currentTab = .topTracks
				}
			}
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 70)
		.padding([.top])
        .background(.black)
        .foregroundStyle(.white)
    }
	
	private func songList(_ songModelList: [SongModel]) -> some View {
		ScrollView(showsIndicators: false) {
			LazyVStack(spacing: 20) {
			
				ForEach(songModelList, id:\.id) { song in
					songListCell(song)
						.onTapGesture {
							withAnimation {
								self.currentSongPlayList = currentTab == .forYou ? homeViewModel.currentSongList : homeViewModel.currentTopTracks
								self.currentSongIndex = currentSongPlayList.firstIndex(of: song)!
							}
						}
				}
			}
		}
		.tint(.white)
		.refreshable {
			self.homeViewModel.fetchSongsList()
		}
	}
	
	private var loadingCell: some View {
		HStack {
			Circle()
				.frame(width: 55, height: 55)
			
			VStack(alignment: .leading, spacing: 6) {
				RoundedRectangle(cornerRadius: 4)
					.frame(height: 10)
					.padding(.trailing, 100)
				
				RoundedRectangle(cornerRadius: 4)
					.frame(height: 10)
					.padding(.trailing, 150)
			}
		}
		.shimer(.init(tint: .gray.opacity(0.3), highLight: .white, blur: 5))
	}
	
	@ViewBuilder
	private func songListCell(_ songModel: SongModel) -> some View {
		HStack(alignment: .center){
			FetchImageView(url: URLConstants.songCoverImage(imageCoverID: songModel.cover),
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
			.frame(width: 55, height: 55)
			.clipShape(Circle())
			
			VStack(alignment: .leading,spacing: 6){
				Text(songModel.name)
					.foregroundStyle(.white)
					.font(.headline)
				
				Text(songModel.artist)
					.foregroundStyle(.gray)
					.font(.subheadline)
			}
			
			Spacer()
		}
		.padding(.horizontal)
	}
	
	private func errorScreen(withMessage errorMessage: String) -> some View {
		VStack(alignment: .center,spacing: 25){
			Text(errorMessage)
				.font(.largeTitle)
			
			Button {
				self.homeViewModel.fetchSongsList()
			} label: {
				Text("Retry")
			}
			.buttonStyle(.borderedProminent)
		}
	}
}

#Preview {
    RootView()
}
