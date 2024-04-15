//
//  URLConstants.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 09/04/24.
//

import Foundation

struct URLConstants {
    static private(set) var songsList = "https://cms.samespace.com/items/songs"
    
    static func songCoverImage(imageCoverID: String) -> String {
        return "https://cms.samespace.com/assets/\(imageCoverID)"
    }
}
