//
//  Samespace_AssignmentApp.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 08/04/24.
//

import SwiftUI
import AVKit
import MediaPlayer

@main
struct Samespace_AssignmentApp: App {
	
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject private var networkMonitor = NetworkMonitor()
	
    var body: some Scene {
        WindowGroup {
			if networkMonitor.isConnected {
				RootView()
			} else {
				ContentUnavailableView(
					"No Internet Connection",
					systemImage: "wifi.exclamationmark",
					description: Text("Please check your connection and try again.")
				).preferredColorScheme(.dark)
			}
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		
		do {
			try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
			try AVAudioSession.sharedInstance().setActive(true)
		} catch {
			print("\(error.localizedDescription)")
			print(error)
		}
		
		return true
	}
}
