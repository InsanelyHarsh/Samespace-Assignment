//
//  TabViewType.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 15/04/24.
//

import Foundation

enum TabViewType {
	case forYou
	case topTracks
	
	var tabTitle: String {
		switch self {
		case .forYou:
			return "For You"
		case .topTracks:
			return "Top Tracks"
		}
	}
}
