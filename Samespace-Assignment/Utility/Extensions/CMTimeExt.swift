//
//  CMTimeExt.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 15/04/24.
//

import Foundation


extension CMTime {
	func formatted() -> String {
		if self == .indefinite || self == .negativeInfinity || !self.isValid { return "0:00"}
		let totalSeconds = Int(CMTimeGetSeconds(self))
		let minutes = totalSeconds / 60
		let seconds = totalSeconds % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
}
