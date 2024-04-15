//
//  CacheManager.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 09/04/24.
//

import UIKit

enum UserDefaultKey:String {
    case networkingResponse = "NETWORKING_RESPONSE_USERDEFAULT_KEY"
}

class CacheManager {
    static let shared = CacheManager()
    
    lazy var imageCache: NSCache<NSString, NSData> = {
        let cache = NSCache<NSString, NSData>()
        cache.countLimit = 15
        cache.totalCostLimit = 1024*1024*50 //50 MB
        return cache
    }()
    
    func saveImageCache(_ image: NSData, identifier: String) {
        imageCache.setObject(image, forKey: NSString(string: identifier))
    }
    
    func fetchCacheImage(identifier: String) -> NSData? {
        let imageData = imageCache.object(forKey: NSString(string: identifier))
        return imageData
    }
}

struct UserDefaultManager {
    
    func fetchNetworkingResponse() -> SongListModel? {
        let songList = UserDefaults.standard.value(forKey: UserDefaultKey.networkingResponse.rawValue) as? SongListModel
        return songList
    }
    
    func storeNetworkingResponse(_ songList: SongListModel) {
        UserDefaults.standard.setValue(songList, forKey: UserDefaultKey.networkingResponse.rawValue)
    }
}
