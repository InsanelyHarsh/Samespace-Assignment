//
//  NetworkingService.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 09/04/24.
//

import Foundation

enum NetworkingError:Error {
	case invalidURL(urlString: String)
    case reqeustFailed(with: Error?)
    case invalidStatus
    case emptyResponse
    case decodingFailed(error: Error)
    case encodingFailed(error: Error)
    
    case connectionFailed
	
	///Message Presented to User
	var userMessage: String {
		switch self {
		case .invalidURL:
			return "Internal Error"
		case .reqeustFailed( _), .decodingFailed(_), .encodingFailed(_):
			return "Something went wrong, Please try again later."
		case .invalidStatus, .emptyResponse:
			return "Unexpected Response, Please try again later"
		case .connectionFailed:
			return "Unable to connect to the server, Please try again later"
		}
	}
	
	var internalLogDescription: String {
		switch self {
		case .invalidURL(let urlString):
			return "[ERROR] Invalid URL: \(urlString)"
		case .reqeustFailed(let with):
			return "[ERROR] Request Failed with Error: \(with?.localizedDescription ?? "0")"
		case .invalidStatus:
			return "[ERROR] Invalid Response Status"
		case .emptyResponse:
			return "[ERROR] Empty Response from Server"
		case .decodingFailed(let error):
			return "[ERROR] Decoding Failed with Error: \(error.localizedDescription)"
		case .encodingFailed(let error):
			return "[ERROR] Encoding Failed with Error: \(error.localizedDescription)"
		case .connectionFailed:
			return "[ERROR] Connection Request Failed"
		}
	}
}

final class NetworkingService {
    public func getRequest<T:Decodable>(url urlString:String,
                                        handler: @escaping (Result<T,NetworkingError>) -> Void) {
        

        guard let url = URL(string: urlString) else {
            handler(.failure(.invalidURL(urlString: urlString)))
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                handler(.failure(.reqeustFailed(with: error)))
                return
            }
            
            guard let response = response, let statusCode = response as? HTTPURLResponse else {
                return
            }
            
            if statusCode.statusCode < 200 ||  statusCode.statusCode > 299 {
                handler(.failure(.invalidStatus))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                handler(.success(decodedData))
            }catch(let error) {
                handler(.failure(.decodingFailed(error: error)))
                return
            }
            
        }.resume()
    }
    
    public func getData(url urlString:String,
                        handler: @escaping (Result<Data,NetworkingError>) -> Void) {
        guard let url = URL(string: urlString) else {
            handler(.failure(.invalidURL(urlString: urlString)))
            return
        }
        
		let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                handler(.failure(.reqeustFailed(with: error)))
                return
            }
            
//            guard let response = response, let statusCode = response as? HTTPURLResponse else {
//                return
//            }
            
//            if statusCode.statusCode < 200 ||  statusCode.statusCode > 299 {
//                handler(.failure(.invalidStatus))
//                return
//            }
            
            guard let data = data else {
                handler(.failure(.emptyResponse))
                return
            }
            
            handler(.success(data))
            
        }.resume()
    }
}
