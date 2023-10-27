//
//  DaDataService.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.08.2023.
//

import Combine
import ipbswiftapi_v7
import Foundation

public struct DaDataService {
    
    private let networkDispatcher: NetworkDispatcher
    
    public init(networkDispatcher: NetworkDispatcher = NetworkDispatcher()) {
        self.networkDispatcher = networkDispatcher
    }
    
    public func getSuggestions(for address: String) -> AnyPublisher<Suggestions, NetworkRequestError> {
        guard let url = URL(string: IPBSettings.daDataBaseURL + "/suggest/address") else {
            return Fail(error: NetworkRequestError.customError("Invalid URL")).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Token \(IPBSettings.daDataAPIKey)", forHTTPHeaderField: "Authorization")
        
        let body = ["query": address]
        if let httpBody = try? JSONEncoder().encode(body) {
            request.httpBody = httpBody
        }
        
        return networkDispatcher.dispatch(request: request)
    }
    
    public func getAddressByGeo(latitude: Double, longitude: Double) -> AnyPublisher<Suggestions, NetworkRequestError> {
        guard let url = URL(string: IPBSettings.daDataBaseURL + "/geolocate/address") else {
            return Fail(error: NetworkRequestError.customError("Invalid URL")).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Token \(IPBSettings.daDataAPIKey)", forHTTPHeaderField: "Authorization")
        
        let body = ["lat": latitude, "lon": longitude]
        if let httpBody = try? JSONEncoder().encode(body) {
            request.httpBody = httpBody
        }
        
        return networkDispatcher.dispatch(request: request)
    }
}

public struct Suggestions: Codable, Hashable {
    public let suggestions: [Suggestion]
}

public struct Suggestion: Codable, Hashable {
    public let value: String
}
