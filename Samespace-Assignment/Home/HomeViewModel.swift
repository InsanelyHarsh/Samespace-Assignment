//
//  HomeViewModel.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 09/04/24.
//

import Foundation
import SwiftUI

final class HomeViewModel: ObservableObject {
    private let networkingService = NetworkingService()
	
	@Published private(set) var songListFetchState: NetworkingFetchState = .loading
	@Published var currentSongList: [SongModel] = []
	@Published var currentTopTracks: [SongModel] = []
	
    public func fetchSongsList() {
		self.songListFetchState = .loading
		
        self.networkingService.getRequest(url: URLConstants.songsList) { [weak self] (result:Result<SongListModel,NetworkingError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    withAnimation {
                    	self.currentSongList = success.data
						self.currentTopTracks = success.data.filter{$0.topTrack == true}
						self.songListFetchState = .finished
                    }
                }
            case .failure(let failure):
				DispatchQueue.main.async {
					self.songListFetchState = .failed(with: failure.userMessage)
					print("fetchSongsList:: \(failure.internalLogDescription) \n")
				}
            }
        }
    }
}
