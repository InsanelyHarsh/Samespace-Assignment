//
//  HapticsManager.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 14/04/24.
//

import Foundation
import CoreHaptics

class HapticsManager: ObservableObject {
	
	var hapticEngine: CHHapticEngine?
	
	public func prepareHapticEngine() {
		if !checkHapticCpablity() {
			print("Device Does have Haptic Capability")
			return
		}
		do {
			self.hapticEngine = try CHHapticEngine()
			try self.hapticEngine?.start()
		}catch {
			print("Failed to start Hatpic Engine: \(error.localizedDescription)")
		}
	}
	
	public func performHaptic() {
		guard let hapticEngine = hapticEngine else { return }
		
		var events: [CHHapticEvent] = []
		
		let hapticEnventParameter: CHHapticEventParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
		let event = CHHapticEvent(eventType: .hapticTransient, parameters: [hapticEnventParameter], relativeTime: 0)
		events.append(event)
		
		do {
			let pattern = try CHHapticPattern(events: events, parameters: [])
			
			let hapticPlayer = try hapticEngine.makePlayer(with: pattern)
			try hapticPlayer.start(atTime: 0)
		}catch {
			print("Failed to play pattern: \(error.localizedDescription).")
		}
	}
	
	private func checkHapticCpablity() -> Bool {
		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
			return false
		}
		return true
	}
	
}
