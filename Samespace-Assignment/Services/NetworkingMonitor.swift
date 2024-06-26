//
//  NetworkingMonitor.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 14/04/24.
//

import Foundation
import Network

class NetworkMonitor: ObservableObject {
	private let networkMonitor = NWPathMonitor()
	private let workerQueue = DispatchQueue(label: "Monitor")
	@Published var isConnected = false

	init() {
		networkMonitor.pathUpdateHandler = { path in
			DispatchQueue.main.async {
				self.isConnected = path.status == .satisfied
			}
		}
		networkMonitor.start(queue: workerQueue)
	}
}
